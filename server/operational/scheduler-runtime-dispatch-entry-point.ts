
import { evaluateExecutionAuthority } from "../execution/execution-authority-core";

import type { SchedulerRuntimeDispatchBoundaryResult } from "./scheduler-runtime-dispatch-boundary";

export type SchedulerRuntimeDispatchEntryPointInput = {

  scheduler_runtime_dispatch_boundary: SchedulerRuntimeDispatchBoundaryResult;

};

export type SchedulerRuntimeDispatchEntryPointResult =

  | {

      ok: true;

      entry_point: "scheduler_runtime_dispatch_entry_point";

      scheduler_runtime_dispatch_request_ready: true;

      scheduler_authorized: boolean;

      routing_authorized: boolean;

      worker_claim_authorized: boolean;

      orchestration_authorized: boolean;

      execution_authorized: boolean;

      new_authority_introduced: false;

      findings: string[];

    }

  | {

      ok: false;

      entry_point: "scheduler_runtime_dispatch_entry_point";

      scheduler_runtime_dispatch_request_ready: false;

      scheduler_authorized: boolean;

      routing_authorized: boolean;

      worker_claim_authorized: boolean;

      orchestration_authorized: boolean;

      execution_authorized: boolean;

      new_authority_introduced: false;

      findings: string[];

    };

export function invokeSchedulerRuntimeDispatchEntryPoint(

  input: SchedulerRuntimeDispatchEntryPointInput,

): SchedulerRuntimeDispatchEntryPointResult {

  const dispatchBoundary = input.scheduler_runtime_dispatch_boundary;

  const decision = evaluateExecutionAuthority({

    preview_confirmed: true,

    plan_review_ready: dispatchBoundary.ok

  });

  if (!dispatchBoundary.ok || !dispatchBoundary.scheduler_runtime_dispatch_ready) {

    return {

      ok: false,

      entry_point: "scheduler_runtime_dispatch_entry_point",

      scheduler_runtime_dispatch_request_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: decision.execution_authorized,

      new_authority_introduced: false,

      findings: [

        "Dispatch blocked by boundary; execution authority evaluated but not granted."

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

    execution_authorized: decision.execution_authorized,

    new_authority_introduced: false,

    findings: [

      "Dispatch passed boundary; execution authority evaluated via central authority core."

    ],

  };

}

