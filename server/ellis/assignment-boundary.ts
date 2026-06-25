
import {

  invokeEllisFromEnvelope,

  type EllisEnvelopeShape,

} from "./invocation";

import type { EllisDecision } from "./decision";

export type GovernanceLifecycleAssignmentBoundaryInput = {

  envelope: EllisEnvelopeShape & {

    lifecycle_state?: string | null;

  };

  available_departments?: string[];

  available_actors?: string[];

};

export type GovernanceLifecycleAssignmentBoundaryResult =

  | {

      ok: true;

      boundary: "governance_lifecycle_assignment";

      assignment_ready: true;

      lifecycle_transition_authorized: false;

      mutation_authorized: false;

      persistence_authorized: false;

      execution_authorized: false;

      ellis_decision: Extract<EllisDecision, { ok: true }>;

      findings: string[];

    }

  | {

      ok: false;

      boundary: "governance_lifecycle_assignment";

      assignment_ready: false;

      lifecycle_transition_authorized: false;

      mutation_authorized: false;

      persistence_authorized: false;

      execution_authorized: false;

      ellis_decision?: EllisDecision;

      findings: string[];

    };

function normalizeLifecycleState(value: string | null | undefined): string {

  return String(value ?? "").trim().toUpperCase().replaceAll(" ", "_").replaceAll("-", "_");

}

function block(

  findings: string[],

  ellisDecision?: EllisDecision,

): GovernanceLifecycleAssignmentBoundaryResult {

  return {

    ok: false,

    boundary: "governance_lifecycle_assignment",

    assignment_ready: false,

    lifecycle_transition_authorized: false,

    mutation_authorized: false,

    persistence_authorized: false,

    execution_authorized: false,

    ellis_decision: ellisDecision,

    findings,

  };

}

export function evaluateGovernanceLifecycleAssignmentBoundary(

  input: GovernanceLifecycleAssignmentBoundaryInput,

): GovernanceLifecycleAssignmentBoundaryResult {

  const lifecycleState = normalizeLifecycleState(input.envelope.lifecycle_state);

  if (lifecycleState !== "ENVELOPE_CREATED") {

    return block([

      `Assignment boundary requires lifecycle_state=ENVELOPE_CREATED; received ${lifecycleState || "MISSING"}.`,

    ]);

  }

  const ellisDecision = invokeEllisFromEnvelope({

    envelope: input.envelope,

    available_departments: input.available_departments ?? [],

    available_actors: input.available_actors ?? [],

  });

  if (!ellisDecision.ok) {

    return block(

      ["Ellis could not resolve assignment readiness."],

      ellisDecision,

    );

  }

  return {

    ok: true,

    boundary: "governance_lifecycle_assignment",

    assignment_ready: true,

    lifecycle_transition_authorized: false,

    mutation_authorized: false,

    persistence_authorized: false,

    execution_authorized: false,

    ellis_decision: ellisDecision,

    findings: [

      "Assignment readiness established without lifecycle mutation or persistence.",

    ],

  };

}

