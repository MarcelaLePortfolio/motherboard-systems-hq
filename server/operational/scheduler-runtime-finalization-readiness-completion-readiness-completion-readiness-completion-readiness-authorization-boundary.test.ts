
import test from "node:test";

import assert from "node:assert/strict";

import { authorizeSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionReadinessTransition } from "./scheduler-runtime-finalization-readiness-completion-readiness-completion-readiness-completion-readiness-authorization-boundary.ts";

import type { ProductionSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionReadinessConsumerResult } from "./production-scheduler-runtime-finalization-readiness-completion-readiness-completion-readiness-completion-readiness-consumer.ts";

const consumedReadiness: ProductionSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionReadinessConsumerResult =

  {

    ok: true,

    consumer:

      "production_scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_consumer",

    scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_consumed:

      true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "test scheduler runtime finalization readiness completion readiness completion readiness completion readiness consumer success",

    ],

  };

test("scheduler runtime finalization readiness completion readiness completion readiness completion readiness authorization boundary authorizes only readiness transition", () => {

  const result =

    authorizeSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionReadinessTransition(

      {

        production_scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_consumer:

          consumedReadiness,

      },

    );

  assert.equal(result.ok, true);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_transition_authorized,

    true,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization readiness completion readiness completion readiness completion readiness authorization boundary fails closed when readiness was not consumed", () => {

  const result =

    authorizeSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionReadinessTransition(

      {

        production_scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_consumer:

          {

            ok: false,

            consumer:

              "production_scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_consumer",

            scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_consumed:

              false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: [

              "test scheduler runtime finalization readiness completion readiness completion readiness completion readiness consumer failure",

            ],

          },

      },

    );

  assert.equal(result.ok, false);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_transition_authorized,

    false,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

