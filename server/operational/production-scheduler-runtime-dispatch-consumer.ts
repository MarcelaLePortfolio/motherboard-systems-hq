
import type { SchedulerRuntimeDispatchEntryPointResult } from "./scheduler-runtime-dispatch-entry-point";

export type ProductionSchedulerRuntimeDispatchConsumerInput = {

  scheduler_runtime_dispatch_entry_point: SchedulerRuntimeDispatchEntryPointResult;

};

export type ProductionSchedulerRuntimeDispatchConsumerResult =

  | {

      ok: true;

      consumer: "production_scheduler_runtime_dispatch_consumer";

      scheduler_runtime_dispatch_consumed: true;

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

      consumer: "production_scheduler_runtime_dispatch_consumer";

      scheduler_runtime_dispatch_consumed: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function consumeSchedulerRuntimeDispatchEntryPointForProduction(

  input: ProductionSchedulerRuntimeDispatchConsumerInput,

): ProductionSchedulerRuntimeDispatchConsumerResult {

  const dispatchEntryPoint = input.scheduler_runtime_dispatch_entry_point;

  if (!dispatchEntryPoint.ok || !dispatchEntryPoint.scheduler_runtime_dispatch_request_ready) {

    return {

      ok: false,

      consumer: "production_scheduler_runtime_dispatch_consumer",

      scheduler_runtime_dispatch_consumed: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Production Scheduler Runtime Dispatch Consumer failed closed because Scheduler Runtime Dispatch Entry Point did not produce dispatch request readiness.",

      ],

    };

  }

  return {

    ok: true,

    consumer: "production_scheduler_runtime_dispatch_consumer",

    scheduler_runtime_dispatch_consumed: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Production Scheduler Runtime Dispatch Consumer consumed Scheduler Runtime Dispatch Entry Point readiness without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

