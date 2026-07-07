
import type { SchedulerRuntimeFinalizationReadinessEntryPointResult } from "./scheduler-runtime-finalization-readiness-entry-point";

export type ProductionSchedulerRuntimeFinalizationReadinessConsumerInput = {

  scheduler_runtime_finalization_readiness_entry_point: SchedulerRuntimeFinalizationReadinessEntryPointResult;

};

export type ProductionSchedulerRuntimeFinalizationReadinessConsumerResult =

  | {

      ok: true;

      consumer: "production_scheduler_runtime_finalization_readiness_consumer";

      scheduler_runtime_finalization_readiness_consumed: true;

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

      consumer: "production_scheduler_runtime_finalization_readiness_consumer";

      scheduler_runtime_finalization_readiness_consumed: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: true;

      new_authority_introduced: false;

      findings: string[];

    };

export function consumeSchedulerRuntimeFinalizationReadinessEntryPointForProduction(

  input: ProductionSchedulerRuntimeFinalizationReadinessConsumerInput,

): ProductionSchedulerRuntimeFinalizationReadinessConsumerResult {

  const readinessEntryPoint =

    input.scheduler_runtime_finalization_readiness_entry_point;

  if (

    !readinessEntryPoint.ok ||

    !readinessEntryPoint.scheduler_runtime_finalization_readiness_request_ready

  ) {

    return {

      ok: false,

      consumer: "production_scheduler_runtime_finalization_readiness_consumer",

      scheduler_runtime_finalization_readiness_consumed: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: true,

      new_authority_introduced: false,

      findings: [

        "Production Scheduler Runtime Finalization Readiness Consumer failed closed because Scheduler Runtime Finalization Readiness Entry Point did not produce finalization readiness request readiness.",

      ],

    };

  }

  return {

    ok: true,

    consumer: "production_scheduler_runtime_finalization_readiness_consumer",

    scheduler_runtime_finalization_readiness_consumed: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: true,

    new_authority_introduced: false,

    findings: [

      "Production Scheduler Runtime Finalization Readiness Consumer consumed Scheduler Runtime Finalization Readiness Entry Point readiness without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

