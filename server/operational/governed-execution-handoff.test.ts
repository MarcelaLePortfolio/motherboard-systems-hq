import test from "node:test";
import assert from "node:assert/strict";

import {
  handoffSchedulerReadinessToGovernedExecution,
  type GovernedExecutionEffectIntent,
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

function dependencies() {
  return {
    db: fakeDb(),
    evaluate_approval: (() => ({ ok: true })) as any,
    execute_commit: (() => {
      throw new Error("commit must not be invoked");
    }) as any,
    execute_push: (() => {
      throw new Error("push must not be invoked");
    }) as any,
  } as any;
}

function invoke(
  effectIntent: GovernedExecutionEffectIntent,
  executionId: string,
) {
  let captured: any = null;

  const result =
    handoffSchedulerReadinessToGovernedExecution(
      {
        scheduler_dispatch_contract: dispatch,
        scheduler_runtime_finalization_readiness_completion:
          completion,
        effect_intent: effectIntent,
      },
      {
        db: fakeDb(),
        governance_execution_dependencies:
          dependencies(),
        create_execution_id: () => executionId,
        invoke_governance_execution:
          ((body: any) => {
            captured = body;

            return {
              ok: true,
              route: "governance_execution_route",
              execution: {
                status: "ok",
                execution_id: body.execution_id,
                commit_requested: body.commit_requested,
                push_requested: body.push_requested,
                commit_result: null,
                push_result: null,
              },
              route_mounted: false,
              production_reachability_authorized: false,
              production_approval_gate_bound: false,
              new_authority_introduced: false,
            };
          }) as any,
      },
    );

  return { result, captured };
}

function assertAuthorityBoundary(result: any) {
  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
}

test("transports no-effect intent", () => {
  const { result, captured } =
    invoke({ kind: "no_effect" }, "exec-no-effect");

  assert.equal(result.ok, true);
  assert.equal(captured.commit_requested, false);
  assert.equal(captured.push_requested, false);
  assertAuthorityBoundary(result);
});

test("transports commit-only intent", () => {
  const { result, captured } =
    invoke(
      {
        kind: "commit",
        commit_message: "bounded commit",
      },
      "exec-commit",
    );

  assert.equal(result.ok, true);
  assert.equal(captured.commit_requested, true);
  assert.equal(captured.push_requested, false);
  assert.equal(captured.commit_message, "bounded commit");
  assertAuthorityBoundary(result);
});

test("transports commit-and-push intent", () => {
  const { result, captured } =
    invoke(
      {
        kind: "commit_and_push",
        commit_message: "bounded commit and push",
      },
      "exec-commit-push",
    );

  assert.equal(result.ok, true);
  assert.equal(captured.commit_requested, true);
  assert.equal(captured.push_requested, true);
  assert.equal(
    captured.commit_message,
    "bounded commit and push",
  );
  assertAuthorityBoundary(result);
});

test("transports push-only intent with prior commit reference", () => {
  const { result, captured } =
    invoke(
      {
        kind: "push",
        prior_commit_execution_id: "prior-exec-1",
      },
      "exec-push",
    );

  assert.equal(result.ok, true);
  assert.equal(captured.commit_requested, false);
  assert.equal(captured.push_requested, true);
  assert.equal(
    captured.prior_commit_execution_id,
    "prior-exec-1",
  );
  assertAuthorityBoundary(result);
});

test("fails closed for push intent without prior commit reference", () => {
  const result =
    handoffSchedulerReadinessToGovernedExecution(
      {
        scheduler_dispatch_contract: dispatch,
        scheduler_runtime_finalization_readiness_completion:
          completion,
        effect_intent: {
          kind: "push",
          prior_commit_execution_id: "",
        },
      },
      {
        db: fakeDb(),
        governance_execution_dependencies:
          dependencies(),
      },
    );

  assert.equal(result.ok, false);
  assert.match(
    result.findings[0],
    /requires prior_commit_execution_id/,
  );
  assertAuthorityBoundary(result);
});

test("fails closed for commit intent without commit message", () => {
  const result =
    handoffSchedulerReadinessToGovernedExecution(
      {
        scheduler_dispatch_contract: dispatch,
        scheduler_runtime_finalization_readiness_completion:
          completion,
        effect_intent: {
          kind: "commit",
          commit_message: "",
        },
      },
      {
        db: fakeDb(),
        governance_execution_dependencies:
          dependencies(),
      },
    );

  assert.equal(result.ok, false);
  assert.match(
    result.findings[0],
    /requires commit_message/,
  );
  assertAuthorityBoundary(result);
});

test("fails closed when terminal readiness is absent", () => {
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
        effect_intent: { kind: "no_effect" },
      },
      {
        db: fakeDb(),
        governance_execution_dependencies:
          dependencies(),
      },
    );

  assert.equal(result.ok, false);
  assertAuthorityBoundary(result);
});

test("fails closed on durable lineage mismatch", () => {
  const result =
    handoffSchedulerReadinessToGovernedExecution(
      {
        scheduler_dispatch_contract: dispatch,
        scheduler_runtime_finalization_readiness_completion:
          completion,
        effect_intent: { kind: "no_effect" },
      },
      {
        db: fakeDb({ packageId: "wrong-package" }),
        governance_execution_dependencies:
          dependencies(),
      },
    );

  assert.equal(result.ok, false);
  assert.match(result.findings[0], /lineage does not match/);
  assertAuthorityBoundary(result);
});

test("fails closed when durable scope is not unique", () => {
  const result =
    handoffSchedulerReadinessToGovernedExecution(
      {
        scheduler_dispatch_contract: dispatch,
        scheduler_runtime_finalization_readiness_completion:
          completion,
        effect_intent: { kind: "no_effect" },
      },
      {
        db: {
          prepare: () => ({
            all: () => [],
          }),
        } as any,
        governance_execution_dependencies:
          dependencies(),
      },
    );

  assert.equal(result.ok, false);
  assert.match(
    result.findings[0],
    /exactly one durable execution scope/,
  );
  assertAuthorityBoundary(result);
});
