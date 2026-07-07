
import test from "node:test";

import assert from "node:assert/strict";

import { evaluateSchedulerExecutionReadinessBoundary } from "./scheduler-execution-readiness-boundary";

import type { ProductionSchedulerDispatchConsumerResult } from "./production-scheduler-dispatch-consumer";

const consumedDispatch: ProductionSchedulerDispatchConsumerResult = {

  ok: true,

  consumer: "production_scheduler_dispatch_consumer",

  scheduler_dispatch_consumed: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler dispatch consumer success"],

};

test("scheduler execution readiness boundary confirms readiness without authorizing scheduler execution", () => {

  const result = evaluateSchedulerExecutionReadinessBoundary({

    production_scheduler_dispatch_consumer: consumedDispatch,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_execution_ready, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler execution readiness boundary fails closed when dispatch was not consumed", () => {

  const result = evaluateSchedulerExecutionReadinessBoundary({

    production_scheduler_dispatch_consumer: {

            ok: false,

            consumer: "production_scheduler_dispatch_consumer",

            scheduler_dispatch_consumed: false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: ["test scheduler dispatch consumer failure"],

          },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_execution_ready, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

