
import test from "node:test";

import assert from "node:assert/strict";

import { acceptSchedulerRuntimeFinalizationReadinessCompletionReadinessEntryPoint } from "./scheduler-runtime-finalization-readiness-completion-readiness-entry-point.ts";

import type { SchedulerRuntimeFinalizationReadinessCompletionReadinessBoundaryResult } from "./scheduler-runtime-finalization-readiness-completion-readiness-boundary.ts";

const readyCompletionReadiness: SchedulerRuntimeFinalizationReadinessCompletionReadinessBoundaryResult =

  {

    ok: true,

    boundary: "scheduler_runtime_finalization_readiness_completion_readiness",

    scheduler_runtime_finalization_readiness_completion_ready: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "test scheduler runtime finalization readiness completion readiness success",

    ],

  };

test("scheduler runtime finalization readiness completion readiness entry point accepts readiness without authorizing scheduler runtime finalization", () => {

  const result =

    acceptSchedulerRuntimeFinalizationReadinessCompletionReadinessEntryPoint({

      scheduler_runtime_finalization_readiness_completion_readiness:

        readyCompletionReadiness,

    });

  assert.equal(result.ok, true);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_request_ready,

    true,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization readiness completion readiness entry point fails closed when readiness is absent", () => {

  const result =

    acceptSchedulerRuntimeFinalizationReadinessCompletionReadinessEntryPoint({

      scheduler_runtime_finalization_readiness_completion_readiness: {

        ok: false,

        boundary: "scheduler_runtime_finalization_readiness_completion_readiness",

        scheduler_runtime_finalization_readiness_completion_ready: false,

        scheduler_authorized: false,

        routing_authorized: false,

        worker_claim_authorized: false,

        orchestration_authorized: false,

        execution_authorized: false,

        new_authority_introduced: false,

        findings: [

          "test scheduler runtime finalization readiness completion readiness failure",

        ],

      },

    });

  assert.equal(result.ok, false);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_request_ready,

    false,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

