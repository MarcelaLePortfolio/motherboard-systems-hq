
import test from "node:test";

import assert from "node:assert/strict";

import { invokeSchedulerRuntimeDispatchEntryPoint } from "./scheduler-runtime-dispatch-entry-point.ts";

import type { SchedulerRuntimeDispatchBoundaryResult } from "./scheduler-runtime-dispatch-boundary.ts";

const readyDispatchBoundary: SchedulerRuntimeDispatchBoundaryResult = {

  ok: true,

  boundary: "scheduler_runtime_dispatch",

  scheduler_runtime_dispatch_ready: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime dispatch boundary success"],

};

test("scheduler runtime dispatch entry point accepts dispatch readiness without authorizing scheduler runtime dispatch", () => {

  const result = invokeSchedulerRuntimeDispatchEntryPoint({

    scheduler_runtime_dispatch_boundary: readyDispatchBoundary,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_dispatch_request_ready, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime dispatch entry point fails closed when dispatch readiness is absent", () => {

  const result = invokeSchedulerRuntimeDispatchEntryPoint({

    scheduler_runtime_dispatch_boundary: {

      ok: false,

      boundary: "scheduler_runtime_dispatch",

      scheduler_runtime_dispatch_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: ["test scheduler runtime dispatch boundary failure"],

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_dispatch_request_ready, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

