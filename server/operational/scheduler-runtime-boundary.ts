
import type { ProductionSchedulerExecutionConsumerResult } from "./production-scheduler-execution-consumer";

export type SchedulerRuntimeBoundaryInput = {

  production_scheduler_execution_consumer: ProductionSchedulerExecutionConsumerResult;

};

export type SchedulerRuntimeBoundaryResult =

  | {

      ok: true;

      boundary: "scheduler_runtime";

      scheduler_runtime_ready: true;

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

      boundary: "scheduler_runtime";

      scheduler_runtime_ready: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function evaluateSchedulerRuntimeBoundary(

  input: SchedulerRuntimeBoundaryInput,

): SchedulerRuntimeBoundaryResult {

  const executionConsumer = input.production_scheduler_execution_consumer;

  if (!executionConsumer.ok || !executionConsumer.scheduler_execution_consumed) {

    return {

      ok: false,

      boundary: "scheduler_runtime",

      scheduler_runtime_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Runtime Boundary failed closed because Production Scheduler Execution Consumer did not consume the scheduler execution request.",

      ],

    };

  }

  return {

    ok: true,

    boundary: "scheduler_runtime",

    scheduler_runtime_ready: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Runtime Boundary confirmed scheduler runtime readiness without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

