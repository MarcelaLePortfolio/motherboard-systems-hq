
import type { SchedulerExecutionEntryPointResult } from "./scheduler-execution-entry-point";

export type ProductionSchedulerExecutionConsumerInput = {

  scheduler_execution_entry_point: SchedulerExecutionEntryPointResult;

};

export type ProductionSchedulerExecutionConsumerResult =

  | {

      ok: true;

      consumer: "production_scheduler_execution_consumer";

      scheduler_execution_consumed: true;

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

      consumer: "production_scheduler_execution_consumer";

      scheduler_execution_consumed: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function consumeSchedulerExecutionEntryPointForProduction(

  input: ProductionSchedulerExecutionConsumerInput,

): ProductionSchedulerExecutionConsumerResult {

  const executionEntryPoint = input.scheduler_execution_entry_point;

  if (!executionEntryPoint.ok || !executionEntryPoint.scheduler_execution_request_ready) {

    return {

      ok: false,

      consumer: "production_scheduler_execution_consumer",

      scheduler_execution_consumed: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Production Scheduler Execution Consumer failed closed because Scheduler Execution Entry Point did not produce execution request readiness.",

      ],

    };

  }

  return {

    ok: true,

    consumer: "production_scheduler_execution_consumer",

    scheduler_execution_consumed: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Production Scheduler Execution Consumer consumed Scheduler Execution Entry Point readiness without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

