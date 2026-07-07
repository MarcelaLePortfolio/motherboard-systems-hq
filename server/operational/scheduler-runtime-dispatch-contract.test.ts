
import test from "node:test";

import assert from "node:assert/strict";

import { buildSchedulerRuntimeDispatchContract } from "./scheduler-runtime-dispatch-contract";

import type { SchedulerRuntimeDispatchAuthorizationBoundaryResult } from "./scheduler-runtime-dispatch-authorization-boundary";

const authorizedRuntimeDispatchTransition: SchedulerRuntimeDispatchAuthorizationBoundaryResult = {

  ok: true,

  boundary: "scheduler_runtime_dispatch_authorization",

  scheduler_runtime_dispatch_transition_authorized: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime dispatch authorization success"],

};

test("scheduler runtime dispatch contract builds dispatch handoff without authorizing scheduler runtime dispatch", () => {

  const result = buildSchedulerRuntimeDispatchContract({

    scheduler_runtime_dispatch_authorization: authorizedRuntimeDispatchTransition,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_dispatch_contract_ready, true);

  assert.equal(result.scheduler_runtime_dispatch_transition_authorized, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime dispatch contract fails closed without runtime dispatch transition authorization", () => {

  const result = buildSchedulerRuntimeDispatchContract({

    scheduler_runtime_dispatch_authorization: {

            ok: false,

            boundary: "scheduler_runtime_dispatch_authorization",

            scheduler_runtime_dispatch_transition_authorized: false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: ["test scheduler runtime dispatch authorization failure"],

          },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_dispatch_contract_ready, false);

  assert.equal(result.scheduler_runtime_dispatch_transition_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

