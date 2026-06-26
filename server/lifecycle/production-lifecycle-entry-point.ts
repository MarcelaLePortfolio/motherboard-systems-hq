
import {

  composeGovernanceLifecycleAssignmentTransition,

  type ComposeGovernanceLifecycleAssignmentTransitionInput,

  type ComposedGovernanceLifecycleAssignmentTransitionResult,

  type GovernanceLifecyclePersistenceFunction,

} from "../../db/governance-lifecycle-composition";

export type ProductionLifecycleEntryPointInput = Omit<

  ComposeGovernanceLifecycleAssignmentTransitionInput,

  "persist"

> & {

  persist_lifecycle_transition: GovernanceLifecyclePersistenceFunction;

};

export type ProductionLifecycleEntryPointResult =

  | {

      ok: true;

      entry_point: "production_lifecycle_entry_point";

      lifecycle: Extract<ComposedGovernanceLifecycleAssignmentTransitionResult, { ok: true }>;

      endpoint_authorized: false;

      scheduler_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      routing_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    }

  | {

      ok: false;

      entry_point: "production_lifecycle_entry_point";

      lifecycle?: ComposedGovernanceLifecycleAssignmentTransitionResult;

      endpoint_authorized: false;

      scheduler_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      routing_authorized: false;

      execution_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

export function invokeProductionLifecycleEntryPoint(

  input: ProductionLifecycleEntryPointInput,

): ProductionLifecycleEntryPointResult {

  try {

    const lifecycle = composeGovernanceLifecycleAssignmentTransition({

      envelope_id: input.envelope_id,

      envelope: input.envelope,

      available_departments: input.available_departments ?? [],

      available_actors: input.available_actors ?? [],

      target_lifecycle_state: input.target_lifecycle_state,

      persisted_at: input.persisted_at,

      persist: input.persist_lifecycle_transition,

    });

    if (!lifecycle.ok) {

      return {

        ok: false,

        entry_point: "production_lifecycle_entry_point",

        lifecycle,

        endpoint_authorized: false,

        scheduler_authorized: false,

        worker_claim_authorized: false,

        orchestration_authorized: false,

        routing_authorized: false,

        execution_authorized: false,

        new_authority_introduced: false,

        findings: [

          "Production Lifecycle Entry Point failed closed because lifecycle composition rejected the transition.",

        ],

      };

    }

    return {

      ok: true,

      entry_point: "production_lifecycle_entry_point",

      lifecycle,

      endpoint_authorized: false,

      scheduler_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      routing_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Production Lifecycle Entry Point invoked native-free lifecycle composition without endpoint, scheduler, worker, orchestration, routing, execution, or new authority.",

      ],

    };

  } catch (error) {

    return {

      ok: false,

      entry_point: "production_lifecycle_entry_point",

      endpoint_authorized: false,

      scheduler_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      routing_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        `Production Lifecycle Entry Point failed closed: ${

          error instanceof Error ? error.message : String(error)

        }`,

      ],

    };

  }

}

