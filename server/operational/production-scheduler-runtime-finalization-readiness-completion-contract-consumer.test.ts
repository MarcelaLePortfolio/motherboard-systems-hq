
import test from "node:test";

import assert from "node:assert/strict";

import { consumeSchedulerRuntimeFinalizationReadinessCompletionContractForProduction } from "./production-scheduler-runtime-finalization-readiness-completion-contract-consumer";

import type { SchedulerRuntimeFinalizationReadinessCompletionContractResult } from "./scheduler-runtime-finalization-readiness-completion-contract";

const readyCompletionContract: SchedulerRuntimeFinalizationReadinessCompletionContractResult =

  {

    ok: true,

    contract: "scheduler_runtime_finalization_readiness_completion_contract",

    scheduler_runtime_finalization_readiness_completion_contract_ready: true,

    scheduler_runtime_finalization_readiness_completion_transition_authorized:

      true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "test scheduler runtime finalization readiness completion contract success",

    ],

  };

test("production scheduler runtime finalization readiness completion contract consumer consumes completion contract without authorizing scheduler runtime finalization", () => {

  const result =

    consumeSchedulerRuntimeFinalizationReadinessCompletionContractForProduction({

      scheduler_runtime_finalization_readiness_completion_contract:

        readyCompletionContract,

    });

  assert.equal(result.ok, true);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_contract_consumed,

    true,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production scheduler runtime finalization readiness completion contract consumer fails closed when completion contract is not ready", () => {

  const result =

    consumeSchedulerRuntimeFinalizationReadinessCompletionContractForProduction({

      scheduler_runtime_finalization_readiness_completion_contract: {

                ok: false,

                contract: "scheduler_runtime_finalization_readiness_completion_contract",

                scheduler_runtime_finalization_readiness_completion_contract_ready:

                  false,

                scheduler_runtime_finalization_readiness_completion_transition_authorized:

                  false,

                scheduler_authorized: false,

                routing_authorized: false,

                worker_claim_authorized: false,

                orchestration_authorized: false,

                execution_authorized: false,

                new_authority_introduced: false,

                findings: [

                  "test scheduler runtime finalization readiness completion contract failure",

                ],

              },

    });

  assert.equal(result.ok, false);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_contract_consumed,

    false,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

