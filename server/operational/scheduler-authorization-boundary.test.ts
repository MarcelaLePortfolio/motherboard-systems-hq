
import test from "node:test";

import assert from "node:assert/strict";

import { authorizeSchedulerTransition } from "./scheduler-authorization-boundary";

import type { ProductionSchedulerConsumerResult } from "./production-scheduler-consumer";

const readySchedulerConsumer: ProductionSchedulerConsumerResult = {

  ok: true,

  consumer: "production_scheduler_consumer",

  scheduler_consumer_ready: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler consumer readiness"],

};

test("scheduler authorization boundary authorizes only scheduler transition", () => {

  const result = authorizeSchedulerTransition({

    production_scheduler_consumer: readySchedulerConsumer,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_transition_authorized, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler authorization boundary fails closed without scheduler consumer readiness", () => {

  const result = authorizeSchedulerTransition({

    production_scheduler_consumer: {

            ok: false,

            consumer: "production_scheduler_consumer",

            scheduler_consumer_ready: false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: ["test scheduler consumer failure"],

          },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_transition_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

