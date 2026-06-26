
import Database from "better-sqlite3";

import {

  evaluateGovernanceLifecycleAssignmentBoundary,

  type GovernanceLifecycleAssignmentBoundaryInput,

  type GovernanceLifecycleAssignmentBoundaryResult,

} from "../server/ellis/assignment-boundary";

import {

  authorizeGovernanceLifecycleAssignmentTransition,

  type GovernanceLifecycleTransitionAuthorizationResult,

} from "../server/ellis/lifecycle-transition-authorization";

import {

  persistGovernanceEnvelopeLifecycleTransition,

  type PersistedGovernanceEnvelopeLifecycleTransition,

} from "./governance-lifecycle-persistence";

export type CompleteGovernanceLifecycleAssignmentTransitionInput = {

  envelope_id: string;

  envelope: GovernanceLifecycleAssignmentBoundaryInput["envelope"];

  available_departments?: string[];

  available_actors?: string[];

  target_lifecycle_state?: string | null;

  persisted_at?: string | null;

  db?: Database.Database;

};

export type CompletedGovernanceLifecycleAssignmentTransitionResult =

  | {

      ok: true;

      integration: "governance_lifecycle_assignment_transition";

      assignment_boundary: Extract<GovernanceLifecycleAssignmentBoundaryResult, { ok: true }>;

      transition_authorization: Extract<GovernanceLifecycleTransitionAuthorizationResult, { ok: true }>;

      persistence: PersistedGovernanceEnvelopeLifecycleTransition;

      production_runtime_caller: false;

      endpoint_authorized: false;

      scheduler_authorized: false;

      worker_claim_authorized: false;

      execution_authorized: false;

      findings: string[];

    }

  | {

      ok: false;

      integration: "governance_lifecycle_assignment_transition";

      assignment_boundary: GovernanceLifecycleAssignmentBoundaryResult;

      transition_authorization?: GovernanceLifecycleTransitionAuthorizationResult;

      persistence?: never;

      production_runtime_caller: false;

      endpoint_authorized: false;

      scheduler_authorized: false;

      worker_claim_authorized: false;

      execution_authorized: false;

      findings: string[];

    };

function requireText(value: string | null | undefined, label: string): string {

  const normalized = value?.trim();

  if (!normalized) {

    throw new Error(`Missing governance lifecycle integration field: ${label}`);

  }

  return normalized;

}

export function completeGovernanceLifecycleAssignmentTransition(

  input: CompleteGovernanceLifecycleAssignmentTransitionInput,

): CompletedGovernanceLifecycleAssignmentTransitionResult {

  const envelope_id = requireText(input.envelope_id, "envelope_id");

  const targetLifecycleState = input.target_lifecycle_state ?? "ASSIGNED";

  const assignmentBoundary = evaluateGovernanceLifecycleAssignmentBoundary({

    envelope: input.envelope,

    available_departments: input.available_departments ?? [],

    available_actors: input.available_actors ?? [],

  });

  if (!assignmentBoundary.ok) {

    return {

      ok: false,

      integration: "governance_lifecycle_assignment_transition",

      assignment_boundary: assignmentBoundary,

      production_runtime_caller: false,

      endpoint_authorized: false,

      scheduler_authorized: false,

      worker_claim_authorized: false,

      execution_authorized: false,

      findings: [

        "Lifecycle integration stopped before transition authorization because assignment readiness was not established.",

      ],

    };

  }

  const transitionAuthorization = authorizeGovernanceLifecycleAssignmentTransition({

    current_lifecycle_state: input.envelope.lifecycle_state,

    target_lifecycle_state: targetLifecycleState,

    assignment_boundary: assignmentBoundary,

  });

  if (!transitionAuthorization.ok) {

    return {

      ok: false,

      integration: "governance_lifecycle_assignment_transition",

      assignment_boundary: assignmentBoundary,

      transition_authorization: transitionAuthorization,

      production_runtime_caller: false,

      endpoint_authorized: false,

      scheduler_authorized: false,

      worker_claim_authorized: false,

      execution_authorized: false,

      findings: [

        "Lifecycle integration stopped before persistence because transition authorization was not established.",

      ],

    };

  }

  const persistence = persistGovernanceEnvelopeLifecycleTransition({

    envelope_id,

    transition_authorization: transitionAuthorization,

    persisted_at: input.persisted_at,

    db: input.db,

  });

  return {

    ok: true,

    integration: "governance_lifecycle_assignment_transition",

    assignment_boundary: assignmentBoundary,

    transition_authorization: transitionAuthorization,

    persistence,

    production_runtime_caller: false,

    endpoint_authorized: false,

    scheduler_authorized: false,

    worker_claim_authorized: false,

    execution_authorized: false,

    findings: [

      "Lifecycle integration completed assignment readiness, transition authorization, and lifecycle persistence without production runtime wiring.",

    ],

  };

}

