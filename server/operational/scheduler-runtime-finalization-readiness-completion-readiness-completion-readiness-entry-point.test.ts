
import test from "node:test";

import assert from "node:assert/strict";

import { enterSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadiness } from "./scheduler-runtime-finalization-readiness-completion-readiness-completion-readiness-entry-point.ts";

import type { SchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessBoundaryResult } from "./scheduler-runtime-finalization-readiness-completion-readiness-completion-readiness-boundary.ts";

const readyBoundary: SchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessBoundaryResult =

  {

    ok: true,

    boundary:

      "scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness",

    scheduler_runtime_finalization_readiness_completion_readiness_completion_ready:

      true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "test scheduler runtime finalization readiness completion readiness completion readiness boundary success",

    ],

  };

test("scheduler runtime finalization readiness completion readiness completion readiness entry point accepts readiness without authorizing scheduler runtime finalization", () => {

  const result =

    enterSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadiness(

      {

        scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_boundary:

          readyBoundary,

      },

    );

  assert.equal(result.ok, true);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_request_ready,

    true,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization readiness completion readiness completion readiness entry point fails closed when readiness is absent", () => {

  const result =

    enterSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadiness(

      {

        scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_boundary:

          {

            ok: false,

            boundary:

              "scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness",

            scheduler_runtime_finalization_readiness_completion_readiness_completion_ready:

              false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: [

              "test scheduler runtime finalization readiness completion readiness completion readiness boundary failure",

            ],

          },

      },

    );

  assert.equal(result.ok, false);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_request_ready,

    false,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

