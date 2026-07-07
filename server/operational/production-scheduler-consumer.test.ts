
import test from "node:test";

import assert from "node:assert/strict";

import { consumeSchedulerEntryPointForProduction } from "./production-scheduler-consumer";

import type { SchedulerEntryPointResult } from "./scheduler-entry-point";

const readySchedulerEntryPoint: SchedulerEntryPointResult = {

  ok: true,

  entry_point: "scheduler_entry_point",

  scheduler_request_ready: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler entry point success"],

};

test("production scheduler consumer accepts scheduler entry point readiness without authorizing scheduling", () => {

  const result = consumeSchedulerEntryPointForProduction({

    scheduler_entry_point: readySchedulerEntryPoint,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_consumer_ready, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production scheduler consumer fails closed when scheduler entry point is not ready", () => {

  const result = consumeSchedulerEntryPointForProduction({

    scheduler_entry_point: {

            ok: false,

            entry_point: "scheduler_entry_point",

            scheduler_request_ready: false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: ["test scheduler entry point failure"],

          },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_consumer_ready, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

