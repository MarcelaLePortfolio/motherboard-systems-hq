
import test from "node:test";

import assert from "node:assert/strict";

import { invokeSchedulerExecutionEntryPoint } from "./scheduler-execution-entry-point";

import type { SchedulerExecutionReadinessBoundaryResult } from "./scheduler-execution-readiness-boundary";

const readyExecutionBoundary: SchedulerExecutionReadinessBoundaryResult = {

  ok: true,

  boundary: "scheduler_execution_readiness",

  scheduler_execution_ready: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler execution readiness success"],

};

test("scheduler execution entry point accepts readiness without authorizing scheduler execution", () => {

  const result = invokeSchedulerExecutionEntryPoint({

    scheduler_execution_readiness: readyExecutionBoundary,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_execution_request_ready, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler execution entry point fails closed when execution readiness is absent", () => {

  const result = invokeSchedulerExecutionEntryPoint({

    scheduler_execution_readiness: {

            ok: false,

            boundary: "scheduler_execution_readiness",

            scheduler_execution_ready: false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: ["test scheduler execution readiness failure"],

          },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_execution_request_ready, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

