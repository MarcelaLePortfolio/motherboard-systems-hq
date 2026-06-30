
import type { SchedulerRuntimeFinalizationContractResult } from "./scheduler-runtime-finalization-contract.ts";

export type ProductionSchedulerRuntimeFinalizationContractConsumerInput = {

  scheduler_runtime_finalization_contract: SchedulerRuntimeFinalizationContractResult;

};

export type ProductionSchedulerRuntimeFinalizationContractConsumerResult =

  | {

      ok: true;

      consumer: "production_scheduler_runtime_finalization_contract_consumer";

      scheduler_runtime_finalization_contract_consumed: true;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    }

  | {

      ok: false;

      consumer: "production_scheduler_runtime_finalization_contract_consumer";

      scheduler_runtime_finalization_contract_consumed: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function consumeSchedulerRuntimeFinalizationContractForProduction(

  input: ProductionSchedulerRuntimeFinalizationContractConsumerInput,

): ProductionSchedulerRuntimeFinalizationContractConsumerResult {

  const finalizationContract = input.scheduler_runtime_finalization_contract;

  if (

    !finalizationContract.ok ||

    !finalizationContract.scheduler_runtime_finalization_contract_ready

  ) {

    return {

      ok: false,

      consumer: "production_scheduler_runtime_finalization_contract_consumer",

      scheduler_runtime_finalization_contract_consumed: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Production Scheduler Runtime Finalization Contract Consumer failed closed because Scheduler Runtime Finalization Contract was not ready.",

      ],

    };

  }

  return {

    ok: true,

    consumer: "production_scheduler_runtime_finalization_contract_consumer",

    scheduler_runtime_finalization_contract_consumed: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Production Scheduler Runtime Finalization Contract Consumer consumed Scheduler Runtime Finalization Contract without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

