
import test from "node:test";

import assert from "node:assert/strict";

import { invokeSchedulerRuntimeFinalizationReadinessEntryPoint } from "./scheduler-runtime-finalization-readiness-entry-point";

import type { SchedulerRuntimeFinalizationReadinessBoundaryResult } from "./scheduler-runtime-finalization-readiness-boundary";

const readyFinalizationReadinessBoundary: SchedulerRuntimeFinalizationReadinessBoundaryResult = {

  ok: true,

  boundary: "scheduler_runtime_finalization_readiness",

  scheduler_runtime_finalization_ready: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime finalization readiness boundary success"],

};

test("scheduler runtime finalization readiness entry point accepts readiness without authorizing scheduler runtime finalization", () => {

  const result = invokeSchedulerRuntimeFinalizationReadinessEntryPoint({

    scheduler_runtime_finalization_readiness_boundary:

      readyFinalizationReadinessBoundary,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_finalization_readiness_request_ready, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization readiness entry point fails closed when readiness is absent", () => {

  const result = invokeSchedulerRuntimeFinalizationReadinessEntryPoint({

    scheduler_runtime_finalization_readiness_boundary: {

            ok: false,

            boundary: "scheduler_runtime_finalization_readiness",

            scheduler_runtime_finalization_ready: false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: ["test scheduler runtime finalization readiness boundary failure"],

          },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_finalization_readiness_request_ready, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

