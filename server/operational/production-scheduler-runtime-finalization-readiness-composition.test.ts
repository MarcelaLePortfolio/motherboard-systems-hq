import test from "node:test";
import assert from "node:assert/strict";

import { composeProductionSchedulerRuntimeFinalizationReadiness } from "./production-scheduler-runtime-finalization-readiness-composition";
import type { ProductionSchedulerRuntimeFinalizationConsumerResult } from "./production-scheduler-runtime-finalization-consumer";

const consumed: ProductionSchedulerRuntimeFinalizationConsumerResult = {
  ok: true,
  consumer: "production_scheduler_runtime_finalization_consumer",
  scheduler_runtime_finalization_consumed: true,
  scheduler_authorized: false,
  routing_authorized: false,
  worker_claim_authorized: false,
  orchestration_authorized: false,
  execution_authorized: false,
  new_authority_introduced: false,
  findings: ["test finalization consumer success"],
};

const rejected: ProductionSchedulerRuntimeFinalizationConsumerResult = {
  ok: false,
  consumer: "production_scheduler_runtime_finalization_consumer",
  scheduler_runtime_finalization_consumed: false,
  scheduler_authorized: false,
  routing_authorized: false,
  worker_claim_authorized: false,
  orchestration_authorized: false,
  execution_authorized: false,
  new_authority_introduced: false,
  findings: ["test finalization consumer failure"],
};

test("finalization authorization-to-readiness composition connects the verified production chain without introducing execution authority", () => {
  const result = composeProductionSchedulerRuntimeFinalizationReadiness({
    production_scheduler_runtime_finalization_consumer: consumed,
  });

  assert.equal(result.scheduler_runtime_finalization_authorization.ok, true);
  assert.equal(result.scheduler_runtime_finalization_contract.ok, true);
  assert.equal(
    result.production_scheduler_runtime_finalization_contract_consumer.ok,
    true,
  );
  assert.equal(
    result.scheduler_runtime_finalization_readiness_boundary.ok,
    true,
  );
  assert.equal(
    result.scheduler_runtime_finalization_readiness_entry_point.ok,
    true,
  );
  assert.equal(
    result.production_scheduler_runtime_finalization_readiness_consumer.ok,
    true,
  );

  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});

test("finalization authorization-to-readiness composition preserves fail-closed behavior", () => {
  const result = composeProductionSchedulerRuntimeFinalizationReadiness({
    production_scheduler_runtime_finalization_consumer: rejected,
  });

  assert.equal(result.scheduler_runtime_finalization_authorization.ok, false);
  assert.equal(result.scheduler_runtime_finalization_contract.ok, false);
  assert.equal(
    result.production_scheduler_runtime_finalization_contract_consumer.ok,
    false,
  );
  assert.equal(
    result.scheduler_runtime_finalization_readiness_boundary.ok,
    false,
  );
  assert.equal(
    result.scheduler_runtime_finalization_readiness_entry_point.ok,
    false,
  );
  assert.equal(
    result.production_scheduler_runtime_finalization_readiness_consumer.ok,
    false,
  );

  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});
