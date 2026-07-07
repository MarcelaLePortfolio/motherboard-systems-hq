
import type { ProductionSchedulerRuntimeDispatchConsumerResult } from "./production-scheduler-runtime-dispatch-consumer";

export type SchedulerRuntimeDispatchAuthorizationBoundaryInput = {

  production_scheduler_runtime_dispatch_consumer: ProductionSchedulerRuntimeDispatchConsumerResult;

};

export type SchedulerRuntimeDispatchAuthorizationBoundaryResult =

  | {

      ok: true;

      boundary: "scheduler_runtime_dispatch_authorization";

      scheduler_runtime_dispatch_transition_authorized: true;

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

      boundary: "scheduler_runtime_dispatch_authorization";

      scheduler_runtime_dispatch_transition_authorized: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function authorizeSchedulerRuntimeDispatchTransition(

  input: SchedulerRuntimeDispatchAuthorizationBoundaryInput,

): SchedulerRuntimeDispatchAuthorizationBoundaryResult {

  const dispatchConsumer = input.production_scheduler_runtime_dispatch_consumer;

  if (!dispatchConsumer.ok || !dispatchConsumer.scheduler_runtime_dispatch_consumed) {

    return {

      ok: false,

      boundary: "scheduler_runtime_dispatch_authorization",

      scheduler_runtime_dispatch_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Runtime Dispatch Authorization Boundary failed closed because Production Scheduler Runtime Dispatch Consumer did not consume the runtime dispatch request.",

      ],

    };

  }

  return {

    ok: true,

    boundary: "scheduler_runtime_dispatch_authorization",

    scheduler_runtime_dispatch_transition_authorized: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Runtime Dispatch Authorization Boundary authorized only the scheduler runtime dispatch transition while withholding scheduling, routing, worker claims, orchestration, execution, and new authority.",

    ],

  };

}

