
import type { SchedulerRuntimeAuthorizationBoundaryResult } from "./scheduler-runtime-authorization-boundary";

export type SchedulerRuntimeContractInput = {

  scheduler_runtime_authorization: SchedulerRuntimeAuthorizationBoundaryResult;

};

export type SchedulerRuntimeContractResult =

  | {

      ok: true;

      contract: "scheduler_runtime_contract";

      scheduler_runtime_contract_ready: true;

      scheduler_runtime_transition_authorized: true;

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

      contract: "scheduler_runtime_contract";

      scheduler_runtime_contract_ready: false;

      scheduler_runtime_transition_authorized: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function buildSchedulerRuntimeContract(

  input: SchedulerRuntimeContractInput,

): SchedulerRuntimeContractResult {

  const authorization = input.scheduler_runtime_authorization;

  if (!authorization.ok || !authorization.scheduler_runtime_transition_authorized) {

    return {

      ok: false,

      contract: "scheduler_runtime_contract",

      scheduler_runtime_contract_ready: false,

      scheduler_runtime_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Runtime Contract failed closed because scheduler runtime transition authorization was not established.",

      ],

    };

  }

  return {

    ok: true,

    contract: "scheduler_runtime_contract",

    scheduler_runtime_contract_ready: true,

    scheduler_runtime_transition_authorized: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Runtime Contract constructed the runtime handoff contract without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

