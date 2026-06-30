
import type { ProductionSchedulerRuntimeFinalizationReadinessCompletionConsumerResult } from "./production-scheduler-runtime-finalization-readiness-completion-consumer.ts";

export type SchedulerRuntimeFinalizationReadinessCompletionAuthorizationBoundaryInput = {

  production_scheduler_runtime_finalization_readiness_completion_consumer: ProductionSchedulerRuntimeFinalizationReadinessCompletionConsumerResult;

};

export type SchedulerRuntimeFinalizationReadinessCompletionAuthorizationBoundaryResult =

  | {

      ok: true;

      boundary: "scheduler_runtime_finalization_readiness_completion_authorization";

      scheduler_runtime_finalization_readiness_completion_transition_authorized: true;

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

      boundary: "scheduler_runtime_finalization_readiness_completion_authorization";

      scheduler_runtime_finalization_readiness_completion_transition_authorized: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function authorizeSchedulerRuntimeFinalizationReadinessCompletionTransition(

  input: SchedulerRuntimeFinalizationReadinessCompletionAuthorizationBoundaryInput,

): SchedulerRuntimeFinalizationReadinessCompletionAuthorizationBoundaryResult {

  const completionConsumer =

    input.production_scheduler_runtime_finalization_readiness_completion_consumer;

  if (

    !completionConsumer.ok ||

    !completionConsumer.scheduler_runtime_finalization_readiness_completion_consumed

  ) {

    return {

      ok: false,

      boundary: "scheduler_runtime_finalization_readiness_completion_authorization",

      scheduler_runtime_finalization_readiness_completion_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Runtime Finalization Readiness Completion Authorization Boundary failed closed because Production Scheduler Runtime Finalization Readiness Completion Consumer did not consume completion readiness.",

      ],

    };

  }

  return {

    ok: true,

    boundary: "scheduler_runtime_finalization_readiness_completion_authorization",

    scheduler_runtime_finalization_readiness_completion_transition_authorized: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Runtime Finalization Readiness Completion Authorization Boundary authorized only the scheduler runtime finalization readiness completion transition while withholding scheduling, routing, worker claims, orchestration, execution, and new authority.",

    ],

  };

}

