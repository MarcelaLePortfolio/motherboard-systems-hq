
import {

  invokeProductionLifecycleEntryPoint,

  type ProductionLifecycleEntryPointInput,

  type ProductionLifecycleEntryPointResult,

} from "./production-lifecycle-entry-point";

import type {

  GovernanceLifecyclePersistenceFunction,

} from "../../db/governance-lifecycle-composition";

import {

  persistGovernanceEnvelopeLifecycleTransition,

} from "../../db/governance-lifecycle-persistence";

import {

  createOperationalIntakeRecord,

  type CreateOperationalIntakeRecordInput,

  type OperationalIntakeRecord,

} from "../../db/operational-intake-runtime";

import {

  consumeOperationalIntakeForProduction,

  type ProductionOperationalConsumerInput,

  type ProductionOperationalConsumerResult,

} from "../operational/production-operational-consumer";

export type OperationalIntakeCreationFunction = (

  input: CreateOperationalIntakeRecordInput,

) => OperationalIntakeRecord;

export type ProductionOperationalConsumptionFunction = (

  input: ProductionOperationalConsumerInput,

) => ProductionOperationalConsumerResult;

export type ProductionLifecycleConsumerInput = Omit<

  ProductionLifecycleEntryPointInput,

  "persist_lifecycle_transition"

> & {

  db?: unknown;

  persist_lifecycle_transition?: GovernanceLifecyclePersistenceFunction;

  create_operational_intake?: OperationalIntakeCreationFunction;

  consume_operational_intake?: ProductionOperationalConsumptionFunction;

};

export type ProductionLifecycleConsumerResult =

  | {

      ok: true;

      entry: ProductionLifecycleEntryPointResult;

      operational_intake: OperationalIntakeRecord;

      operational_consumption: ProductionOperationalConsumerResult;

      findings: string[];

    }

  | {

      ok: false;

      entry: ProductionLifecycleEntryPointResult;

      operational_intake?: OperationalIntakeRecord;

      operational_consumption?: ProductionOperationalConsumerResult;

      findings: string[];

    };

function createDefaultLifecyclePersistence(

  db: unknown,

): GovernanceLifecyclePersistenceFunction {

  return ({ envelope_id, transition_authorization, persisted_at }) => {

    return persistGovernanceEnvelopeLifecycleTransition({

      envelope_id,

      transition_authorization,

      persisted_at,

      db: db as never,

    });

  };

}

export function consumeProductionLifecycleEntryPoint(

  input: ProductionLifecycleConsumerInput,

): ProductionLifecycleConsumerResult {

  const lifecycle = invokeProductionLifecycleEntryPoint({

    envelope_id: input.envelope_id,

    envelope: input.envelope,

    available_departments: input.available_departments ?? [],

    department_handshake: input.department_handshake,

    target_lifecycle_state: input.target_lifecycle_state,

    persisted_at: input.persisted_at,

    persist_lifecycle_transition:

      input.persist_lifecycle_transition ?? createDefaultLifecyclePersistence(input.db),

  });

  if (!lifecycle.ok) {

    return {

      ok: false,

      entry: lifecycle,

      findings: lifecycle.findings,

    };

  }

  const operationalIntakeCreator =

    input.create_operational_intake ?? createOperationalIntakeRecord;

  const operational_intake = operationalIntakeCreator({

    intake_id: `operational-intake:${lifecycle.lifecycle.persistence.envelope_id}`,

    envelope_id: lifecycle.lifecycle.persistence.envelope_id,

    assigned_department:

      lifecycle.lifecycle.assignment_boundary.ellis_decision.assigned_department,

    intake_created_at: lifecycle.lifecycle.persistence.persisted_at,

    db: input.db as never,

  });

  const operationalConsumer =

    input.consume_operational_intake ?? consumeOperationalIntakeForProduction;

  const operational_consumption = operationalConsumer({

    operational_intake,

  });

  if (!operational_consumption.ok) {

    return {

      ok: false,

      entry: lifecycle,

      operational_intake,

      operational_consumption,

      findings: [

        ...lifecycle.findings,

        "Production Lifecycle Consumer failed closed because Production Operational Consumer rejected Operational Intake.",

      ],

    };

  }

  return {

    ok: true,

    entry: lifecycle,

    operational_intake,

    operational_consumption,

    findings: [

      ...lifecycle.findings,

      "Production Lifecycle Consumer composed Operational Intake and downstream operational consumption after successful lifecycle persistence.",

    ],

  };

}

