
import test from "node:test";

import assert from "node:assert/strict";

import { consumeSchedulerRuntimeDispatchContractForProduction } from "./production-scheduler-runtime-dispatch-contract-consumer.ts";

import type { SchedulerRuntimeDispatchContractResult } from "./scheduler-runtime-dispatch-contract.ts";

const readyDispatchContract: SchedulerRuntimeDispatchContractResult = {

  ok: true,

  contract: "scheduler_runtime_dispatch_contract",

  scheduler_runtime_dispatch_contract_ready: true,

  scheduler_runtime_dispatch_transition_authorized: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime dispatch contract success"],

};

test("production scheduler runtime dispatch contract consumer consumes dispatch contract without authorizing scheduler runtime dispatch", () => {

  const result = consumeSchedulerRuntimeDispatchContractForProduction({

    scheduler_runtime_dispatch_contract: readyDispatchContract,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_dispatch_contract_consumed, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production scheduler runtime dispatch contract consumer fails closed when dispatch contract is not ready", () => {

  const result = consumeSchedulerRuntimeDispatchContractForProduction({

    scheduler_runtime_dispatch_contract: {

      ok: false,

      contract: "scheduler_runtime_dispatch_contract",

      scheduler_runtime_dispatch_contract_ready: false,

      scheduler_runtime_dispatch_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: ["test scheduler runtime dispatch contract failure"],

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_dispatch_contract_consumed, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

