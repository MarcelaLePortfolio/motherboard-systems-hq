
import type { ProductionSchedulerConsumerResult } from "./production-scheduler-consumer";

export type SchedulerAuthorizationBoundaryInput = {

  production_scheduler_consumer: ProductionSchedulerConsumerResult;

};

export type SchedulerAuthorizationBoundaryResult =

  | {

      ok: true;

      boundary: "scheduler_authorization";

      scheduler_transition_authorized: true;

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

      boundary: "scheduler_authorization";

      scheduler_transition_authorized: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function authorizeSchedulerTransition(

  input: SchedulerAuthorizationBoundaryInput,

): SchedulerAuthorizationBoundaryResult {

  const schedulerConsumer = input.production_scheduler_consumer;

  if (!schedulerConsumer.ok || !schedulerConsumer.scheduler_consumer_ready) {

    return {

      ok: false,

      boundary: "scheduler_authorization",

      scheduler_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Authorization Boundary failed closed because Production Scheduler Consumer did not establish scheduler consumer readiness.",

      ],

    };

  }

  return {

    ok: true,

    boundary: "scheduler_authorization",

    scheduler_transition_authorized: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Authorization Boundary authorized only the scheduler transition while withholding scheduler execution, routing, worker claims, orchestration, execution, and new authority.",

    ],

  };

}

