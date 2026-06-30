
import test from "node:test";

import assert from "node:assert/strict";

import { consumeSchedulerRuntimeDispatchEntryPointForProduction } from "./production-scheduler-runtime-dispatch-consumer.ts";

import type { SchedulerRuntimeDispatchEntryPointResult } from "./scheduler-runtime-dispatch-entry-point.ts";

const readyDispatchEntryPoint: SchedulerRuntimeDispatchEntryPointResult = {

  ok: true,

  entry_point: "scheduler_runtime_dispatch_entry_point",

  scheduler_runtime_dispatch_request_ready: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime dispatch entry point success"],

};

test("production scheduler runtime dispatch consumer consumes dispatch entry point without authorizing scheduler runtime dispatch", () => {

  const result = consumeSchedulerRuntimeDispatchEntryPointForProduction({

    scheduler_runtime_dispatch_entry_point: readyDispatchEntryPoint,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_dispatch_consumed, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production scheduler runtime dispatch consumer fails closed when dispatch entry point is not ready", () => {

  const result = consumeSchedulerRuntimeDispatchEntryPointForProduction({

    scheduler_runtime_dispatch_entry_point: {

      ok: false,

      entry_point: "scheduler_runtime_dispatch_entry_point",

      scheduler_runtime_dispatch_request_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: ["test scheduler runtime dispatch entry point failure"],

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_dispatch_consumed, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

