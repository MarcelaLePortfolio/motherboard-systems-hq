
import test from "node:test";

import assert from "node:assert/strict";

import { consumeSchedulerRuntimeEntryPointForProduction } from "./production-scheduler-runtime-consumer.ts";

import type { SchedulerRuntimeEntryPointResult } from "./scheduler-runtime-entry-point.ts";

const readyRuntimeEntryPoint: SchedulerRuntimeEntryPointResult = {

  ok: true,

  entry_point: "scheduler_runtime_entry_point",

  scheduler_runtime_request_ready: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime entry point success"],

};

test("production scheduler runtime consumer consumes runtime entry point without authorizing scheduler runtime", () => {

  const result = consumeSchedulerRuntimeEntryPointForProduction({

    scheduler_runtime_entry_point: readyRuntimeEntryPoint,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_consumed, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production scheduler runtime consumer fails closed when runtime entry point is not ready", () => {

  const result = consumeSchedulerRuntimeEntryPointForProduction({

    scheduler_runtime_entry_point: {

      ok: false,

      entry_point: "scheduler_runtime_entry_point",

      scheduler_runtime_request_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: ["test scheduler runtime entry point failure"],

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_consumed, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

