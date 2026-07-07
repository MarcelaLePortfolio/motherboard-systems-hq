
import test from "node:test";

import assert from "node:assert/strict";

import { consumeSchedulerRuntimeFinalizationReadinessEntryPointForProduction } from "./production-scheduler-runtime-finalization-readiness-consumer";

import type { SchedulerRuntimeFinalizationReadinessEntryPointResult } from "./scheduler-runtime-finalization-readiness-entry-point";

const readyFinalizationReadinessEntryPoint: SchedulerRuntimeFinalizationReadinessEntryPointResult = {

  ok: true,

  entry_point: "scheduler_runtime_finalization_readiness_entry_point",

  scheduler_runtime_finalization_readiness_request_ready: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime finalization readiness entry point success"],

};

test("production scheduler runtime finalization readiness consumer consumes readiness entry point without authorizing scheduler runtime finalization", () => {

  const result =

    consumeSchedulerRuntimeFinalizationReadinessEntryPointForProduction({

      scheduler_runtime_finalization_readiness_entry_point:

        readyFinalizationReadinessEntryPoint,

    });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_finalization_readiness_consumed, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production scheduler runtime finalization readiness consumer fails closed when readiness entry point is not ready", () => {

  const result =

    consumeSchedulerRuntimeFinalizationReadinessEntryPointForProduction({

      scheduler_runtime_finalization_readiness_entry_point: {

                ok: false,

                entry_point: "scheduler_runtime_finalization_readiness_entry_point",

                scheduler_runtime_finalization_readiness_request_ready: false,

                scheduler_authorized: false,

                routing_authorized: false,

                worker_claim_authorized: false,

                orchestration_authorized: false,

                execution_authorized: false,

                new_authority_introduced: false,

                findings: ["test scheduler runtime finalization readiness entry point failure"],

              },

    });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_finalization_readiness_consumed, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

