
import type { ProductionSchedulerRuntimeContractConsumerResult } from "./production-scheduler-runtime-contract-consumer.ts";

export type SchedulerRuntimeDispatchBoundaryInput = {

  production_scheduler_runtime_contract_consumer: ProductionSchedulerRuntimeContractConsumerResult;

};

export type SchedulerRuntimeDispatchBoundaryResult =

  | {

      ok: true;

      boundary: "scheduler_runtime_dispatch";

      scheduler_runtime_dispatch_ready: true;

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

      boundary: "scheduler_runtime_dispatch";

      scheduler_runtime_dispatch_ready: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function evaluateSchedulerRuntimeDispatchBoundary(

  input: SchedulerRuntimeDispatchBoundaryInput,

): SchedulerRuntimeDispatchBoundaryResult {

  const contractConsumer = input.production_scheduler_runtime_contract_consumer;

  if (!contractConsumer.ok || !contractConsumer.scheduler_runtime_contract_consumed) {

    return {

      ok: false,

      boundary: "scheduler_runtime_dispatch",

      scheduler_runtime_dispatch_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Runtime Dispatch Boundary failed closed because Production Scheduler Runtime Contract Consumer did not consume the runtime contract.",

      ],

    };

  }

  return {

    ok: true,

    boundary: "scheduler_runtime_dispatch",

    scheduler_runtime_dispatch_ready: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Runtime Dispatch Boundary confirmed runtime dispatch readiness without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

