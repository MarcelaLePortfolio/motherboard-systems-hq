import test from "node:test";
import assert from "node:assert/strict";

import {
  handoffSchedulerReadinessToGovernedExecution,
} from "./governed-execution-handoff";
import type { SchedulerDispatchContractResult } from "./scheduler-dispatch-contract";
import type { ProductionSchedulerRuntimeFinalizationReadinessCompletionConsumerResult } from "./production-scheduler-runtime-finalization-readiness-completion-consumer";

const dispatch: SchedulerDispatchContractResult = {
  ok: true,
  contract: "scheduler_dispatch_contract",
  scheduler_dispatch_ready: true,
  scheduler_transition_authorized: true,
  envelope_id: "envelope-1",
  package_id: "package-1",
  package_version: 1,
  assigned_department: "engineering",
  required_capabilities_snapshot: null,
  scheduler_authorized: false,
  routing_authorized: false,
  worker_claim_authorized: false,
  orchestration_authorized: false,
  execution_authorized: false,
  new_authority_introduced: false,
  findings: ["test scheduler dispatch"],
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
    findings: ["test terminal readiness completion"],
  };

function fakeDb({
  packageId = "package-1",
  packageVersion = 1,
}: {
  packageId?: string;
  packageVersion?: number;
} = {}) {
  return {
    prepare: () => ({
      all: () => [
        {
          approval_id: "approval-1",
          envelope_id: "envelope-1",
          package_id: packageId,
          package_version: packageVersion,
        },
      ],
    }),
  } as any;
}

function governanceDependencies() {
  return {
    db: fakeDb(),
    evaluate_approval: (() => ({
      ok: true,
    })) as any,
    execute_commit: (() => {
      throw new Error("commit must not be invoked");
    }) as any,
    execute_push: (() => {
      throw new Error("push must not be invoked");
    }) as any,
    load_approval: (() => ({
      approval_id: "approval-1",
      envelope_id: "envelope-1",
      package_id: "package-1",
      package_version: 1,
      approved_by: "user",
      approval_scope: "planning_only",
      commit_authorized: false,
      push_authorized: false,
      remote: "origin",
      branch: "feature/test",
      issued_at: new Date().toISOString(),
      expires_at: null,
      justification: null,
      status: "approved",
      created_at: new Date().toISOString(),
    })) as any,
    load_scope: (() => ({
      approval_id: "approval-1",
      envelope_id: "envelope-1",
      package_id: "package-1",
      package_version: 1,
      repo_path: "/tmp/repo",
      expected_head:
        "1111111111111111111111111111111111111111",
      branch: "feature/test",
      allowed_paths: ["server/example.ts"],
      forbidden_paths: [],
      scope_constraints: "bounded test scope",
      created_at: new Date().toISOString(),
    })) as any,
    load_governance_chain: (() => ({
      governance: { ok: true },
      package: {},
      delegation: {
        delegation_id: "delegation-1",
        project_id: "hq",
        delegated_by: "user",
        authorization_state: "authorized",
      },
      validation: {},
      envelope_gate: {},
      envelope: {},
    })) as any,
    compile_approval: ((approval: any) => ({
      approval_id: approval.approval_id,
      approved_by: approval.approved_by,
      approval_scope: approval.approval_scope,
      mutation_authorized: false,
      shell_execution_authorized: false,
      autonomous_execution_authorized: false,
      version_control_authorization: {
        commit_authorized: false,
        push_authorized: false,
        remote: "origin",
        branch: "feature/test",
      },
      issued_at: approval.issued_at,
      expires_at: null,
      justification: null,
      status: "approved",
    })) as any,
    execute_execution: ((request: any) => {
      assert.equal(request.executionId, "execution-test-1");
      assert.equal(request.commitRequested, false);
      assert.equal(request.pushRequested, false);
      assert.equal(request.commitMessage, undefined);
      assert.equal(request.localCommitResult, undefined);

      return {
        status: "ok",
        execution_id: request.executionId,
        commit_requested: false,
        push_requested: false,
        commit_result: null,
        push_result: null,
      };
    }) as any,
    persist_reconciliation_entry: (() => ({
      entry_id: 1,
    })) as any,
  };
}

