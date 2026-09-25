import test from "node:test";
import assert from "node:assert/strict";

import { composeProductionSchedulerRuntimeTerminalGovernedExecution } from "./production-scheduler-runtime-terminal-governed-execution-composition";
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
  findings: ["test dispatch"],
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
  findings: ["test completion"],
};

test("terminal composition reaches terminal contract consumption while preserving authority boundaries", () => {
  const result =
    composeProductionSchedulerRuntimeTerminalGovernedExecution({
      scheduler_dispatch_contract: {
        ...dispatch,
        ok: false,
        scheduler_dispatch_ready: false,
        scheduler_transition_authorized: false,
        findings: ["force governed handoff closed after terminal composition"],
      },
      production_scheduler_runtime_finalization_readiness_completion_consumer:
        completion,
      effect_intent: { kind: "no_effect" },
    });

  assert.equal(
    result.scheduler_runtime_finalization_readiness_completion_authorization.ok,
    true,
  );
  assert.equal(
    result.scheduler_runtime_finalization_readiness_completion_contract.ok,
    true,
  );
  assert.equal(
    result
      .production_scheduler_runtime_finalization_readiness_completion_contract_consumer
      .ok,
    true,
  );
  assert.equal(
    result
      .production_scheduler_runtime_finalization_readiness_completion_contract_consumer
      .scheduler_runtime_finalization_readiness_completion_contract_consumed,
    true,
  );

  assert.ok(result.governed_execution_handoff);
  assert.equal(result.governed_execution_handoff.ok, false);

  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});

test("terminal composition fails closed before governed handoff when completion is absent", () => {
  const result =
    composeProductionSchedulerRuntimeTerminalGovernedExecution({
      scheduler_dispatch_contract: dispatch,
      production_scheduler_runtime_finalization_readiness_completion_consumer: {
        ...completion,
        ok: false,
        scheduler_runtime_finalization_readiness_completion_consumed: false,
        findings: ["test completion absent"],
      },
      effect_intent: { kind: "no_effect" },
    });

  assert.equal(
    result.scheduler_runtime_finalization_readiness_completion_authorization.ok,
    false,
  );
  assert.equal(
    result.scheduler_runtime_finalization_readiness_completion_contract.ok,
    false,
  );
  assert.equal(
    result
      .production_scheduler_runtime_finalization_readiness_completion_contract_consumer
      .ok,
    false,
  );
  assert.equal(result.governed_execution_handoff, null);

  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});
