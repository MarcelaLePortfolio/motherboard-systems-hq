
import type { GovernanceLifecycleAssignmentBoundaryResult } from "./assignment-boundary.ts";

export type GovernanceLifecycleTransitionAuthorizationInput = {

  current_lifecycle_state: string | null | undefined;

  target_lifecycle_state: string | null | undefined;

  assignment_boundary: GovernanceLifecycleAssignmentBoundaryResult;

};

export type GovernanceLifecycleTransitionAuthorizationResult =

  | {

      ok: true;

      transition_authorized: true;

      transition: "ENVELOPE_CREATED_TO_ASSIGNED";

      from: "ENVELOPE_CREATED";

      to: "ASSIGNED";

      mutation_authorized: false;

      persistence_authorized: false;

      execution_authorized: false;

      findings: string[];

    }

  | {

      ok: false;

      transition_authorized: false;

      transition: "ENVELOPE_CREATED_TO_ASSIGNED";

      from: string;

      to: string;

      mutation_authorized: false;

      persistence_authorized: false;

      execution_authorized: false;

      findings: string[];

    };

function normalizeLifecycleState(value: string | null | undefined): string {

  return String(value ?? "").trim().toUpperCase().replaceAll(" ", "_").replaceAll("-", "_");

}

export function authorizeGovernanceLifecycleAssignmentTransition(

  input: GovernanceLifecycleTransitionAuthorizationInput,

): GovernanceLifecycleTransitionAuthorizationResult {

  const from = normalizeLifecycleState(input.current_lifecycle_state);

  const to = normalizeLifecycleState(input.target_lifecycle_state);

  if (from !== "ENVELOPE_CREATED" || to !== "ASSIGNED") {

    return {

      ok: false,

      transition_authorized: false,

      transition: "ENVELOPE_CREATED_TO_ASSIGNED",

      from: from || "MISSING",

      to: to || "MISSING",

      mutation_authorized: false,

      persistence_authorized: false,

      execution_authorized: false,

      findings: [

        `Transition authorization requires ENVELOPE_CREATED -> ASSIGNED; received ${from || "MISSING"} -> ${to || "MISSING"}.`,

      ],

    };

  }

  if (!input.assignment_boundary.ok || !input.assignment_boundary.assignment_ready) {

    return {

      ok: false,

      transition_authorized: false,

      transition: "ENVELOPE_CREATED_TO_ASSIGNED",

      from,

      to,

      mutation_authorized: false,

      persistence_authorized: false,

      execution_authorized: false,

      findings: [

        "Transition authorization requires assignment readiness from the governance lifecycle assignment boundary.",

      ],

    };

  }

  return {

    ok: true,

    transition_authorized: true,

    transition: "ENVELOPE_CREATED_TO_ASSIGNED",

    from: "ENVELOPE_CREATED",

    to: "ASSIGNED",

    mutation_authorized: false,

    persistence_authorized: false,

    execution_authorized: false,

    findings: [

      "Lifecycle transition authorization established without mutation or persistence.",

    ],

  };

}

