
import type { SchedulerRuntimeDispatchAuthorizationBoundaryResult } from "./scheduler-runtime-dispatch-authorization-boundary";

export type SchedulerRuntimeDispatchContractInput = {

  scheduler_runtime_dispatch_authorization: SchedulerRuntimeDispatchAuthorizationBoundaryResult;

};

export type SchedulerRuntimeDispatchContractResult =

  | {

      ok: true;

      contract: "scheduler_runtime_dispatch_contract";

      scheduler_runtime_dispatch_contract_ready: true;

      scheduler_runtime_dispatch_transition_authorized: true;

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

      contract: "scheduler_runtime_dispatch_contract";

      scheduler_runtime_dispatch_contract_ready: false;

      scheduler_runtime_dispatch_transition_authorized: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function buildSchedulerRuntimeDispatchContract(

  input: SchedulerRuntimeDispatchContractInput,

): SchedulerRuntimeDispatchContractResult {

  const authorization = input.scheduler_runtime_dispatch_authorization;

  if (!authorization.ok || !authorization.scheduler_runtime_dispatch_transition_authorized) {

    return {

      ok: false,

      contract: "scheduler_runtime_dispatch_contract",

      scheduler_runtime_dispatch_contract_ready: false,

      scheduler_runtime_dispatch_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Runtime Dispatch Contract failed closed because scheduler runtime dispatch transition authorization was not established.",

      ],

    };

  }

  return {

    ok: true,

    contract: "scheduler_runtime_dispatch_contract",

    scheduler_runtime_dispatch_contract_ready: true,

    scheduler_runtime_dispatch_transition_authorized: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Runtime Dispatch Contract constructed the runtime dispatch handoff contract without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

