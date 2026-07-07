
import type { ProductionOperationalConsumerResult } from "./production-operational-consumer";

export type SchedulerReadinessBoundaryInput = {

  operational_consumption: ProductionOperationalConsumerResult;

};

export type SchedulerReadinessBoundaryResult =

  | {

      ok: true;

      boundary: "scheduler_readiness";

      scheduler_ready: true;

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

      boundary: "scheduler_readiness";

      scheduler_ready: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function evaluateSchedulerReadinessBoundary(

  input: SchedulerReadinessBoundaryInput,

): SchedulerReadinessBoundaryResult {

  const operationalConsumption = input.operational_consumption;

  if (!operationalConsumption.ok) {

    return {

      ok: false,

      boundary: "scheduler_readiness",

      scheduler_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Readiness Boundary failed closed because production operational consumption did not succeed.",

      ],

    };

  }

  if (!operationalConsumption.downstream_consumption_ready) {

    return {

      ok: false,

      boundary: "scheduler_readiness",

      scheduler_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Scheduler Readiness Boundary failed closed because downstream operational consumption was not ready.",

      ],

    };

  }

  return {

    ok: true,

    boundary: "scheduler_readiness",

    scheduler_ready: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Scheduler Readiness Boundary confirmed scheduler readiness from successful production operational consumption without authorizing scheduling, routing, worker claims, orchestration, execution, or new authority.",

    ],

  };

}

