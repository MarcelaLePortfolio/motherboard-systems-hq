
import test from "node:test";

import assert from "node:assert/strict";

import { consumeSchedulerDispatchContractForProduction } from "./production-scheduler-dispatch-consumer.ts";

import type { SchedulerDispatchContractResult } from "./scheduler-dispatch-contract.ts";

const readyDispatchContract: SchedulerDispatchContractResult = {

  ok: true,

  contract: "scheduler_dispatch_contract",

  scheduler_dispatch_ready: true,

  scheduler_transition_authorized: true,

  envelope_id: "env-production-scheduler-dispatch-consumer",

  package_id: "pkg-production-scheduler-dispatch-consumer",

  package_version: 1,

  assigned_department: "engineering",

  required_capabilities_snapshot: "engineering",

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler dispatch contract success"],

};

test("production scheduler dispatch consumer consumes dispatch contract without authorizing scheduler", () => {

  const result = consumeSchedulerDispatchContractForProduction({

    scheduler_dispatch_contract: readyDispatchContract,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_dispatch_consumed, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production scheduler dispatch consumer fails closed when dispatch contract is not ready", () => {

  const result = consumeSchedulerDispatchContractForProduction({

    scheduler_dispatch_contract: {

      ok: false,

      contract: "scheduler_dispatch_contract",

      scheduler_dispatch_ready: false,

      scheduler_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: ["test scheduler dispatch contract failure"],

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_dispatch_consumed, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

