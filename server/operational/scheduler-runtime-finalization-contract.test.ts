
import test from "node:test";

import assert from "node:assert/strict";

import { buildSchedulerRuntimeFinalizationContract } from "./scheduler-runtime-finalization-contract.ts";

import type { SchedulerRuntimeFinalizationAuthorizationBoundaryResult } from "./scheduler-runtime-finalization-authorization-boundary.ts";

const authorizedRuntimeFinalizationTransition: SchedulerRuntimeFinalizationAuthorizationBoundaryResult = {

  ok: true,

  boundary: "scheduler_runtime_finalization_authorization",

  scheduler_runtime_finalization_transition_authorized: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime finalization authorization success"],

};

test("scheduler runtime finalization contract builds finalization handoff without authorizing scheduler runtime finalization", () => {

  const result = buildSchedulerRuntimeFinalizationContract({

    scheduler_runtime_finalization_authorization:

      authorizedRuntimeFinalizationTransition,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_finalization_contract_ready, true);

  assert.equal(result.scheduler_runtime_finalization_transition_authorized, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization contract fails closed without runtime finalization transition authorization", () => {

  const result = buildSchedulerRuntimeFinalizationContract({

    scheduler_runtime_finalization_authorization: {

      ok: false,

      boundary: "scheduler_runtime_finalization_authorization",

      scheduler_runtime_finalization_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: ["test scheduler runtime finalization authorization failure"],

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_finalization_contract_ready, false);

  assert.equal(result.scheduler_runtime_finalization_transition_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

