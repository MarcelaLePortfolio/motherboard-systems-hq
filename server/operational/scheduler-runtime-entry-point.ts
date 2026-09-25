import type { SchedulerRuntimeBoundaryResult } from "./scheduler-runtime-boundary";

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
  if (
    !input.scheduler_runtime_boundary.ok ||
    !input.scheduler_runtime_boundary.scheduler_runtime_ready
  ) {
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
        ...input.scheduler_runtime_boundary.findings,
        "Scheduler runtime entry point failed closed because runtime readiness was absent.",
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
      ...input.scheduler_runtime_boundary.findings,
      "Scheduler runtime entry point accepted runtime readiness without introducing scheduler, routing, worker-claim, orchestration, execution, or new authority.",
    ],
  };
}
