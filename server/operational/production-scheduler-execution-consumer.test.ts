
import test from "node:test";

import assert from "node:assert/strict";

import { consumeSchedulerExecutionEntryPointForProduction } from "./production-scheduler-execution-consumer.ts";

import type { SchedulerExecutionEntryPointResult } from "./scheduler-execution-entry-point.ts";

const readyExecutionEntryPoint: SchedulerExecutionEntryPointResult = {

  ok: true,

  entry_point: "scheduler_execution_entry_point",

  scheduler_execution_request_ready: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler execution entry point success"],

};

test("production scheduler execution consumer consumes execution entry point without authorizing scheduler execution", () => {

  const result = consumeSchedulerExecutionEntryPointForProduction({

    scheduler_execution_entry_point: readyExecutionEntryPoint,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_execution_consumed, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production scheduler execution consumer fails closed when execution entry point is not ready", () => {

  const result = consumeSchedulerExecutionEntryPointForProduction({

    scheduler_execution_entry_point: {

      ok: false,

      entry_point: "scheduler_execution_entry_point",

      scheduler_execution_request_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: ["test scheduler execution entry point failure"],

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_execution_consumed, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

