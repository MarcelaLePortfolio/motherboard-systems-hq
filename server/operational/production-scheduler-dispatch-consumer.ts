
import type { SchedulerDispatchContractResult } from "./scheduler-dispatch-contract.ts";

export type ProductionSchedulerDispatchConsumerInput = {

  scheduler_dispatch_contract: SchedulerDispatchContractResult;

};

export type ProductionSchedulerDispatchConsumerResult =

  | {

      ok: true;

      consumer: "production_scheduler_dispatch_consumer";

      scheduler_dispatch_consumed: true;

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

      consumer: "production_scheduler_dispatch_consumer";

      scheduler_dispatch_consumed: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function consumeSchedulerDispatchContractForProduction(

  input: ProductionSchedulerDispatchConsumerInput,

): ProductionSchedulerDispatchConsumerResult {

  const dispatchContract = input.scheduler_dispatch_contract;

  if (!dispatchContract.ok || !dispatchContract.scheduler_dispatch_ready) {

    return {

      ok: false,

      consumer: "production_scheduler_dispatch_consumer",

      scheduler_dispatch_consumed: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Production Scheduler Dispatch Consumer failed closed because Scheduler Dispatch Contract did not establish dispatch readiness.",

      ],

    };

  }

  return {

    ok: true,

    consumer: "production_scheduler_dispatch_consumer",

    scheduler_dispatch_consumed: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Production Scheduler Dispatch Consumer consumed Scheduler Dispatch Contract without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

