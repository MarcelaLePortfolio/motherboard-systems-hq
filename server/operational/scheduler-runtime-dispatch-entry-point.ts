
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

  const baseFlags = {

    scheduler_authorized: dispatchBoundary.ok,

    routing_authorized: dispatchBoundary.ok,

    worker_claim_authorized: dispatchBoundary.ok,

    orchestration_authorized: dispatchBoundary.ok,

    execution_authorized: decision.execution_authorized,

  };

  if (!dispatchBoundary.ok || !dispatchBoundary.scheduler_runtime_dispatch_ready) {

    return {

      ok: false,

      entry_point: "scheduler_runtime_dispatch_entry_point",

      scheduler_runtime_dispatch_request_ready: false,

      ...baseFlags,

      new_authority_introduced: false,

      findings: [

        "Dispatch blocked at boundary; all downstream authorizations inherit boundary failure state."

      ],

    };

  }

  return {

    ok: true,

    entry_point: "scheduler_runtime_dispatch_entry_point",

    scheduler_runtime_dispatch_request_ready: true,

    ...baseFlags,

    new_authority_introduced: false,

    findings: [

      "Dispatch passed boundary; authorization state derived consistently from boundary + authority core."

    ],

  };

}

