
import type { OperationalIntakeRecord } from "../../db/operational-intake-runtime.js";

export type ProductionOperationalConsumerInput = {

  operational_intake: OperationalIntakeRecord;

};

export type ProductionOperationalConsumerResult =

  | {

      ok: true;

      consumer: "production_operational_consumer";

      operational_intake: OperationalIntakeRecord;

      downstream_consumption_ready: true;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: authority.execution_authorized;

      new_authority_introduced: false;

      findings: string[];

    }

  | {

      ok: false;

      consumer: "production_operational_consumer";

      operational_intake?: OperationalIntakeRecord;

      downstream_consumption_ready: false;

      scheduler_authorized: false;

      routing_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      execution_authorized: authority.execution_authorized;

      new_authority_introduced: false;

      findings: string[];

    };

export function consumeOperationalIntakeForProduction(

  input: ProductionOperationalConsumerInput,

): ProductionOperationalConsumerResult {

  const operationalIntake = input.operational_intake;

  if (operationalIntake.lifecycle_state_at_intake !== "ASSIGNED") {

    return {

      ok: false,

      consumer: "production_operational_consumer",

      operational_intake: operationalIntake,

      downstream_consumption_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: authority.execution_authorized,

      new_authority_introduced: false,

      findings: [

        "Production Operational Consumer failed closed because Operational Intake was not recorded from ASSIGNED lifecycle state.",

      ],

    };

  }

  if (operationalIntake.intake_status !== "RECORDED") {

    return {

      ok: false,

      consumer: "production_operational_consumer",

      operational_intake: operationalIntake,

      downstream_consumption_ready: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: authority.execution_authorized,

      new_authority_introduced: false,

      findings: [

        "Production Operational Consumer failed closed because Operational Intake status was not RECORDED.",

      ],

    };

  }

  return {

    ok: true,

    consumer: "production_operational_consumer",

    operational_intake: operationalIntake,

    downstream_consumption_ready: true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: authority.execution_authorized,

    new_authority_introduced: false,

    findings: [

      "Production Operational Consumer consumed canonical Operational Intake without scheduler, routing, worker, orchestration, execution, actor assignment, participation resolution, or new authority.",

    ],

  };

}

