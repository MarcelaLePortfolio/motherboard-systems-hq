
import type { SchedulerRuntimeFinalizationReadinessContractResult } from "./scheduler-runtime-finalization-readiness-contract.ts";

export type ProductionSchedulerRuntimeFinalizationReadinessContractConsumerInput = {

  scheduler_runtime_finalization_readiness_contract: SchedulerRuntimeFinalizationReadinessContractResult;

};

export type ProductionSchedulerRuntimeFinalizationReadinessContractConsumerResult =

  | {

      ok: true;

      consumer: "production_scheduler_runtime_finalization_readiness_contract_consumer";

      scheduler_runtime_finalization_readiness_contract_consumed: true;

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

      consumer: "production_scheduler_runtime_finalization_readiness_contract_consumer";

      scheduler_runtime_finalization_readiness_contract_consumed: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function consumeSchedulerRuntimeFinalizationReadinessContractForProduction(

  input: ProductionSchedulerRuntimeFinalizationReadinessContractConsumerInput,

): ProductionSchedulerRuntimeFinalizationReadinessContractConsumerResult {

  const readinessContract =

    input.scheduler_runtime_finalization_readiness_contract;

  if (

    !readinessContract.ok ||

    !readinessContract.scheduler_runtime_finalization_readiness_contract_ready

  ) {

    return {

      ok: false,

      consumer: "production_scheduler_runtime_finalization_readiness_contract_consumer",

      scheduler_runtime_finalization_readiness_contract_consumed: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Production Scheduler Runtime Finalization Readiness Contract Consumer failed closed because Scheduler Runtime Finalization Readiness Contract was not ready.",

      ],

    };

  }

  return {

    ok: true,

    consumer: "production_scheduler_runtime_finalization_readiness_contract_consumer",

    scheduler_runtime_finalization_readiness_contract_consumed: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Production Scheduler Runtime Finalization Readiness Contract Consumer consumed Scheduler Runtime Finalization Readiness Contract without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

