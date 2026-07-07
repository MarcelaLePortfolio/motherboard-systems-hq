
import type { SchedulerEntryPointResult } from "./scheduler-entry-point";

export type ProductionSchedulerConsumerInput = {

  scheduler_entry_point: SchedulerEntryPointResult;

};

export type ProductionSchedulerConsumerResult =

  | {

      ok: true;

      consumer: "production_scheduler_consumer";

      scheduler_consumer_ready: true;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: authority.execution_authorized;

      new_authority_introduced: false;

      findings: string[];

    }

  | {

      ok: false;

      consumer: "production_scheduler_consumer";

      scheduler_consumer_ready: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: authority.execution_authorized;

      new_authority_introduced: false;

      findings: string[];

    };

export function consumeSchedulerEntryPointForProduction(

  input: ProductionSchedulerConsumerInput,

): ProductionSchedulerConsumerResult {

  const schedulerEntryPoint = input.scheduler_entry_point;

  if (!schedulerEntryPoint.ok || !schedulerEntryPoint.scheduler_request_ready) {

    return {

      ok: false,

      consumer: "production_scheduler_consumer",

      scheduler_consumer_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: authority.execution_authorized,

      new_authority_introduced: false,

      findings: [

        "Production Scheduler Consumer failed closed because Scheduler Entry Point did not produce scheduler request readiness.",

      ],

    };

  }

  return {

    ok: true,

    consumer: "production_scheduler_consumer",

    scheduler_consumer_ready: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: authority.execution_authorized,

    new_authority_introduced: false,

    findings: [

      "Production Scheduler Consumer consumed Scheduler Entry Point readiness without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

