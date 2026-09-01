
import type { SchedulerRuntimeFinalizationEntryPointResult } from "./scheduler-runtime-finalization-entry-point";

export type ProductionSchedulerRuntimeFinalizationConsumerInput = {

  scheduler_runtime_finalization_entry_point: SchedulerRuntimeFinalizationEntryPointResult;

};

export type ProductionSchedulerRuntimeFinalizationConsumerResult =

  | {

      ok: true;

      consumer: "production_scheduler_runtime_finalization_consumer";

      scheduler_runtime_finalization_consumed: true;

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

      consumer: "production_scheduler_runtime_finalization_consumer";

      scheduler_runtime_finalization_consumed: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function consumeSchedulerRuntimeFinalizationEntryPointForProduction(

  input: ProductionSchedulerRuntimeFinalizationConsumerInput,

): ProductionSchedulerRuntimeFinalizationConsumerResult {

  const finalizationEntryPoint = input.scheduler_runtime_finalization_entry_point;

  if (

    !finalizationEntryPoint.ok ||

    !finalizationEntryPoint.scheduler_runtime_finalization_request_ready

  ) {

    return {

      ok: false,

      consumer: "production_scheduler_runtime_finalization_consumer",

      scheduler_runtime_finalization_consumed: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Production Scheduler Runtime Finalization Consumer failed closed because Scheduler Runtime Finalization Entry Point did not produce finalization request readiness.",

      ],

    };

  }

  return {

    ok: true,

    consumer: "production_scheduler_runtime_finalization_consumer",

    scheduler_runtime_finalization_consumed: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Production Scheduler Runtime Finalization Consumer consumed Scheduler Runtime Finalization Entry Point readiness without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

