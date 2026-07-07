
import test from "node:test";

import assert from "node:assert/strict";

import { evaluateSchedulerRuntimeFinalizationReadinessBoundary } from "./scheduler-runtime-finalization-readiness-boundary";

import type { ProductionSchedulerRuntimeFinalizationContractConsumerResult } from "./production-scheduler-runtime-finalization-contract-consumer";

const consumedFinalizationContract: ProductionSchedulerRuntimeFinalizationContractConsumerResult = {

  ok: true,

  consumer: "production_scheduler_runtime_finalization_contract_consumer",

  scheduler_runtime_finalization_contract_consumed: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime finalization contract consumer success"],

};

test("scheduler runtime finalization readiness boundary confirms readiness without authorizing scheduler runtime finalization", () => {

  const result = evaluateSchedulerRuntimeFinalizationReadinessBoundary({

    production_scheduler_runtime_finalization_contract_consumer:

      consumedFinalizationContract,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_finalization_ready, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization readiness boundary fails closed when finalization contract was not consumed", () => {

  const result = evaluateSchedulerRuntimeFinalizationReadinessBoundary({

    production_scheduler_runtime_finalization_contract_consumer: {

            ok: false,

            consumer: "production_scheduler_runtime_finalization_contract_consumer",

            scheduler_runtime_finalization_contract_consumed: false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: ["test scheduler runtime finalization contract consumer failure"],

          },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_finalization_ready, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

