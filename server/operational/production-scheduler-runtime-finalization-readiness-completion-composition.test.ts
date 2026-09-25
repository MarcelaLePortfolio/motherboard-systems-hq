import test from "node:test";
import assert from "node:assert/strict";

import { composeProductionSchedulerRuntimeFinalizationReadinessCompletion } from "./production-scheduler-runtime-finalization-readiness-completion-composition";
import type { ProductionSchedulerRuntimeFinalizationReadinessConsumerResult } from "./production-scheduler-runtime-finalization-readiness-consumer";

const consumed: ProductionSchedulerRuntimeFinalizationReadinessConsumerResult = {
  ok: true,
  consumer: "production_scheduler_runtime_finalization_readiness_consumer",
  scheduler_runtime_finalization_readiness_consumed: true,
  scheduler_authorized: false,
  routing_authorized: false,
  worker_claim_authorized: false,
  orchestration_authorized: false,
  execution_authorized: false,
  new_authority_introduced: false,
  findings: ["test finalization readiness consumer success"],
};

const rejected: ProductionSchedulerRuntimeFinalizationReadinessConsumerResult = {
  ok: false,
  consumer: "production_scheduler_runtime_finalization_readiness_consumer",
  scheduler_runtime_finalization_readiness_consumed: false,
  scheduler_authorized: false,
  routing_authorized: false,
  worker_claim_authorized: false,
  orchestration_authorized: false,
  execution_authorized: false,
  new_authority_introduced: false,
  findings: ["test finalization readiness consumer failure"],
};

test("readiness-authorization-to-completion composition connects the verified production chain without introducing execution authority", () => {
  const result =
    composeProductionSchedulerRuntimeFinalizationReadinessCompletion({
      production_scheduler_runtime_finalization_readiness_consumer: consumed,
    });

  assert.equal(
    result.scheduler_runtime_finalization_readiness_authorization.ok,
    true,
  );
  assert.equal(
    result.scheduler_runtime_finalization_readiness_contract.ok,
    true,
  );
  assert.equal(
    result.production_scheduler_runtime_finalization_readiness_contract_consumer
      .ok,
    true,
  );
  assert.equal(
    result.scheduler_runtime_finalization_readiness_completion_boundary.ok,
    true,
  );
  assert.equal(
    result.scheduler_runtime_finalization_readiness_completion_entry_point.ok,
    true,
  );
  assert.equal(
    result
      .production_scheduler_runtime_finalization_readiness_completion_consumer
      .ok,
    true,
  );

  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});

test("readiness-authorization-to-completion composition preserves fail-closed behavior", () => {
  const result =
    composeProductionSchedulerRuntimeFinalizationReadinessCompletion({
      production_scheduler_runtime_finalization_readiness_consumer: rejected,
    });

  assert.equal(
    result.scheduler_runtime_finalization_readiness_authorization.ok,
    false,
  );
  assert.equal(
    result.scheduler_runtime_finalization_readiness_contract.ok,
    false,
  );
  assert.equal(
    result.production_scheduler_runtime_finalization_readiness_contract_consumer
      .ok,
    false,
  );
  assert.equal(
    result.scheduler_runtime_finalization_readiness_completion_boundary.ok,
    false,
  );
  assert.equal(
    result.scheduler_runtime_finalization_readiness_completion_entry_point.ok,
    false,
  );
  assert.equal(
    result
      .production_scheduler_runtime_finalization_readiness_completion_consumer
      .ok,
    false,
  );

  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});
