
import type { ProductionSchedulerDispatchConsumerResult } from "./production-scheduler-dispatch-consumer";

export type SchedulerExecutionReadinessBoundaryInput = {

  production_scheduler_dispatch_consumer: ProductionSchedulerDispatchConsumerResult;

};

export type SchedulerExecutionReadinessBoundaryResult =

  | {

      ok: true;

      boundary: "scheduler_execution_readiness";

      scheduler_execution_ready: true;

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

      boundary: "scheduler_execution_readiness";

      scheduler_execution_ready: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function evaluateSchedulerExecutionReadinessBoundary(

  input: SchedulerExecutionReadinessBoundaryInput,

): SchedulerExecutionReadinessBoundaryResult {

  const dispatchConsumer = input.production_scheduler_dispatch_consumer;

  if (!dispatchConsumer.ok || !dispatchConsumer.scheduler_dispatch_consumed) {

    return {

      ok: false,

      boundary: "scheduler_execution_readiness",

      scheduler_execution_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Execution Readiness Boundary failed closed because Production Scheduler Dispatch Consumer did not consume the dispatch contract.",

      ],

    };

  }

  return {

    ok: true,

    boundary: "scheduler_execution_readiness",

    scheduler_execution_ready: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Execution Readiness Boundary confirmed scheduler execution readiness without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

