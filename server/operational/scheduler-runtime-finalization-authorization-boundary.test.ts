
import test from "node:test";

import assert from "node:assert/strict";

import { authorizeSchedulerRuntimeFinalizationTransition } from "./scheduler-runtime-finalization-authorization-boundary.ts";

import type { ProductionSchedulerRuntimeFinalizationConsumerResult } from "./production-scheduler-runtime-finalization-consumer.ts";

const consumedFinalizationRequest: ProductionSchedulerRuntimeFinalizationConsumerResult = {

  ok: true,

  consumer: "production_scheduler_runtime_finalization_consumer",

  scheduler_runtime_finalization_consumed: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime finalization consumer success"],

};

test("scheduler runtime finalization authorization boundary authorizes only runtime finalization transition", () => {

  const result = authorizeSchedulerRuntimeFinalizationTransition({

    production_scheduler_runtime_finalization_consumer:

      consumedFinalizationRequest,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_finalization_transition_authorized, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization authorization boundary fails closed when runtime finalization was not consumed", () => {

  const result = authorizeSchedulerRuntimeFinalizationTransition({

    production_scheduler_runtime_finalization_consumer: {

      ok: false,

      consumer: "production_scheduler_runtime_finalization_consumer",

      scheduler_runtime_finalization_consumed: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: ["test scheduler runtime finalization consumer failure"],

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_finalization_transition_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

