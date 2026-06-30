
import test from "node:test";

import assert from "node:assert/strict";

import { invokeSchedulerRuntimeFinalizationEntryPoint } from "./scheduler-runtime-finalization-entry-point.ts";

import type { SchedulerRuntimeFinalizationBoundaryResult } from "./scheduler-runtime-finalization-boundary.ts";

const authorizedFinalizationBoundary: SchedulerRuntimeFinalizationBoundaryResult = {

  ok: true,

  boundary: "scheduler_runtime_finalization",

  scheduler_runtime_finalization_transition_authorized: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime finalization boundary success"],

};

test("scheduler runtime finalization entry point accepts finalization readiness without authorizing scheduler runtime finalization", () => {

  const result = invokeSchedulerRuntimeFinalizationEntryPoint({

    scheduler_runtime_finalization_boundary: authorizedFinalizationBoundary,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_finalization_request_ready, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization entry point fails closed when finalization readiness is absent", () => {

  const result = invokeSchedulerRuntimeFinalizationEntryPoint({

    scheduler_runtime_finalization_boundary: {

      ok: false,

      boundary: "scheduler_runtime_finalization",

      scheduler_runtime_finalization_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: ["test scheduler runtime finalization boundary failure"],

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_finalization_request_ready, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

