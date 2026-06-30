
import type { SchedulerRuntimeFinalizationAuthorizationBoundaryResult } from "./scheduler-runtime-finalization-authorization-boundary.ts";

export type SchedulerRuntimeFinalizationContractInput = {

  scheduler_runtime_finalization_authorization: SchedulerRuntimeFinalizationAuthorizationBoundaryResult;

};

export type SchedulerRuntimeFinalizationContractResult =

  | {

      ok: true;

      contract: "scheduler_runtime_finalization_contract";

      scheduler_runtime_finalization_contract_ready: true;

      scheduler_runtime_finalization_transition_authorized: true;

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

      contract: "scheduler_runtime_finalization_contract";

      scheduler_runtime_finalization_contract_ready: false;

      scheduler_runtime_finalization_transition_authorized: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function buildSchedulerRuntimeFinalizationContract(

  input: SchedulerRuntimeFinalizationContractInput,

): SchedulerRuntimeFinalizationContractResult {

  const authorization = input.scheduler_runtime_finalization_authorization;

  if (

    !authorization.ok ||

    !authorization.scheduler_runtime_finalization_transition_authorized

  ) {

    return {

      ok: false,

      contract: "scheduler_runtime_finalization_contract",

      scheduler_runtime_finalization_contract_ready: false,

      scheduler_runtime_finalization_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Runtime Finalization Contract failed closed because scheduler runtime finalization transition authorization was not established.",

      ],

    };

  }

  return {

    ok: true,

    contract: "scheduler_runtime_finalization_contract",

    scheduler_runtime_finalization_contract_ready: true,

    scheduler_runtime_finalization_transition_authorized: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Runtime Finalization Contract constructed the runtime finalization handoff contract without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

