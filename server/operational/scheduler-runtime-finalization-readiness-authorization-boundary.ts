
import type { ProductionSchedulerRuntimeFinalizationReadinessConsumerResult } from "./production-scheduler-runtime-finalization-readiness-consumer.ts";

export type SchedulerRuntimeFinalizationReadinessAuthorizationBoundaryInput = {

  production_scheduler_runtime_finalization_readiness_consumer: ProductionSchedulerRuntimeFinalizationReadinessConsumerResult;

};

export type SchedulerRuntimeFinalizationReadinessAuthorizationBoundaryResult =

  | {

      ok: true;

      boundary: "scheduler_runtime_finalization_readiness_authorization";

      scheduler_runtime_finalization_readiness_transition_authorized: true;

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

      boundary: "scheduler_runtime_finalization_readiness_authorization";

      scheduler_runtime_finalization_readiness_transition_authorized: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function authorizeSchedulerRuntimeFinalizationReadinessTransition(

  input: SchedulerRuntimeFinalizationReadinessAuthorizationBoundaryInput,

): SchedulerRuntimeFinalizationReadinessAuthorizationBoundaryResult {

  const readinessConsumer =

    input.production_scheduler_runtime_finalization_readiness_consumer;

  if (

    !readinessConsumer.ok ||

    !readinessConsumer.scheduler_runtime_finalization_readiness_consumed

  ) {

    return {

      ok: false,

      boundary: "scheduler_runtime_finalization_readiness_authorization",

      scheduler_runtime_finalization_readiness_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Runtime Finalization Readiness Authorization Boundary failed closed because Production Scheduler Runtime Finalization Readiness Consumer did not consume the runtime finalization readiness request.",

      ],

    };

  }

  return {

    ok: true,

    boundary: "scheduler_runtime_finalization_readiness_authorization",

    scheduler_runtime_finalization_readiness_transition_authorized: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Runtime Finalization Readiness Authorization Boundary authorized only the scheduler runtime finalization readiness transition while withholding scheduling, routing, worker claims, orchestration, execution, and new authority.",

    ],

  };

}

