
import test from "node:test";

import assert from "node:assert/strict";

import { evaluateSchedulerRuntimeBoundary } from "./scheduler-runtime-boundary";

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

test("scheduler runtime boundary confirms runtime readiness without authorizing scheduler runtime", () => {

  const result = evaluateSchedulerRuntimeBoundary({

    production_scheduler_execution_consumer: consumedExecutionRequest,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_ready, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime boundary fails closed when execution request was not consumed", () => {

  const result = evaluateSchedulerRuntimeBoundary({

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

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_ready, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

