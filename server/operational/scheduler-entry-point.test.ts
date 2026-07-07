
import test from "node:test";

import assert from "node:assert/strict";

import { invokeSchedulerEntryPoint } from "./scheduler-entry-point";

import type { SchedulerReadinessBoundaryResult } from "./scheduler-readiness-boundary";

const readySchedulerBoundary: SchedulerReadinessBoundaryResult = {

  ok: true,

  boundary: "scheduler_readiness",

  scheduler_ready: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler readiness success"],

};

test("scheduler entry point accepts readiness without authorizing scheduler", () => {

  const result = invokeSchedulerEntryPoint({

    scheduler_readiness: readySchedulerBoundary,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_request_ready, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler entry point fails closed when readiness is absent", () => {

  const result = invokeSchedulerEntryPoint({

    scheduler_readiness: {

            ok: false,

            boundary: "scheduler_readiness",

            scheduler_ready: false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: ["test scheduler readiness failure"],

          },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_request_ready, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

