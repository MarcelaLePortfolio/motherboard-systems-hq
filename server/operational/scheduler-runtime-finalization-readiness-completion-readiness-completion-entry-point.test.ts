
import test from "node:test";

import assert from "node:assert/strict";

import { acceptSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionEntryPoint } from "./scheduler-runtime-finalization-readiness-completion-readiness-completion-entry-point.ts";

import type { SchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionBoundaryResult } from "./scheduler-runtime-finalization-readiness-completion-readiness-completion-boundary.ts";

const completedReadinessCompletionReadiness: SchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionBoundaryResult =

  {

    ok: true,

    boundary:

      "scheduler_runtime_finalization_readiness_completion_readiness_completion",

    scheduler_runtime_finalization_readiness_completion_readiness_complete: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "test scheduler runtime finalization readiness completion readiness completion success",

    ],

  };

test("scheduler runtime finalization readiness completion readiness completion entry point accepts completion without authorizing scheduler runtime finalization", () => {

  const result =

    acceptSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionEntryPoint(

      {

        scheduler_runtime_finalization_readiness_completion_readiness_completion:

          completedReadinessCompletionReadiness,

      },

    );

  assert.equal(result.ok, true);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_request_ready,

    true,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization readiness completion readiness completion entry point fails closed when completion is absent", () => {

  const result =

    acceptSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionEntryPoint(

      {

        scheduler_runtime_finalization_readiness_completion_readiness_completion:

          {

            ok: false,

            boundary:

              "scheduler_runtime_finalization_readiness_completion_readiness_completion",

            scheduler_runtime_finalization_readiness_completion_readiness_complete:

              false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: [

              "test scheduler runtime finalization readiness completion readiness completion failure",

            ],

          },

      },

    );

  assert.equal(result.ok, false);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_request_ready,

    false,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

