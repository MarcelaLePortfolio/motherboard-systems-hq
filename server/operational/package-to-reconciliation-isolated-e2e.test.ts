import assert from "node:assert/strict";
import test from "node:test";
import Database from "better-sqlite3";

import {
  projectCanonicalPackageToMissionPackage,
} from "../../db/canonical-package-mission-projection";
import {
  getOperationalPackageForProject,
  selectOperationalPackageForProject,
} from "../../db/operational-package-authority";
import {
  ensureGovernanceExecutionApprovalTable,
  persistGovernanceExecutionApproval,
} from "../../db/governance-execution-approval-persistence";
import {
  ensureGovernanceExecutionScopeTable,
  persistGovernanceExecutionScope,
} from "../../db/governance-execution-scope-persistence";
import {
  listGovernanceExecutionReconciliationEntries,
  persistGovernanceExecutionReconciliationEntry,
} from "../../db/governance-execution-reconciliation-persistence";
import {
  composeProductionSchedulerRuntimeTerminalGovernedExecution,
} from "./production-scheduler-runtime-terminal-governed-execution-composition";
import type {
  SchedulerDispatchContractResult,
} from "./scheduler-dispatch-contract";
import type {
  ProductionSchedulerRuntimeFinalizationReadinessCompletionConsumerResult,
} from "./production-scheduler-runtime-finalization-readiness-completion-consumer";

