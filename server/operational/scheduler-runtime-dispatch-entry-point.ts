
import type { SchedulerRuntimeDispatchBoundaryResult } from "./scheduler-runtime-dispatch-boundary.ts";

export type SchedulerRuntimeDispatchEntryPointInput = {

  scheduler_runtime_dispatch_boundary: SchedulerRuntimeDispatchBoundaryResult;

};

export type SchedulerRuntimeDispatchEntryPointResult =

  | {

      ok: true;

      entry_point: "scheduler_runtime_dispatch_entry_point";

      scheduler_runtime_dispatch_request_ready: true;

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

      entry_point: "scheduler_runtime_dispatch_entry_point";

      scheduler_runtime_dispatch_request_ready: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function invokeSchedulerRuntimeDispatchEntryPoint(

  input: SchedulerRuntimeDispatchEntryPointInput,

): SchedulerRuntimeDispatchEntryPointResult {

  const dispatchBoundary = input.scheduler_runtime_dispatch_boundary;

  if (!dispatchBoundary.ok || !dispatchBoundary.scheduler_runtime_dispatch_ready) {

    return {

      ok: false,

      entry_point: "scheduler_runtime_dispatch_entry_point",

      scheduler_runtime_dispatch_request_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Runtime Dispatch Entry Point failed closed because Scheduler Runtime Dispatch Boundary did not establish dispatch readiness.",

      ],

    };

  }

  return {

    ok: true,

    entry_point: "scheduler_runtime_dispatch_entry_point",

    scheduler_runtime_dispatch_request_ready: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Runtime Dispatch Entry Point accepted runtime dispatch readiness without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

