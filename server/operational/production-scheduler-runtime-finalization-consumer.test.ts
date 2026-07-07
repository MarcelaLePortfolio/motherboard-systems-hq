
import test from "node:test";

import assert from "node:assert/strict";

import { consumeSchedulerRuntimeFinalizationEntryPointForProduction } from "./production-scheduler-runtime-finalization-consumer";

import type { SchedulerRuntimeFinalizationEntryPointResult } from "./scheduler-runtime-finalization-entry-point";

const readyFinalizationEntryPoint: SchedulerRuntimeFinalizationEntryPointResult = {

  ok: true,

  entry_point: "scheduler_runtime_finalization_entry_point",

  scheduler_runtime_finalization_request_ready: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime finalization entry point success"],

};

test("production scheduler runtime finalization consumer consumes finalization entry point without authorizing scheduler runtime finalization", () => {

  const result = consumeSchedulerRuntimeFinalizationEntryPointForProduction({

    scheduler_runtime_finalization_entry_point: readyFinalizationEntryPoint,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_finalization_consumed, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production scheduler runtime finalization consumer fails closed when finalization entry point is not ready", () => {

  const result = consumeSchedulerRuntimeFinalizationEntryPointForProduction({

    scheduler_runtime_finalization_entry_point: {

            ok: false,

            entry_point: "scheduler_runtime_finalization_entry_point",

            scheduler_runtime_finalization_request_ready: false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: ["test scheduler runtime finalization entry point failure"],

          },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_finalization_consumed, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

