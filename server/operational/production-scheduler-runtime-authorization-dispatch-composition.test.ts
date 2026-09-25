import test from "node:test";
import assert from "node:assert/strict";

import { composeProductionSchedulerRuntimeAuthorizationDispatch } from "./production-scheduler-runtime-authorization-dispatch-composition";
import type { ProductionSchedulerRuntimeConsumerResult } from "./production-scheduler-runtime-consumer";

const consumedRuntimeRequest: ProductionSchedulerRuntimeConsumerResult = {
  ok: true,
  consumer: "production_scheduler_runtime_consumer",
  scheduler_runtime_consumed: true,
  scheduler_authorized: false,
  routing_authorized: false,
  worker_claim_authorized: false,
  orchestration_authorized: false,
  execution_authorized: false,
  new_authority_introduced: false,
  findings: ["test scheduler runtime consumer success"],
};

test("runtime authorization-to-dispatch composition connects the verified production chain without introducing execution authority", () => {
  const result = composeProductionSchedulerRuntimeAuthorizationDispatch({
    production_scheduler_runtime_consumer: consumedRuntimeRequest,
  });

  assert.equal(result.scheduler_runtime_authorization.ok, true);
  assert.equal(
    result.scheduler_runtime_authorization.scheduler_runtime_transition_authorized,
    true,
  );
  assert.equal(result.scheduler_runtime_contract.ok, true);
  assert.equal(
    result.scheduler_runtime_contract.scheduler_runtime_contract_ready,
    true,
  );
  assert.equal(result.production_scheduler_runtime_contract_consumer.ok, true);
  assert.equal(
    result.production_scheduler_runtime_contract_consumer
      .scheduler_runtime_contract_consumed,
    true,
  );
  assert.equal(result.scheduler_runtime_dispatch_boundary.ok, true);
  assert.equal(
    result.scheduler_runtime_dispatch_boundary.scheduler_runtime_dispatch_ready,
    true,
  );
  assert.equal(result.scheduler_runtime_dispatch_entry_point.ok, true);
  assert.equal(
    result.scheduler_runtime_dispatch_entry_point
      .scheduler_runtime_dispatch_request_ready,
    true,
  );
  assert.equal(result.production_scheduler_runtime_dispatch_consumer.ok, true);
  assert.equal(
    result.production_scheduler_runtime_dispatch_consumer
      .scheduler_runtime_dispatch_consumed,
    true,
  );

  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});

test("runtime authorization-to-dispatch composition preserves fail-closed behavior when runtime was not consumed", () => {
  const result = composeProductionSchedulerRuntimeAuthorizationDispatch({
    production_scheduler_runtime_consumer: {
      ok: false,
      consumer: "production_scheduler_runtime_consumer",
      scheduler_runtime_consumed: false,
      scheduler_authorized: false,
      routing_authorized: false,
      worker_claim_authorized: false,
      orchestration_authorized: false,
      execution_authorized: false,
      new_authority_introduced: false,
      findings: ["test scheduler runtime consumer failure"],
    },
  });

  assert.equal(result.scheduler_runtime_authorization.ok, false);
  assert.equal(
    result.scheduler_runtime_authorization.scheduler_runtime_transition_authorized,
    false,
  );
  assert.equal(result.scheduler_runtime_contract.ok, false);
  assert.equal(result.production_scheduler_runtime_contract_consumer.ok, false);
  assert.equal(result.scheduler_runtime_dispatch_boundary.ok, false);
  assert.equal(result.scheduler_runtime_dispatch_entry_point.ok, false);
  assert.equal(result.production_scheduler_runtime_dispatch_consumer.ok, false);

  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});
