import test from "node:test";
import assert from "node:assert/strict";

import { composeProductionSchedulerRuntimeDispatchFinalization } from "./production-scheduler-runtime-dispatch-finalization-composition";
import type { ProductionSchedulerRuntimeDispatchConsumerResult } from "./production-scheduler-runtime-dispatch-consumer";

const consumedDispatchRequest: ProductionSchedulerRuntimeDispatchConsumerResult = {
  ok: true,
  consumer: "production_scheduler_runtime_dispatch_consumer",
  scheduler_runtime_dispatch_consumed: true,
  scheduler_authorized: false,
  routing_authorized: false,
  worker_claim_authorized: false,
  orchestration_authorized: false,
  execution_authorized: false,
  new_authority_introduced: false,
  findings: ["test scheduler runtime dispatch consumer success"],
};

const rejectedDispatchRequest: ProductionSchedulerRuntimeDispatchConsumerResult = {
  ok: false,
  consumer: "production_scheduler_runtime_dispatch_consumer",
  scheduler_runtime_dispatch_consumed: false,
  scheduler_authorized: false,
  routing_authorized: false,
  worker_claim_authorized: false,
  orchestration_authorized: false,
  execution_authorized: false,
  new_authority_introduced: false,
  findings: ["test scheduler runtime dispatch consumer failure"],
};

test("dispatch-authorization-to-finalization composition connects the verified production chain without introducing execution authority", () => {
  const result = composeProductionSchedulerRuntimeDispatchFinalization({
    production_scheduler_runtime_dispatch_consumer: consumedDispatchRequest,
  });

  assert.equal(result.scheduler_runtime_dispatch_authorization.ok, true);
  assert.equal(result.scheduler_runtime_dispatch_contract.ok, true);
  assert.equal(
    result.production_scheduler_runtime_dispatch_contract_consumer.ok,
    true,
  );
  assert.equal(result.scheduler_runtime_finalization_boundary.ok, true);
  assert.equal(result.scheduler_runtime_finalization_entry_point.ok, true);
  assert.equal(
    result.production_scheduler_runtime_finalization_consumer.ok,
    true,
  );

  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});

test("dispatch-authorization-to-finalization composition preserves fail-closed behavior when runtime dispatch was not consumed", () => {
  const result = composeProductionSchedulerRuntimeDispatchFinalization({
    production_scheduler_runtime_dispatch_consumer: rejectedDispatchRequest,
  });

  assert.equal(result.scheduler_runtime_dispatch_authorization.ok, false);
  assert.equal(result.scheduler_runtime_dispatch_contract.ok, false);
  assert.equal(
    result.production_scheduler_runtime_dispatch_contract_consumer.ok,
    false,
  );
  assert.equal(result.scheduler_runtime_finalization_boundary.ok, false);
  assert.equal(result.scheduler_runtime_finalization_entry_point.ok, false);
  assert.equal(
    result.production_scheduler_runtime_finalization_consumer.ok,
    false,
  );

  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});
