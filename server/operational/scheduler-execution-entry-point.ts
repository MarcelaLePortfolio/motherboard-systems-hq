
import type { SchedulerExecutionReadinessBoundaryResult } from "./scheduler-execution-readiness-boundary.ts";

export type SchedulerExecutionEntryPointInput = {

  scheduler_execution_readiness: SchedulerExecutionReadinessBoundaryResult;

};

export type SchedulerExecutionEntryPointResult =

  | {

      ok: true;

      entry_point: "scheduler_execution_entry_point";

      scheduler_execution_request_ready: true;

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

      entry_point: "scheduler_execution_entry_point";

      scheduler_execution_request_ready: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function invokeSchedulerExecutionEntryPoint(

  input: SchedulerExecutionEntryPointInput,

): SchedulerExecutionEntryPointResult {

  const readiness = input.scheduler_execution_readiness;

  if (!readiness.ok || !readiness.scheduler_execution_ready) {

    return {

      ok: false,

      entry_point: "scheduler_execution_entry_point",

      scheduler_execution_request_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Execution Entry Point failed closed because Scheduler Execution Readiness Boundary did not establish execution readiness.",

      ],

    };

  }

  return {

    ok: true,

    entry_point: "scheduler_execution_entry_point",

    scheduler_execution_request_ready: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Execution Entry Point accepted scheduler execution readiness without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

