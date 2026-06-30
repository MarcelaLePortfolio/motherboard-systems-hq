
import type { SchedulerRuntimeBoundaryResult } from "./scheduler-runtime-boundary.ts";

export type SchedulerRuntimeEntryPointInput = {

  scheduler_runtime_boundary: SchedulerRuntimeBoundaryResult;

};

export type SchedulerRuntimeEntryPointResult =

  | {

      ok: true;

      entry_point: "scheduler_runtime_entry_point";

      scheduler_runtime_request_ready: true;

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

      entry_point: "scheduler_runtime_entry_point";

      scheduler_runtime_request_ready: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function invokeSchedulerRuntimeEntryPoint(

  input: SchedulerRuntimeEntryPointInput,

): SchedulerRuntimeEntryPointResult {

  const runtimeBoundary = input.scheduler_runtime_boundary;

  if (!runtimeBoundary.ok || !runtimeBoundary.scheduler_runtime_ready) {

    return {

      ok: false,

      entry_point: "scheduler_runtime_entry_point",

      scheduler_runtime_request_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Runtime Entry Point failed closed because Scheduler Runtime Boundary did not establish runtime readiness.",

      ],

    };

  }

  return {

    ok: true,

    entry_point: "scheduler_runtime_entry_point",

    scheduler_runtime_request_ready: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Runtime Entry Point accepted scheduler runtime readiness without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

