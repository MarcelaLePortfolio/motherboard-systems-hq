
import type { SchedulerRuntimeDispatchContractResult } from "./scheduler-runtime-dispatch-contract.ts";

export type ProductionSchedulerRuntimeDispatchContractConsumerInput = {

  scheduler_runtime_dispatch_contract: SchedulerRuntimeDispatchContractResult;

};

export type ProductionSchedulerRuntimeDispatchContractConsumerResult =

  | {

      ok: true;

      consumer: "production_scheduler_runtime_dispatch_contract_consumer";

      scheduler_runtime_dispatch_contract_consumed: true;

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

      consumer: "production_scheduler_runtime_dispatch_contract_consumer";

      scheduler_runtime_dispatch_contract_consumed: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function consumeSchedulerRuntimeDispatchContractForProduction(

  input: ProductionSchedulerRuntimeDispatchContractConsumerInput,

): ProductionSchedulerRuntimeDispatchContractConsumerResult {

  const dispatchContract = input.scheduler_runtime_dispatch_contract;

  if (!dispatchContract.ok || !dispatchContract.scheduler_runtime_dispatch_contract_ready) {

    return {

      ok: false,

      consumer: "production_scheduler_runtime_dispatch_contract_consumer",

      scheduler_runtime_dispatch_contract_consumed: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Production Scheduler Runtime Dispatch Contract Consumer failed closed because Scheduler Runtime Dispatch Contract was not ready.",

      ],

    };

  }

  return {

    ok: true,

    consumer: "production_scheduler_runtime_dispatch_contract_consumer",

    scheduler_runtime_dispatch_contract_consumed: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Production Scheduler Runtime Dispatch Contract Consumer consumed Scheduler Runtime Dispatch Contract without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

