
import type { ProductionSchedulerRuntimeConsumerResult } from "./production-scheduler-runtime-consumer.ts";

export type SchedulerRuntimeAuthorizationBoundaryInput = {

  production_scheduler_runtime_consumer: ProductionSchedulerRuntimeConsumerResult;

};

export type SchedulerRuntimeAuthorizationBoundaryResult =

  | {

      ok: true;

      boundary: "scheduler_runtime_authorization";

      scheduler_runtime_transition_authorized: true;

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

      boundary: "scheduler_runtime_authorization";

      scheduler_runtime_transition_authorized: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function authorizeSchedulerRuntimeTransition(

  input: SchedulerRuntimeAuthorizationBoundaryInput,

): SchedulerRuntimeAuthorizationBoundaryResult {

  const runtimeConsumer = input.production_scheduler_runtime_consumer;

  if (!runtimeConsumer.ok || !runtimeConsumer.scheduler_runtime_consumed) {

    return {

      ok: false,

      boundary: "scheduler_runtime_authorization",

      scheduler_runtime_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Runtime Authorization Boundary failed closed because Production Scheduler Runtime Consumer did not consume the scheduler runtime request.",

      ],

    };

  }

  return {

    ok: true,

    boundary: "scheduler_runtime_authorization",

    scheduler_runtime_transition_authorized: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Runtime Authorization Boundary authorized only the scheduler runtime transition while withholding scheduling, routing, worker claims, orchestration, execution, and new authority.",

    ],

  };

}

