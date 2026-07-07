
import type { SchedulerRuntimeContractResult } from "./scheduler-runtime-contract";

export type ProductionSchedulerRuntimeContractConsumerInput = {

  scheduler_runtime_contract: SchedulerRuntimeContractResult;

};

export type ProductionSchedulerRuntimeContractConsumerResult =

  | {

      ok: true;

      consumer: "production_scheduler_runtime_contract_consumer";

      scheduler_runtime_contract_consumed: true;

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

      consumer: "production_scheduler_runtime_contract_consumer";

      scheduler_runtime_contract_consumed: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function consumeSchedulerRuntimeContractForProduction(

  input: ProductionSchedulerRuntimeContractConsumerInput,

): ProductionSchedulerRuntimeContractConsumerResult {

  const runtimeContract = input.scheduler_runtime_contract;

  if (!runtimeContract.ok || !runtimeContract.scheduler_runtime_contract_ready) {

    return {

      ok: false,

      consumer: "production_scheduler_runtime_contract_consumer",

      scheduler_runtime_contract_consumed: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Production Scheduler Runtime Contract Consumer failed closed because Scheduler Runtime Contract was not ready.",

      ],

    };

  }

  return {

    ok: true,

    consumer: "production_scheduler_runtime_contract_consumer",

    scheduler_runtime_contract_consumed: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Production Scheduler Runtime Contract Consumer consumed Scheduler Runtime Contract without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

