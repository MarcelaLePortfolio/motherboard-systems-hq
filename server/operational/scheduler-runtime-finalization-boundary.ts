
import type { ProductionSchedulerRuntimeDispatchContractConsumerResult } from "./production-scheduler-runtime-dispatch-contract-consumer.ts";

export type SchedulerRuntimeFinalizationBoundaryInput = {

  production_scheduler_runtime_dispatch_contract_consumer: ProductionSchedulerRuntimeDispatchContractConsumerResult;

};

export type SchedulerRuntimeFinalizationBoundaryResult =

  | {

      ok: true;

      boundary: "scheduler_runtime_finalization";

      scheduler_runtime_finalization_transition_authorized: true;

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

      boundary: "scheduler_runtime_finalization";

      scheduler_runtime_finalization_transition_authorized: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function authorizeSchedulerRuntimeFinalizationTransition(

  input: SchedulerRuntimeFinalizationBoundaryInput,

): SchedulerRuntimeFinalizationBoundaryResult {

  const dispatchContractConsumer =

    input.production_scheduler_runtime_dispatch_contract_consumer;

  if (

    !dispatchContractConsumer.ok ||

    !dispatchContractConsumer.scheduler_runtime_dispatch_contract_consumed

  ) {

    return {

      ok: false,

      boundary: "scheduler_runtime_finalization",

      scheduler_runtime_finalization_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Runtime Finalization Boundary failed closed because Production Scheduler Runtime Dispatch Contract Consumer did not consume the runtime dispatch contract.",

      ],

    };

  }

  return {

    ok: true,

    boundary: "scheduler_runtime_finalization",

    scheduler_runtime_finalization_transition_authorized: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Runtime Finalization Boundary authorized only the scheduler runtime finalization transition while withholding scheduling, routing, worker claims, orchestration, execution, and new authority.",

    ],

  };

}

