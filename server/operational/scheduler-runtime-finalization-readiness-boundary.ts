
import type { ProductionSchedulerRuntimeFinalizationContractConsumerResult } from "./production-scheduler-runtime-finalization-contract-consumer.ts";

export type SchedulerRuntimeFinalizationReadinessBoundaryInput = {

  production_scheduler_runtime_finalization_contract_consumer: ProductionSchedulerRuntimeFinalizationContractConsumerResult;

};

export type SchedulerRuntimeFinalizationReadinessBoundaryResult =

  | {

      ok: true;

      boundary: "scheduler_runtime_finalization_readiness";

      scheduler_runtime_finalization_ready: true;

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

      boundary: "scheduler_runtime_finalization_readiness";

      scheduler_runtime_finalization_ready: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function evaluateSchedulerRuntimeFinalizationReadinessBoundary(

  input: SchedulerRuntimeFinalizationReadinessBoundaryInput,

): SchedulerRuntimeFinalizationReadinessBoundaryResult {

  const finalizationContractConsumer =

    input.production_scheduler_runtime_finalization_contract_consumer;

  if (

    !finalizationContractConsumer.ok ||

    !finalizationContractConsumer.scheduler_runtime_finalization_contract_consumed

  ) {

    return {

      ok: false,

      boundary: "scheduler_runtime_finalization_readiness",

      scheduler_runtime_finalization_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Runtime Finalization Readiness Boundary failed closed because Production Scheduler Runtime Finalization Contract Consumer did not consume the finalization contract.",

      ],

    };

  }

  return {

    ok: true,

    boundary: "scheduler_runtime_finalization_readiness",

    scheduler_runtime_finalization_ready: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Runtime Finalization Readiness Boundary confirmed runtime finalization readiness without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

