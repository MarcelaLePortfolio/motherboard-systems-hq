
import test from "node:test";

import assert from "node:assert/strict";

import { consumeSchedulerRuntimeContractForProduction } from "./production-scheduler-runtime-contract-consumer";

import type { SchedulerRuntimeContractResult } from "./scheduler-runtime-contract";

const readyRuntimeContract: SchedulerRuntimeContractResult = {

  ok: true,

  contract: "scheduler_runtime_contract",

  scheduler_runtime_contract_ready: true,

  scheduler_runtime_transition_authorized: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime contract success"],

};

test("production scheduler runtime contract consumer consumes runtime contract without authorizing scheduler runtime", () => {

  const result = consumeSchedulerRuntimeContractForProduction({

    scheduler_runtime_contract: readyRuntimeContract,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_contract_consumed, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production scheduler runtime contract consumer fails closed when runtime contract is not ready", () => {

  const result = consumeSchedulerRuntimeContractForProduction({

    scheduler_runtime_contract: {

            ok: false,

            contract: "scheduler_runtime_contract",

            scheduler_runtime_contract_ready: false,

            scheduler_runtime_transition_authorized: false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: ["test scheduler runtime contract failure"],

          },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_contract_consumed, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

