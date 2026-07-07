
import test from "node:test";

import assert from "node:assert/strict";

import { authorizeSchedulerRuntimeDispatchTransition } from "./scheduler-runtime-dispatch-authorization-boundary";

import type { ProductionSchedulerRuntimeDispatchConsumerResult } from "./production-scheduler-runtime-dispatch-consumer";

const consumedRuntimeDispatch: ProductionSchedulerRuntimeDispatchConsumerResult = {

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

test("scheduler runtime dispatch authorization boundary authorizes only runtime dispatch transition", () => {

  const result = authorizeSchedulerRuntimeDispatchTransition({

    production_scheduler_runtime_dispatch_consumer: consumedRuntimeDispatch,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_dispatch_transition_authorized, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime dispatch authorization boundary fails closed when runtime dispatch was not consumed", () => {

  const result = authorizeSchedulerRuntimeDispatchTransition({

    production_scheduler_runtime_dispatch_consumer: {

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

          },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_dispatch_transition_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

