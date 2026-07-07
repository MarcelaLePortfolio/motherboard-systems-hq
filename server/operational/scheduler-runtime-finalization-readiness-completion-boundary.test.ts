
import test from "node:test";

import assert from "node:assert/strict";

import { evaluateSchedulerRuntimeFinalizationReadinessCompletionBoundary } from "./scheduler-runtime-finalization-readiness-completion-boundary";

import type { ProductionSchedulerRuntimeFinalizationReadinessContractConsumerResult } from "./production-scheduler-runtime-finalization-readiness-contract-consumer";

const consumedFinalizationReadinessContract: ProductionSchedulerRuntimeFinalizationReadinessContractConsumerResult = {

  ok: true,

  consumer: "production_scheduler_runtime_finalization_readiness_contract_consumer",

  scheduler_runtime_finalization_readiness_contract_consumed: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime finalization readiness contract consumer success"],

};

test("scheduler runtime finalization readiness completion boundary confirms completion without authorizing scheduler runtime finalization", () => {

  const result = evaluateSchedulerRuntimeFinalizationReadinessCompletionBoundary({

    production_scheduler_runtime_finalization_readiness_contract_consumer:

      consumedFinalizationReadinessContract,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_finalization_readiness_complete, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization readiness completion boundary fails closed when readiness contract was not consumed", () => {

  const result = evaluateSchedulerRuntimeFinalizationReadinessCompletionBoundary({

    production_scheduler_runtime_finalization_readiness_contract_consumer: {

            ok: false,

            consumer: "production_scheduler_runtime_finalization_readiness_contract_consumer",

            scheduler_runtime_finalization_readiness_contract_consumed: false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: ["test scheduler runtime finalization readiness contract consumer failure"],

          },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_finalization_readiness_complete, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

