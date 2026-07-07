
import type { SchedulerRuntimeEntryPointResult } from "./scheduler-runtime-entry-point";

export type ProductionSchedulerRuntimeConsumerInput = {

  scheduler_runtime_entry_point: SchedulerRuntimeEntryPointResult;

};

export type ProductionSchedulerRuntimeConsumerResult =

  | {

      ok: true;

      consumer: "production_scheduler_runtime_consumer";

      scheduler_runtime_consumed: true;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: true;

      new_authority_introduced: false;

      findings: string[];

    }

  | {

      ok: false;

      consumer: "production_scheduler_runtime_consumer";

      scheduler_runtime_consumed: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: true;

      new_authority_introduced: false;

      findings: string[];

    };

export function consumeSchedulerRuntimeEntryPointForProduction(

  input: ProductionSchedulerRuntimeConsumerInput,

): ProductionSchedulerRuntimeConsumerResult {

  const runtimeEntryPoint = input.scheduler_runtime_entry_point;

  if (!runtimeEntryPoint.ok || !runtimeEntryPoint.scheduler_runtime_request_ready) {

    return {

      ok: false,

      consumer: "production_scheduler_runtime_consumer",

      scheduler_runtime_consumed: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: true,

      new_authority_introduced: false,

      findings: [

        "Production Scheduler Runtime Consumer failed closed because Scheduler Runtime Entry Point did not produce runtime request readiness.",

      ],

    };

  }

  return {

    ok: true,

    consumer: "production_scheduler_runtime_consumer",

    scheduler_runtime_consumed: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: true,

    new_authority_introduced: false,

    findings: [

      "Production Scheduler Runtime Consumer consumed Scheduler Runtime Entry Point readiness without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

