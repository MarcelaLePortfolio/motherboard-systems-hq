
import test from "node:test";

import assert from "node:assert/strict";

import { consumeSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionForProduction } from "./production-scheduler-runtime-finalization-readiness-completion-readiness-completion-consumer.ts";

import type { SchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionEntryPointResult } from "./scheduler-runtime-finalization-readiness-completion-readiness-completion-entry-point.ts";

const readyCompletionEntryPoint: SchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionEntryPointResult =

  {

    ok: true,

    entry_point:

      "scheduler_runtime_finalization_readiness_completion_readiness_completion_entry_point",

    scheduler_runtime_finalization_readiness_completion_readiness_completion_request_ready:

      true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "test scheduler runtime finalization readiness completion readiness completion entry point success",

    ],

  };

test("production scheduler runtime finalization readiness completion readiness completion consumer consumes completion entry point without authorizing scheduler runtime finalization", () => {

  const result =

    consumeSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionForProduction(

      {

        scheduler_runtime_finalization_readiness_completion_readiness_completion_entry_point:

          readyCompletionEntryPoint,

      },

    );

  assert.equal(result.ok, true);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_consumed,

    true,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production scheduler runtime finalization readiness completion readiness completion consumer fails closed when completion entry point is not ready", () => {

  const result =

    consumeSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionForProduction(

      {

        scheduler_runtime_finalization_readiness_completion_readiness_completion_entry_point:

          {

            ok: false,

            entry_point:

              "scheduler_runtime_finalization_readiness_completion_readiness_completion_entry_point",

            scheduler_runtime_finalization_readiness_completion_readiness_completion_request_ready:

              false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: [

              "test scheduler runtime finalization readiness completion readiness completion entry point failure",

            ],

          },

      },

    );

  assert.equal(result.ok, false);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_consumed,

    false,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

