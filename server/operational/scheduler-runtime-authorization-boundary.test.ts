
import test from "node:test";

import assert from "node:assert/strict";

import { authorizeSchedulerRuntimeTransition } from "./scheduler-runtime-authorization-boundary.ts";

import type { ProductionSchedulerRuntimeConsumerResult } from "./production-scheduler-runtime-consumer.ts";

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

test("scheduler runtime authorization boundary authorizes only scheduler runtime transition", () => {

  const result = authorizeSchedulerRuntimeTransition({

    production_scheduler_runtime_consumer: consumedRuntimeRequest,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_transition_authorized, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime authorization boundary fails closed when runtime request was not consumed", () => {

  const result = authorizeSchedulerRuntimeTransition({

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

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_transition_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

