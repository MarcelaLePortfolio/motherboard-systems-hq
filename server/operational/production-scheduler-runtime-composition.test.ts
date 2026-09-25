import test from "node:test";
import assert from "node:assert/strict";

import { composeProductionSchedulerRuntime } from "./production-scheduler-runtime-composition";
import type { ProductionSchedulerExecutionConsumerResult } from "./production-scheduler-execution-consumer";

const consumedExecutionRequest: ProductionSchedulerExecutionConsumerResult = {
  ok: true,
  consumer: "production_scheduler_execution_consumer",
  scheduler_execution_consumed: true,
  scheduler_authorized: false,
  routing_authorized: false,
  worker_claim_authorized: false,
  orchestration_authorized: false,
  execution_authorized: false,
  new_authority_introduced: false,
  findings: ["test scheduler execution consumer success"],
};

test("production scheduler runtime composition connects the existing runtime chain without introducing authority", () => {
  const result = composeProductionSchedulerRuntime({
    production_scheduler_execution_consumer: consumedExecutionRequest,
  });

  assert.equal(result.scheduler_runtime_boundary.ok, true);
  assert.equal(
    result.scheduler_runtime_boundary.scheduler_runtime_ready,
    true,
  );

  assert.equal(result.scheduler_runtime_entry_point.ok, true);
  assert.equal(
    result.scheduler_runtime_entry_point.scheduler_runtime_request_ready,
    true,
  );

  assert.equal(result.production_scheduler_runtime_consumer.ok, true);
  assert.equal(
    result.production_scheduler_runtime_consumer.scheduler_runtime_consumed,
    true,
  );

  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});

test("production scheduler runtime composition preserves fail-closed behavior when execution was not consumed", () => {
  const result = composeProductionSchedulerRuntime({
    production_scheduler_execution_consumer: {
      ok: false,
      consumer: "production_scheduler_execution_consumer",
      scheduler_execution_consumed: false,
      scheduler_authorized: false,
      routing_authorized: false,
      worker_claim_authorized: false,
      orchestration_authorized: false,
      execution_authorized: false,
      new_authority_introduced: false,
      findings: ["test scheduler execution consumer failure"],
    },
  });

  assert.equal(result.scheduler_runtime_boundary.ok, false);
  assert.equal(
    result.scheduler_runtime_boundary.scheduler_runtime_ready,
    false,
  );

  assert.equal(result.scheduler_runtime_entry_point.ok, false);
  assert.equal(
    result.scheduler_runtime_entry_point.scheduler_runtime_request_ready,
    false,
  );

  assert.equal(result.production_scheduler_runtime_consumer.ok, false);
  assert.equal(
    result.production_scheduler_runtime_consumer.scheduler_runtime_consumed,
    false,
  );

  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});
