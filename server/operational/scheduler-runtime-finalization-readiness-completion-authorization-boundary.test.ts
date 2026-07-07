
import test from "node:test";

import assert from "node:assert/strict";

import { authorizeSchedulerRuntimeFinalizationReadinessCompletionTransition } from "./scheduler-runtime-finalization-readiness-completion-authorization-boundary";

import type { ProductionSchedulerRuntimeFinalizationReadinessCompletionConsumerResult } from "./production-scheduler-runtime-finalization-readiness-completion-consumer";

const consumedCompletionReadiness: ProductionSchedulerRuntimeFinalizationReadinessCompletionConsumerResult = {

  ok: true,

  consumer: "production_scheduler_runtime_finalization_readiness_completion_consumer",

  scheduler_runtime_finalization_readiness_completion_consumed: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime finalization readiness completion consumer success"],

};

test("scheduler runtime finalization readiness completion authorization boundary authorizes only completion transition", () => {

  const result =

    authorizeSchedulerRuntimeFinalizationReadinessCompletionTransition({

      production_scheduler_runtime_finalization_readiness_completion_consumer:

        consumedCompletionReadiness,

    });

  assert.equal(result.ok, true);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_transition_authorized,

    true,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization readiness completion authorization boundary fails closed when completion was not consumed", () => {

  const result =

    authorizeSchedulerRuntimeFinalizationReadinessCompletionTransition({

      production_scheduler_runtime_finalization_readiness_completion_consumer: {

                ok: false,

                consumer: "production_scheduler_runtime_finalization_readiness_completion_consumer",

                scheduler_runtime_finalization_readiness_completion_consumed: false,

                scheduler_authorized: false,

                routing_authorized: false,

                worker_claim_authorized: false,

                orchestration_authorized: false,

                execution_authorized: false,

                new_authority_introduced: false,

                findings: [

                  "test scheduler runtime finalization readiness completion consumer failure",

                ],

              },

    });

  assert.equal(result.ok, false);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_transition_authorized,

    false,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

