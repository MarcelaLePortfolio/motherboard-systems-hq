
import type Database from "better-sqlite3";

import {

  completeGovernanceLifecycleAssignmentTransition,

  type CompleteGovernanceLifecycleAssignmentTransitionInput,

  type CompletedGovernanceLifecycleAssignmentTransitionResult,

} from "../../db/governance-lifecycle-integration";

export type ProductionLifecycleEntryPointInput = {

  envelope_id: string;

  envelope: CompleteGovernanceLifecycleAssignmentTransitionInput["envelope"];

  available_departments?: string[];

  available_actors?: string[];

  target_lifecycle_state?: string | null;

  persisted_at?: string | null;

  db?: Database.Database;

};

export type ProductionLifecycleEntryPointResult =

  | {

      ok: true;

      entry_point: "production_lifecycle_entry_point";

      lifecycle: Extract<CompletedGovernanceLifecycleAssignmentTransitionResult, { ok: true }>;

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

      lifecycle?: CompletedGovernanceLifecycleAssignmentTransitionResult;

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

    const lifecycle = completeGovernanceLifecycleAssignmentTransition({

      envelope_id: input.envelope_id,

      envelope: input.envelope,

      available_departments: input.available_departments ?? [],

      available_actors: input.available_actors ?? [],

      target_lifecycle_state: input.target_lifecycle_state,

      persisted_at: input.persisted_at,

      db: input.db,

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

          "Production Lifecycle Entry Point failed closed because the lifecycle integration caller rejected the transition.",

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

        "Production Lifecycle Entry Point invoked the existing lifecycle integration caller without endpoint, scheduler, worker, orchestration, routing, or execution authority.",

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

