
import {

  invokeProductionLifecycleEntryPoint,

  type ProductionLifecycleEntryPointInput,

  type ProductionLifecycleEntryPointResult,

} from "./production-lifecycle-entry-point";

import type {

  GovernanceLifecyclePersistenceFunction,

} from "../../db/governance-lifecycle-composition";

declare const require: {

  (id: string): unknown;

};

type GovernanceLifecyclePersistenceModule =

  typeof import("../../db/governance-lifecycle-persistence");

export type ProductionLifecycleConsumerInput = Omit<

  ProductionLifecycleEntryPointInput,

  "persist_lifecycle_transition"

> & {

  db?: unknown;

  persist_lifecycle_transition?: GovernanceLifecyclePersistenceFunction;

};

export type ProductionLifecycleConsumerResult =

  ProductionLifecycleEntryPointResult;

function loadGovernanceLifecyclePersistence(): GovernanceLifecyclePersistenceModule {

  return require("../../db/governance-lifecycle-persistence") as GovernanceLifecyclePersistenceModule;

}

function createDefaultLifecyclePersistence(

  db: unknown,

): GovernanceLifecyclePersistenceFunction {

  return ({ envelope_id, transition_authorization, persisted_at }) => {

    const {

      persistGovernanceEnvelopeLifecycleTransition,

    } = loadGovernanceLifecyclePersistence();

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

  return invokeProductionLifecycleEntryPoint({

    envelope_id: input.envelope_id,

    envelope: input.envelope,

    available_departments: input.available_departments ?? [],

    available_actors: input.available_actors ?? [],

    target_lifecycle_state: input.target_lifecycle_state,

    persisted_at: input.persisted_at,

    persist_lifecycle_transition:

      input.persist_lifecycle_transition ??

      createDefaultLifecyclePersistence(input.db),

  });

}

