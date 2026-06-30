
import test from "node:test";

import assert from "node:assert/strict";

import { invokeSchedulerRuntimeEntryPoint } from "./scheduler-runtime-entry-point.ts";

import type { SchedulerRuntimeBoundaryResult } from "./scheduler-runtime-boundary.ts";

const readyRuntimeBoundary: SchedulerRuntimeBoundaryResult = {

  ok: true,

  boundary: "scheduler_runtime",

  scheduler_runtime_ready: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime boundary success"],

};

test("scheduler runtime entry point accepts runtime readiness without authorizing scheduler runtime", () => {

  const result = invokeSchedulerRuntimeEntryPoint({

    scheduler_runtime_boundary: readyRuntimeBoundary,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_request_ready, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime entry point fails closed when runtime readiness is absent", () => {

  const result = invokeSchedulerRuntimeEntryPoint({

    scheduler_runtime_boundary: {

      ok: false,

      boundary: "scheduler_runtime",

      scheduler_runtime_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: ["test scheduler runtime boundary failure"],

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_request_ready, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

