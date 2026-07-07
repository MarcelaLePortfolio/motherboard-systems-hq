
import type { SchedulerRuntimeFinalizationBoundaryResult } from "./scheduler-runtime-finalization-boundary";

export type SchedulerRuntimeFinalizationEntryPointInput = {

  scheduler_runtime_finalization_boundary: SchedulerRuntimeFinalizationBoundaryResult;

};

export type SchedulerRuntimeFinalizationEntryPointResult =

  | {

      ok: true;

      entry_point: "scheduler_runtime_finalization_entry_point";

      scheduler_runtime_finalization_request_ready: true;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: true;

      new_authority_introduced: false;

      findings: string[];

    }

  | {

      ok: false;

      entry_point: "scheduler_runtime_finalization_entry_point";

      scheduler_runtime_finalization_request_ready: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: true;

      new_authority_introduced: false;

      findings: string[];

    };

export function invokeSchedulerRuntimeFinalizationEntryPoint(

  input: SchedulerRuntimeFinalizationEntryPointInput,

): SchedulerRuntimeFinalizationEntryPointResult {

  const finalizationBoundary = input.scheduler_runtime_finalization_boundary;

  if (

    !finalizationBoundary.ok ||

    !finalizationBoundary.scheduler_runtime_finalization_transition_authorized

  ) {

    return {

      ok: false,

      entry_point: "scheduler_runtime_finalization_entry_point",

      scheduler_runtime_finalization_request_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: true,

      new_authority_introduced: false,

      findings: [

        "Scheduler Runtime Finalization Entry Point failed closed because Scheduler Runtime Finalization Boundary did not authorize finalization transition readiness.",

      ],

    };

  }

  return {

    ok: true,

    entry_point: "scheduler_runtime_finalization_entry_point",

    scheduler_runtime_finalization_request_ready: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: true,

    new_authority_introduced: false,

    findings: [

      "Scheduler Runtime Finalization Entry Point accepted runtime finalization readiness without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

