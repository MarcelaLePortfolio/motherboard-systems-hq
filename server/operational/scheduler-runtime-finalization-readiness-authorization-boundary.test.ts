
import test from "node:test";

import assert from "node:assert/strict";

import { authorizeSchedulerRuntimeFinalizationReadinessTransition } from "./scheduler-runtime-finalization-readiness-authorization-boundary";

import type { ProductionSchedulerRuntimeFinalizationReadinessConsumerResult } from "./production-scheduler-runtime-finalization-readiness-consumer";

const consumedFinalizationReadinessRequest: ProductionSchedulerRuntimeFinalizationReadinessConsumerResult = {

  ok: true,

  consumer: "production_scheduler_runtime_finalization_readiness_consumer",

  scheduler_runtime_finalization_readiness_consumed: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime finalization readiness consumer success"],

};

test("scheduler runtime finalization readiness authorization boundary authorizes only runtime finalization readiness transition", () => {

  const result = authorizeSchedulerRuntimeFinalizationReadinessTransition({

    production_scheduler_runtime_finalization_readiness_consumer:

      consumedFinalizationReadinessRequest,

  });

  assert.equal(result.ok, true);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_transition_authorized,

    true,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization readiness authorization boundary fails closed when runtime finalization readiness was not consumed", () => {

  const result = authorizeSchedulerRuntimeFinalizationReadinessTransition({

    production_scheduler_runtime_finalization_readiness_consumer: {

            ok: false,

            consumer: "production_scheduler_runtime_finalization_readiness_consumer",

            scheduler_runtime_finalization_readiness_consumed: false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: ["test scheduler runtime finalization readiness consumer failure"],

          },

  });

  assert.equal(result.ok, false);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_transition_authorized,

    false,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