test("isolated package lineage reaches durable governed no-effect reconciliation", () => {
  const db = new Database(":memory:");
  db.pragma("foreign_keys = ON");

  const projectId = "hq";
  const packageId = "pkg-isolated-e2e";
  const packageVersion = 1;
  const conversationId = "conversation-isolated-e2e";
  const envelopeId = "env-isolated-e2e";
  const approvalId = "approval-isolated-e2e";
  const executionId = "execution-isolated-e2e";

  try {
    db.exec(`
      CREATE TABLE project_registry (
        project_id TEXT PRIMARY KEY
      );

      CREATE TABLE matilda_canonical_packages (
        project_id TEXT NOT NULL,
        package_id TEXT NOT NULL,
        package_version INTEGER NOT NULL,
        conversation_id TEXT NOT NULL,
        approved_expected_outcome TEXT NOT NULL,
        approved_success_criteria TEXT NOT NULL,
        approved_scope TEXT NOT NULL,
        approved_constraints TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        PRIMARY KEY (package_id, package_version)
      );

      CREATE TABLE governance_packages (
        package_id TEXT NOT NULL,
        package_version INTEGER NOT NULL,
        project_id TEXT,
        conversation_id TEXT,
        requested_outcome TEXT,
        scope TEXT,
        containment TEXT,
        constraints TEXT,
        success_criteria TEXT,
        context TEXT,
        style_presentation_intent TEXT,
        exclusions TEXT,
        created_at TEXT NOT NULL,
        PRIMARY KEY (package_id, package_version)
      );

      CREATE TABLE operational_package_authority (
        project_id TEXT PRIMARY KEY,
        package_id TEXT NOT NULL,
        package_version INTEGER NOT NULL,
        selected_at TEXT NOT NULL
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
    `);

    db.prepare(`
      INSERT INTO project_registry (project_id) VALUES (?)
    `).run(projectId);

    db.prepare(`
      INSERT INTO matilda_canonical_packages (
        project_id,
        package_id,
        package_version,
        conversation_id,
        approved_expected_outcome,
        approved_success_criteria,
        approved_scope,
        approved_constraints,
        status,
        created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      projectId,
      packageId,
      packageVersion,
      conversationId,
      "Validate package-to-reconciliation continuity",
      "Exact lineage and no repository effects",
      "Isolated governed validation",
      "No production effects or new authority",
      "canonical_approved",
      "2026-10-23T00:00:00.000Z",
    );

    const projection = projectCanonicalPackageToMissionPackage(db, {
      project_id: projectId,
      package_id: packageId,
      package_version: packageVersion,
    });

    assert.equal(projection.project_id, projectId);
    assert.equal(projection.package_id, packageId);
    assert.equal(projection.package_version, packageVersion);
    assert.equal(projection.delegation_authorized, false);
    assert.equal(projection.execution_authorized, false);

    const selection = selectOperationalPackageForProject(db, {
      project_id: projectId,
      package_id: packageId,
      package_version: packageVersion,
    });

    assert.equal(selection.package_id, packageId);
    assert.equal(selection.package_version, packageVersion);
    assert.deepEqual(
      getOperationalPackageForProject(db, projectId),
      selection,
    );

    const projected = db.prepare(`
      SELECT project_id, package_id, package_version, conversation_id
      FROM governance_packages
      WHERE package_id = ? AND package_version = ?
    `).get(packageId, packageVersion) as {
      project_id: string;
      package_id: string;
      package_version: number;
      conversation_id: string;
    };

    assert.deepEqual(projected, {
      project_id: projectId,
      package_id: packageId,
      package_version: packageVersion,
      conversation_id: conversationId,
    });

    // Controlled governance fixture: no production delegation or Ellis evidence.
    db.prepare(`
      INSERT INTO governance_envelopes (
        envelope_id,
        package_id,
        package_version,
        delegation_id,
        validation_result_id,
        envelope_gate_id
      ) VALUES (?, ?, ?, ?, ?, ?)
    `).run(
      envelopeId,
      packageId,
      packageVersion,
      "delegation-isolated-e2e",
      "validation-isolated-e2e",
      "gate-isolated-e2e",
    );

    ensureGovernanceExecutionApprovalTable(db);

    persistGovernanceExecutionApproval(db, {
      approval_id: approvalId,
      envelope_id: envelopeId,
      package_id: packageId,
      package_version: packageVersion,
      approved_by: "isolated-test",
      approval_scope: "isolated_no_effect",
      commit_authorized: false,
      push_authorized: false,
      remote: "origin",
      branch: "feature/isolated-test",
      issued_at: new Date().toISOString(),
      justification: "Isolated package-to-reconciliation test only",
    });

    ensureGovernanceExecutionScopeTable(db);

    persistGovernanceExecutionScope(db, {
      approval_id: approvalId,
      envelope_id: envelopeId,
      package_id: packageId,
      package_version: packageVersion,
      repo_path: "/tmp/isolated-no-effect",
      expected_head: "1".repeat(40),
      branch: "feature/isolated-test",
      allowed_paths: ["server/operational/"],
      forbidden_paths: [],
      scope_constraints: "No-effect validation only",
    });

    // Controlled scheduler fixtures, not production Ellis lifecycle evidence.
    const dispatch: SchedulerDispatchContractResult = {
      ok: true,
      contract: "scheduler_dispatch_contract",
      scheduler_dispatch_ready: true,
      scheduler_transition_authorized: true,
      envelope_id: envelopeId,
      package_id: packageId,
      package_version: packageVersion,
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

    const completion:
      ProductionSchedulerRuntimeFinalizationReadinessCompletionConsumerResult = {
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
        delegation_id: "delegation-isolated-e2e",
        project_id: projectId,
        package_id: packageId,
        package_version: packageVersion,
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
      approval_id: approvalId,
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
            assert.fail("Commit must never execute");
          },
          execute_push: () => {
            assert.fail("Push must never execute");
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
    assert.equal(handoff.envelope_id, envelopeId);
    assert.equal(handoff.package_id, packageId);
    assert.equal(handoff.package_version, packageVersion);
    assert.equal(handoff.approval_id, approvalId);
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
      assert.equal(entry.approval_id, approvalId);
      assert.equal(entry.envelope_id, envelopeId);
      assert.equal(entry.package_id, packageId);
      assert.equal(entry.package_version, packageVersion);
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

    assert.equal(handoff.execution_authorized, false);
    assert.equal(handoff.new_authority_introduced, false);
  } finally {
    db.close();
  }
});
