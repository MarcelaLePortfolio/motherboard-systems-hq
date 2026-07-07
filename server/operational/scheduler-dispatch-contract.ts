
import type { SchedulerAuthorizationBoundaryResult } from "./scheduler-authorization-boundary";

import type { OperationalIntakeRecord } from "../../db/operational-intake-runtime.js";

export type SchedulerDispatchContractInput = {

  scheduler_authorization: SchedulerAuthorizationBoundaryResult;

  operational_intake: OperationalIntakeRecord;

};

export type SchedulerDispatchContractResult =

  | {

      ok: true;

      contract: "scheduler_dispatch_contract";

      scheduler_dispatch_ready: true;

      scheduler_transition_authorized: true;

      envelope_id: string;

      package_id: string;

      package_version: number;

      assigned_department: string;

      required_capabilities_snapshot: string | null;

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

      contract: "scheduler_dispatch_contract";

      scheduler_dispatch_ready: false;

      scheduler_transition_authorized: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function buildSchedulerDispatchContract(

  input: SchedulerDispatchContractInput,

): SchedulerDispatchContractResult {

  const schedulerAuthorization = input.scheduler_authorization;

  const operationalIntake = input.operational_intake;

  if (!schedulerAuthorization.ok || !schedulerAuthorization.scheduler_transition_authorized) {

    return {

      ok: false,

      contract: "scheduler_dispatch_contract",

      scheduler_dispatch_ready: false,

      scheduler_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Dispatch Contract failed closed because scheduler transition authorization was not established.",

      ],

    };

  }

  if (operationalIntake.lifecycle_state_at_intake !== "ASSIGNED" || operationalIntake.intake_status !== "RECORDED") {

    return {

      ok: false,

      contract: "scheduler_dispatch_contract",

      scheduler_dispatch_ready: false,

      scheduler_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Dispatch Contract failed closed because Operational Intake was not a recorded ASSIGNED intake.",

      ],

    };

  }

  return {

    ok: true,

    contract: "scheduler_dispatch_contract",

    scheduler_dispatch_ready: true,

    scheduler_transition_authorized: true,

    envelope_id: operationalIntake.envelope_id,

    package_id: operationalIntake.package_id,

    package_version: operationalIntake.package_version,

    assigned_department: operationalIntake.assigned_department,

    required_capabilities_snapshot: operationalIntake.required_capabilities_snapshot,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Dispatch Contract constructed the scheduler handoff contract without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

