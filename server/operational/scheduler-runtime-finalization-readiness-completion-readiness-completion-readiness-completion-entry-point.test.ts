
import test from "node:test";

import assert from "node:assert/strict";

import { enterSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletion } from "./scheduler-runtime-finalization-readiness-completion-readiness-completion-readiness-completion-entry-point.ts";

import type { SchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionBoundaryResult } from "./scheduler-runtime-finalization-readiness-completion-readiness-completion-readiness-completion-boundary.ts";

const completedBoundary: SchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionBoundaryResult =

  {

    ok: true,

    boundary:

      "scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion",

    scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_complete:

      true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "test scheduler runtime finalization readiness completion readiness completion readiness completion boundary success",

    ],

  };

test("scheduler runtime finalization readiness completion readiness completion readiness completion entry point accepts completion without authorizing scheduler runtime finalization", () => {

  const result =

    enterSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletion(

      {

        scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_boundary:

          completedBoundary,

      },

    );

  assert.equal(result.ok, true);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_request_ready,

    true,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization readiness completion readiness completion readiness completion entry point fails closed when completion is absent", () => {

  const result =

    enterSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletion(

      {

        scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_boundary:

          {

            ok: false,

            boundary:

              "scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion",

            scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_complete:

              false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: [

              "test scheduler runtime finalization readiness completion readiness completion readiness completion boundary failure",

            ],

          },

      },

    );

  assert.equal(result.ok, false);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_request_ready,

    false,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