test(
  "hands scheduler readiness to governed execution as a no-effect request without creating authority",
  () => {
    const dependencies = governanceDependencies();

    const result =
      handoffSchedulerReadinessToGovernedExecution(
        {
          scheduler_dispatch_contract: dispatch,
          scheduler_runtime_finalization_readiness_completion:
            completion,
        },
        {
          db: fakeDb(),
          governance_execution_dependencies:
            dependencies as any,
          create_execution_id: () =>
            "execution-test-1",
        },
      );

    assert.equal(result.ok, true);

    if (!result.ok) {
      assert.fail("expected successful governed execution handoff");
    }

    assert.equal(
      result.governed_execution_handoff_completed,
      true,
    );
    assert.equal(result.approval_id, "approval-1");
    assert.equal(result.envelope_id, "envelope-1");
    assert.equal(result.package_id, "package-1");
    assert.equal(result.package_version, 1);
    assert.equal(
      result.execution_id,
      "execution-test-1",
    );
    assert.equal(result.commit_requested, false);
    assert.equal(result.push_requested, false);
    assert.equal(result.scheduler_authorized, false);
    assert.equal(result.routing_authorized, false);
    assert.equal(result.worker_claim_authorized, false);
    assert.equal(result.orchestration_authorized, false);
    assert.equal(result.execution_authorized, false);
    assert.equal(result.new_authority_introduced, false);
  },
);

test(
  "fails closed when terminal scheduler readiness completion is absent",
  () => {
    const result =
      handoffSchedulerReadinessToGovernedExecution(
        {
          scheduler_dispatch_contract: dispatch,
          scheduler_runtime_finalization_readiness_completion:
            {
              ...completion,
              ok: false,
              scheduler_runtime_finalization_readiness_completion_consumed:
                false,
            },
        },
        {
          db: fakeDb(),
          governance_execution_dependencies:
            governanceDependencies() as any,
          create_execution_id: () =>
            "execution-test-2",
        },
      );

    assert.equal(result.ok, false);
    assert.equal(
      result.governed_execution_handoff_completed,
      false,
    );
    assert.equal(result.execution_authorized, false);
    assert.equal(result.new_authority_introduced, false);
  },
);

test(
  "fails closed when durable scope lineage disagrees with scheduler dispatch lineage",
  () => {
    const result =
      handoffSchedulerReadinessToGovernedExecution(
        {
          scheduler_dispatch_contract: dispatch,
          scheduler_runtime_finalization_readiness_completion:
            completion,
        },
        {
          db: fakeDb({
            packageId: "wrong-package",
          }),
          governance_execution_dependencies:
            governanceDependencies() as any,
          create_execution_id: () =>
            "execution-test-3",
        },
      );

    assert.equal(result.ok, false);
    assert.equal(
      result.governed_execution_handoff_completed,
      false,
    );
    assert.match(
      result.findings[0],
      /lineage does not match/,
    );
    assert.equal(result.execution_authorized, false);
    assert.equal(result.new_authority_introduced, false);
  },
);

test(
  "fails closed when durable scope is not uniquely resolvable by envelope",
  () => {
    const missingDb = {
      prepare: () => ({
        all: () => [],
      }),
    } as any;

    const result =
      handoffSchedulerReadinessToGovernedExecution(
        {
          scheduler_dispatch_contract: dispatch,
          scheduler_runtime_finalization_readiness_completion:
            completion,
        },
        {
          db: missingDb,
          governance_execution_dependencies:
            governanceDependencies() as any,
          create_execution_id: () =>
            "execution-test-4",
        },
      );

    assert.equal(result.ok, false);
    assert.match(
      result.findings[0],
      /exactly one durable execution scope/,
    );
    assert.equal(result.execution_authorized, false);
    assert.equal(result.new_authority_introduced, false);
  },
);
