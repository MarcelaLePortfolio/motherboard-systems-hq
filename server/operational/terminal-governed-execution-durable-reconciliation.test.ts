import test from "node:test";
import assert from "node:assert/strict";
import Database from "better-sqlite3";

import {
  ensureGovernanceExecutionApprovalTable,
  persistGovernanceExecutionApproval,
} from "../../db/governance-execution-approval-persistence";
import {
  ensureGovernanceExecutionScopeTable,
  persistGovernanceExecutionScope,
} from "../../db/governance-execution-scope-persistence";
import {
  persistGovernanceExecutionReconciliationEntry,
  listGovernanceExecutionReconciliationEntries,
} from "../../db/governance-execution-reconciliation-persistence";
import {
  composeProductionSchedulerRuntimeTerminalGovernedExecution,
} from "./production-scheduler-runtime-terminal-governed-execution-composition";
import type { SchedulerDispatchContractResult } from "./scheduler-dispatch-contract";
import type { ProductionSchedulerRuntimeFinalizationReadinessCompletionConsumerResult } from "./production-scheduler-runtime-finalization-readiness-completion-consumer";

test("isolated terminal composition persists governed no-effect reconciliation", () => {
  const db = new Database(":memory:");
  db.pragma("foreign_keys = ON");

  try {
    db.exec(`
      CREATE TABLE governance_packages (
        package_id TEXT NOT NULL,
        package_version INTEGER NOT NULL,
        PRIMARY KEY (package_id, package_version)
      );

      CREATE TABLE governance_envelopes (
        envelope_id TEXT PRIMARY KEY,
        package_id TEXT NOT NULL,
        package_version INTEGER NOT NULL,
        delegation_id TEXT NOT NULL,
        validation_result_id TEXT NOT NULL,
        envelope_gate_id TEXT NOT NULL,
        FOREIGN KEY (package_id, package_version)
          REFERENCES governance_packages(package_id, package_version)
      );

      INSERT INTO governance_packages VALUES ('p1', 1);
      INSERT INTO governance_envelopes
      VALUES ('e1', 'p1', 1, 'd1', 'v1', 'g1');
    `);

    ensureGovernanceExecutionApprovalTable(db);

    persistGovernanceExecutionApproval(db, {
      approval_id: "a1",
      envelope_id: "e1",
      package_id: "p1",
      package_version: 1,
      approved_by: "isolated-test",
      approval_scope: "isolated_no_effect",
      commit_authorized: false,
      push_authorized: false,
      remote: "origin",
      branch: "feature/isolated-test",
      issued_at: new Date().toISOString(),
      justification: "Isolated durable reconciliation test only",
    });

    ensureGovernanceExecutionScopeTable(db);

    persistGovernanceExecutionScope(db, {
      approval_id: "a1",
      envelope_id: "e1",
      package_id: "p1",
      package_version: 1,
      repo_path: "/tmp/isolated-no-effect",
      expected_head: "1".repeat(40),
      branch: "feature/isolated-test",
      allowed_paths: ["server/operational/"],
      forbidden_paths: [],
      scope_constraints: "Isolated no-effect validation only",
    });

    const dispatch: SchedulerDispatchContractResult = {
      ok: true,
      contract: "scheduler_dispatch_contract",
      scheduler_dispatch_ready: true,
      scheduler_transition_authorized: true,
      envelope_id: "e1",
      package_id: "p1",
      package_version: 1,
      assigned_department: "engineering",
      required_capabilities_snapshot: null,
      scheduler_authorized: false,
      routing_authorized: false,
      worker_claim_authorized: false,
      orchestration_authorized: false,
      execution_authorized: false,
      new_authority_introduced: false,
      findings: ["isolated dispatch fixture"],
    };

    const completion: ProductionSchedulerRuntimeFinalizationReadinessCompletionConsumerResult = {
      ok: true,
      consumer:
        "production_scheduler_runtime_finalization_readiness_completion_consumer",
      scheduler_runtime_finalization_readiness_completion_consumed: true,
      scheduler_authorized: false,
      routing_authorized: false,
      worker_claim_authorized: false,
      orchestration_authorized: false,
      execution_authorized: false,
      new_authority_introduced: false,
      findings: ["isolated completion fixture"],
    };

    const governance = {
      delegation: {
        delegation_id: "d1",
        project_id: "hq",
        package_id: "p1",
        package_version: 1,
        delegated_by: "isolated-test",
        authorization_state: "AUTHORIZED",
      },
      governance: {
        ok: true,
        authorization_state: "AUTHORIZED",
        validation_status: "VALIDATION_PASSED",
        gate_status: "OPEN",
      },
    };

    const compiledApproval = {
      approval_id: "a1",
      approved_by: "isolated-test",
      approval_scope: "isolated_no_effect",
      mutation_authorized: false,
      shell_execution_authorized: false,
      autonomous_execution_authorized: false,
      version_control_authorization: {
        commit_authorized: false,
        push_authorized: false,
        remote: "origin",
        branch: "feature/isolated-test",
      },
      issued_at: new Date().toISOString(),
      expires_at: null,
      justification: "Isolated no-effect validation",
      status: "approved",
    };

    const executionId = "isolated-terminal-durable-x1";

    const result = composeProductionSchedulerRuntimeTerminalGovernedExecution(
      {
        scheduler_dispatch_contract: dispatch,
        production_scheduler_runtime_finalization_readiness_completion_consumer:
          completion,
        effect_intent: { kind: "no_effect" },
      },
      {
        db,
        create_execution_id: () => executionId,
        governance_execution_dependencies: {
          db,
          load_governance_chain: () => governance as any,
          compile_approval: () => compiledApproval as any,
          evaluate_approval: () => ({
            ok: true,
            version_control_authorization: {
              commit_authorized: false,
              push_authorized: false,
            },
          }),
          execute_commit: () => {
            assert.fail("commit effect must never run");
          },
          execute_push: () => {
            assert.fail("push effect must never run");
          },
          persist_reconciliation_entry:
            persistGovernanceExecutionReconciliationEntry,
        } as any,
      },
    );

    assert.equal(
      result.scheduler_runtime_finalization_readiness_completion_authorization.ok,
      true,
    );
    assert.equal(
      result.scheduler_runtime_finalization_readiness_completion_contract.ok,
      true,
    );
    assert.equal(
      result.production_scheduler_runtime_finalization_readiness_completion_contract_consumer.ok,
      true,
    );

    const handoff = result.governed_execution_handoff;
    assert.ok(handoff);
    assert.equal(handoff.ok, true, JSON.stringify(handoff.findings));

    if (!handoff.ok) {
      return;
    }

    assert.equal(handoff.execution_id, executionId);
    assert.equal(handoff.envelope_id, "e1");
    assert.equal(handoff.package_id, "p1");
    assert.equal(handoff.package_version, 1);
    assert.equal(handoff.approval_id, "a1");
    assert.equal(handoff.commit_requested, false);
    assert.equal(handoff.push_requested, false);
    assert.equal(handoff.execution_result.ok, true);

    const entries = listGovernanceExecutionReconciliationEntries(
      db,
      executionId,
    );

    assert.deepEqual(
      entries.map((entry) => entry.stage),
      ["EXECUTION_STARTED", "EXECUTION_NO_EFFECT_COMPLETED"],
    );

    assert.deepEqual(
      entries.map((entry) => entry.entry_sequence),
      [1, 2],
    );

    for (const entry of entries) {
      assert.equal(entry.execution_id, executionId);
      assert.equal(entry.approval_id, "a1");
      assert.equal(entry.envelope_id, "e1");
      assert.equal(entry.package_id, "p1");
      assert.equal(entry.package_version, 1);
      assert.equal(entry.repo_path, "/tmp/isolated-no-effect");
      assert.equal(entry.expected_head, "1".repeat(40));
      assert.equal(entry.commit_requested, false);
      assert.equal(entry.push_requested, false);
      assert.equal(entry.local_effect_status, "none");
      assert.equal(entry.remote_effect_status, "none");
    }

    assert.equal(result.scheduler_authorized, false);
    assert.equal(result.routing_authorized, false);
    assert.equal(result.worker_claim_authorized, false);
    assert.equal(result.orchestration_authorized, false);
    assert.equal(result.execution_authorized, false);
    assert.equal(result.new_authority_introduced, false);

    assert.equal(handoff.scheduler_authorized, false);
    assert.equal(handoff.routing_authorized, false);
    assert.equal(handoff.worker_claim_authorized, false);
    assert.equal(handoff.orchestration_authorized, false);
    assert.equal(handoff.execution_authorized, false);
    assert.equal(handoff.new_authority_introduced, false);
  } finally {
    db.close();
  }
});
