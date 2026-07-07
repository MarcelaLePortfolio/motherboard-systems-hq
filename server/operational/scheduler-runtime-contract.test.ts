
import test from "node:test";

import assert from "node:assert/strict";

import { buildSchedulerRuntimeContract } from "./scheduler-runtime-contract";

import type { SchedulerRuntimeAuthorizationBoundaryResult } from "./scheduler-runtime-authorization-boundary";

const authorizedRuntimeTransition: SchedulerRuntimeAuthorizationBoundaryResult = {

  ok: true,

  boundary: "scheduler_runtime_authorization",

  scheduler_runtime_transition_authorized: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime authorization success"],

};

test("scheduler runtime contract builds runtime handoff without authorizing scheduler runtime", () => {

  const result = buildSchedulerRuntimeContract({

    scheduler_runtime_authorization: authorizedRuntimeTransition,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_contract_ready, true);

  assert.equal(result.scheduler_runtime_transition_authorized, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime contract fails closed without runtime transition authorization", () => {

  const result = buildSchedulerRuntimeContract({

    scheduler_runtime_authorization: {

            ok: false,

            boundary: "scheduler_runtime_authorization",

            scheduler_runtime_transition_authorized: false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: ["test scheduler runtime authorization failure"],

          },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_contract_ready, false);

  assert.equal(result.scheduler_runtime_transition_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

