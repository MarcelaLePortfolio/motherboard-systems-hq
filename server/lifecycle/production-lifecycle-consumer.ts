
import {

  invokeProductionLifecycleEntryPoint,

  type ProductionLifecycleEntryPointInput,

  type ProductionLifecycleEntryPointResult,

} from "./production-lifecycle-entry-point.ts";

import type {

  GovernanceLifecyclePersistenceFunction,

} from "../../db/governance-lifecycle-composition.ts";

import {

  persistGovernanceEnvelopeLifecycleTransition,

} from "../../db/governance-lifecycle-persistence.ts";

import {

  createOperationalIntakeRecord,

  type CreateOperationalIntakeRecordInput,

  type OperationalIntakeRecord,

} from "../../db/operational-intake-runtime.ts";

export type OperationalIntakeCreationFunction = (

  input: CreateOperationalIntakeRecordInput,

) => OperationalIntakeRecord;

export type ProductionLifecycleConsumerInput = Omit<

  ProductionLifecycleEntryPointInput,

  "persist_lifecycle_transition"

> & {

  db?: unknown;

  persist_lifecycle_transition?: GovernanceLifecyclePersistenceFunction;

  create_operational_intake?: OperationalIntakeCreationFunction;

};

export type ProductionLifecycleConsumerResult =

  | (Extract<ProductionLifecycleEntryPointResult, { ok: true }> & {

      operational_intake: OperationalIntakeRecord;

    })

  | Extract<ProductionLifecycleEntryPointResult, { ok: false }>;

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

    return lifecycle;

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

  return {

    ...lifecycle,

    operational_intake,

    findings: [

      ...lifecycle.findings,

      "Production Lifecycle Consumer composed Operational Intake after successful lifecycle persistence without scheduler, worker, orchestration, routing, execution, actor assignment, participation resolution, or new authority.",

    ],

  };

}

