
import type { SchedulerReadinessBoundaryResult } from "./scheduler-readiness-boundary.ts";

export type SchedulerEntryPointInput = {

  scheduler_readiness: SchedulerReadinessBoundaryResult;

};

export type SchedulerEntryPointResult =

  | {

      ok: true;

      entry_point: "scheduler_entry_point";

      scheduler_request_ready: true;

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

      entry_point: "scheduler_entry_point";

      scheduler_request_ready: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function invokeSchedulerEntryPoint(

  input: SchedulerEntryPointInput,

): SchedulerEntryPointResult {

  const schedulerReadiness = input.scheduler_readiness;

  if (!schedulerReadiness.ok || !schedulerReadiness.scheduler_ready) {

    return {

      ok: false,

      entry_point: "scheduler_entry_point",

      scheduler_request_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Entry Point failed closed because Scheduler Readiness Boundary did not establish scheduler readiness.",

      ],

    };

  }

  return {

    ok: true,

    entry_point: "scheduler_entry_point",

    scheduler_request_ready: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Entry Point accepted Scheduler Readiness Boundary output without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

