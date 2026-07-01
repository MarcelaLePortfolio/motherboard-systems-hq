
import test from "node:test";

import assert from "node:assert/strict";

import { consumeSchedulerRuntimeFinalizationReadinessCompletionReadinessContractForProduction } from "./production-scheduler-runtime-finalization-readiness-completion-readiness-contract-consumer.ts";

import type { SchedulerRuntimeFinalizationReadinessCompletionReadinessContractResult } from "./scheduler-runtime-finalization-readiness-completion-readiness-contract.ts";

const readyReadinessCompletionReadinessContract: SchedulerRuntimeFinalizationReadinessCompletionReadinessContractResult =

  {

    ok: true,

    contract:

      "scheduler_runtime_finalization_readiness_completion_readiness_contract",

    scheduler_runtime_finalization_readiness_completion_readiness_contract_ready:

      true,

    scheduler_runtime_finalization_readiness_completion_readiness_transition_authorized:

      true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "test scheduler runtime finalization readiness completion readiness contract success",

    ],

  };

test("production scheduler runtime finalization readiness completion readiness contract consumer consumes readiness contract without authorizing scheduler runtime finalization", () => {

  const result =

    consumeSchedulerRuntimeFinalizationReadinessCompletionReadinessContractForProduction({

      scheduler_runtime_finalization_readiness_completion_readiness_contract:

        readyReadinessCompletionReadinessContract,

    });

  assert.equal(result.ok, true);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_contract_consumed,

    true,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production scheduler runtime finalization readiness completion readiness contract consumer fails closed when readiness contract is not ready", () => {

  const result =

    consumeSchedulerRuntimeFinalizationReadinessCompletionReadinessContractForProduction({

      scheduler_runtime_finalization_readiness_completion_readiness_contract: {

        ok: false,

        contract:

          "scheduler_runtime_finalization_readiness_completion_readiness_contract",

        scheduler_runtime_finalization_readiness_completion_readiness_contract_ready:

          false,

        scheduler_runtime_finalization_readiness_completion_readiness_transition_authorized:

          false,

        scheduler_authorized: false,

        routing_authorized: false,

        worker_claim_authorized: false,

        orchestration_authorized: false,

        execution_authorized: false,

        new_authority_introduced: false,

        findings: [

          "test scheduler runtime finalization readiness completion readiness contract failure",

        ],

      },

    });

  assert.equal(result.ok, false);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_contract_consumed,

    false,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

