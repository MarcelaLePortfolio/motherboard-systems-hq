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
  handoffSchedulerReadinessToGovernedExecution,
} from "./governed-execution-handoff";
import type {
  SchedulerDispatchContractResult,
} from "./scheduler-dispatch-contract";
import type {
  ProductionSchedulerRuntimeFinalizationReadinessCompletionConsumerResult,
} from "./production-scheduler-runtime-finalization-readiness-completion-consumer";

function createFixture() {
  const db = new Database(":memory:");
  db.pragma("foreign_keys = ON");

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
    justification: "Isolated no-effect test fixture only",
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

  const dispatch = {
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
  } as SchedulerDispatchContractResult;

  const completion = {
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
  } as ProductionSchedulerRuntimeFinalizationReadinessCompletionConsumerResult;

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

  const reconciliationStages: string[] = [];

  const dependencies = {
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
    persist_reconciliation_entry: (_db: unknown, entry: any) => {
      reconciliationStages.push(entry.stage);
      return { entry_id: reconciliationStages.length };
    },
  };

  return {
    db,
    dispatch,
    completion,
    dependencies,
    reconciliationStages,
  };
}

test("isolated no_effect handoff reaches real governance execution route", () => {
  const fixture = createFixture();

  try {
    const result = handoffSchedulerReadinessToGovernedExecution(
      {
        scheduler_dispatch_contract: fixture.dispatch,
        scheduler_runtime_finalization_readiness_completion:
          fixture.completion,
        effect_intent: { kind: "no_effect" },
      },
      {
        db: fixture.db,
        governance_execution_dependencies: fixture.dependencies as any,
        create_execution_id: () => "isolated-no-effect-x1",
      },
    );

    assert.equal(result.ok, true, JSON.stringify(result.findings));

    if (!result.ok) {
      return;
    }

    assert.equal(result.governed_execution_handoff_completed, true);
    assert.equal(result.envelope_id, "e1");
    assert.equal(result.package_id, "p1");
    assert.equal(result.package_version, 1);
    assert.equal(result.approval_id, "a1");
    assert.equal(result.commit_requested, false);
    assert.equal(result.push_requested, false);
    assert.equal(result.execution_result.ok, true);

    assert.deepEqual(fixture.reconciliationStages, [
      "EXECUTION_STARTED",
      "EXECUTION_NO_EFFECT_COMPLETED",
    ]);

    assert.equal(result.scheduler_authorized, false);
    assert.equal(result.routing_authorized, false);
    assert.equal(result.worker_claim_authorized, false);
    assert.equal(result.orchestration_authorized, false);
    assert.equal(result.execution_authorized, false);
    assert.equal(result.new_authority_introduced, false);
  } finally {
    fixture.db.close();
  }
});
