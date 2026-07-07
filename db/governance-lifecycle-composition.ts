
import {

  evaluateGovernanceLifecycleAssignmentBoundary,

  type DepartmentAssignmentHandshake,

  type GovernanceLifecycleAssignmentBoundaryInput,

  type GovernanceLifecycleAssignmentBoundaryResult,

} from "../server/ellis/assignment-boundary.js";

import {

  authorizeGovernanceLifecycleAssignmentTransition,

  type GovernanceLifecycleTransitionAuthorizationResult,

} from "../server/ellis/lifecycle-transition-authorization.js";

export type GovernanceLifecyclePersistenceResult = {

  envelope_id: string;

  previous_lifecycle_state: "ENVELOPE_CREATED";

  lifecycle_state: "ASSIGNED";

  transition: "ENVELOPE_CREATED_TO_ASSIGNED";

  persisted_at: string;

  mutation_authorized: false;

  execution_authorized: false;

};

export type GovernanceLifecyclePersistenceFunction = (input: {

  envelope_id: string;

  transition_authorization: Extract<

    GovernanceLifecycleTransitionAuthorizationResult,

    { ok: true }

  >;

  persisted_at?: string | null;

}) => GovernanceLifecyclePersistenceResult;

export type ComposeGovernanceLifecycleAssignmentTransitionInput = {

  envelope_id: string;

  envelope: GovernanceLifecycleAssignmentBoundaryInput["envelope"];

  available_departments?: string[];

  available_actors?: string[];

  department_handshake?: DepartmentAssignmentHandshake;

  target_lifecycle_state?: string | null;

  persisted_at?: string | null;

  persist: GovernanceLifecyclePersistenceFunction;

};

export type ComposedGovernanceLifecycleAssignmentTransitionResult =

  | {

      ok: true;

      integration: "governance_lifecycle_assignment_transition";

      assignment_boundary: Extract<

        GovernanceLifecycleAssignmentBoundaryResult,

        { ok: true }

      >;

      transition_authorization: Extract<

        GovernanceLifecycleTransitionAuthorizationResult,

        { ok: true }

      >;

      persistence: GovernanceLifecyclePersistenceResult;

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

      assignment_boundary?: GovernanceLifecycleAssignmentBoundaryResult;

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

    throw new Error(`Missing governance lifecycle composition field: ${label}`);

  }

  return normalized;

}

export function composeGovernanceLifecycleAssignmentTransition(

  input: ComposeGovernanceLifecycleAssignmentTransitionInput,

): ComposedGovernanceLifecycleAssignmentTransitionResult {

  const envelope_id = requireText(input.envelope_id, "envelope_id");

  const targetLifecycleState = input.target_lifecycle_state ?? "ASSIGNED";

  const assignmentBoundary = evaluateGovernanceLifecycleAssignmentBoundary({

    envelope: input.envelope,

    available_departments: input.available_departments ?? [],

    available_actors: input.available_actors ?? [],

    department_handshake: input.department_handshake,

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

        "Lifecycle composition stopped before transition authorization because assignment readiness was not established.",

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

        "Lifecycle composition stopped before persistence because transition authorization was not established.",

      ],

    };

  }

  const persistence = input.persist({

    envelope_id,

    transition_authorization: transitionAuthorization,

    persisted_at: input.persisted_at,

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

      "Lifecycle composition completed department-handshake-gated assignment readiness, transition authorization, and injected persistence without native database loading.",

    ],

  };

}

