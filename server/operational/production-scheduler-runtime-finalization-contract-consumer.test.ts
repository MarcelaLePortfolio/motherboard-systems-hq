
import test from "node:test";

import assert from "node:assert/strict";

import { consumeSchedulerRuntimeFinalizationContractForProduction } from "./production-scheduler-runtime-finalization-contract-consumer.ts";

import type { SchedulerRuntimeFinalizationContractResult } from "./scheduler-runtime-finalization-contract.ts";

const readyFinalizationContract: SchedulerRuntimeFinalizationContractResult = {

  ok: true,

  contract: "scheduler_runtime_finalization_contract",

  scheduler_runtime_finalization_contract_ready: true,

  scheduler_runtime_finalization_transition_authorized: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime finalization contract success"],

};

test("production scheduler runtime finalization contract consumer consumes finalization contract without authorizing scheduler runtime finalization", () => {

  const result = consumeSchedulerRuntimeFinalizationContractForProduction({

    scheduler_runtime_finalization_contract: readyFinalizationContract,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_finalization_contract_consumed, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production scheduler runtime finalization contract consumer fails closed when finalization contract is not ready", () => {

  const result = consumeSchedulerRuntimeFinalizationContractForProduction({

    scheduler_runtime_finalization_contract: {

      ok: false,

      contract: "scheduler_runtime_finalization_contract",

      scheduler_runtime_finalization_contract_ready: false,

      scheduler_runtime_finalization_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: ["test scheduler runtime finalization contract failure"],

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_finalization_contract_consumed, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

