
import {

  invokeEllisFromEnvelope,

  type EllisEnvelopeShape,

} from "./invocation";

import type { EllisDecision } from "./decision";

export type DepartmentAssignmentHandshake = {

  acknowledgement_status: "ACKNOWLEDGED";

  capability_status: "CAPABILITY_CONFIRMED" | "CAPABILITY_CONFLICT_REPORTED";

  capability_conflicts?: string[];

  response_basis: string;

};

type DepartmentalEllisDecision = Omit<

  Extract<EllisDecision, { ok: true }>,

  "assigned_actor"

> & {

  assigned_actor?: never;

};

export type GovernanceLifecycleAssignmentBoundaryInput = {

  envelope: EllisEnvelopeShape & {

    lifecycle_state?: string | null;

  };

  available_departments?: string[];

  available_actors?: string[];

  department_handshake?: DepartmentAssignmentHandshake;

};

export type GovernanceLifecycleAssignmentBoundaryResult =

  | {

      ok: true;

      boundary: "governance_lifecycle_assignment";

      assignment_ready: true;

      department_acknowledged: true;

      capability_status: "CAPABILITY_CONFIRMED";

      requires_ellis_recoordination: false;

      lifecycle_transition_authorized: false;

      mutation_authorized: false;

      persistence_authorized: false;

      execution_authorized: false;

      actor_assignment_authorized: false;

      participation_resolution_authorized: false;

      ellis_decision: DepartmentalEllisDecision;

      findings: string[];

    }

  | {

      ok: false;

      boundary: "governance_lifecycle_assignment";

      assignment_ready: false;

      department_acknowledged: false;

      capability_status?: "CAPABILITY_CONFIRMED" | "CAPABILITY_CONFLICT_REPORTED";

      requires_ellis_recoordination: boolean;

      lifecycle_transition_authorized: false;

      mutation_authorized: false;

      persistence_authorized: false;

      execution_authorized: false;

      actor_assignment_authorized: false;

      participation_resolution_authorized: false;

      ellis_decision?: EllisDecision | DepartmentalEllisDecision;

      findings: string[];

    };

function normalizeLifecycleState(value: string | null | undefined): string {

  return String(value ?? "")

    .trim()

    .toUpperCase()

    .replaceAll(" ", "_")

    .replaceAll("-", "_");

}

function removeActorAssignment(

  ellisDecision: Extract<EllisDecision, { ok: true }>,

): DepartmentalEllisDecision {

  const { assigned_actor: _assignedActor, ...departmentalDecision } =

    ellisDecision as Extract<EllisDecision, { ok: true }> & {

      assigned_actor?: string | null;

    };

  return Object.freeze(departmentalDecision) as DepartmentalEllisDecision;

}

function block(

  findings: string[],

  ellisDecision?: EllisDecision | DepartmentalEllisDecision,

  options: {

    capability_status?: "CAPABILITY_CONFIRMED" | "CAPABILITY_CONFLICT_REPORTED";

    requires_ellis_recoordination?: boolean;

  } = {},

): GovernanceLifecycleAssignmentBoundaryResult {

  return {

    ok: false,

    boundary: "governance_lifecycle_assignment",

    assignment_ready: false,

    department_acknowledged: false,

    capability_status: options.capability_status,

    requires_ellis_recoordination:

      options.requires_ellis_recoordination ?? false,

    lifecycle_transition_authorized: false,

    mutation_authorized: false,

    persistence_authorized: false,

    execution_authorized: false,

    actor_assignment_authorized: false,

    participation_resolution_authorized: false,

    ellis_decision: ellisDecision,

    findings,

  };

}

function evaluateDepartmentHandshake(

  handshake: DepartmentAssignmentHandshake | undefined,

):

  | {

      ok: true;

      capability_status: "CAPABILITY_CONFIRMED";

      findings: string[];

    }

  | {

      ok: false;

      capability_status?: "CAPABILITY_CONFIRMED" | "CAPABILITY_CONFLICT_REPORTED";

      requires_ellis_recoordination: boolean;

      findings: string[];

    } {

  if (!handshake) {

    return {

      ok: false,

      requires_ellis_recoordination: false,

      findings: [

        "Department acknowledgement is required before assignment readiness is complete.",

      ],

    };

  }

  if (handshake.acknowledgement_status !== "ACKNOWLEDGED") {

    return {

      ok: false,

      requires_ellis_recoordination: false,

      findings: ["Department acknowledgement_status must be ACKNOWLEDGED."],

    };

  }

  if (

    handshake.capability_status !== "CAPABILITY_CONFIRMED" &&

    handshake.capability_status !== "CAPABILITY_CONFLICT_REPORTED"

  ) {

    return {

      ok: false,

      requires_ellis_recoordination: false,

      findings: ["Department capability_status is invalid."],

    };

  }

  if (!handshake.response_basis || typeof handshake.response_basis !== "string") {

    return {

      ok: false,

      capability_status: handshake.capability_status,

      requires_ellis_recoordination: false,

      findings: ["Department response_basis is required."],

    };

  }

  if (handshake.capability_status === "CAPABILITY_CONFLICT_REPORTED") {

    const conflicts = handshake.capability_conflicts ?? [];

    if (!Array.isArray(conflicts) || conflicts.length === 0) {

      return {

        ok: false,

        capability_status: handshake.capability_status,

        requires_ellis_recoordination: true,

        findings: ["Capability conflict requires capability_conflicts evidence."],

      };

    }

    return {

      ok: false,

      capability_status: handshake.capability_status,

      requires_ellis_recoordination: true,

      findings: [

        "Department acknowledged accountability but reported capability conflict; Ellis re-coordination required.",

      ],

    };

  }

  return {

    ok: true,

    capability_status: "CAPABILITY_CONFIRMED",

    findings: ["Department acknowledged accountability and confirmed capability."],

  };

}

export function evaluateGovernanceLifecycleAssignmentBoundary(

  input: GovernanceLifecycleAssignmentBoundaryInput,

): GovernanceLifecycleAssignmentBoundaryResult {

  const lifecycleState = normalizeLifecycleState(input.envelope.lifecycle_state);

  if (lifecycleState !== "ENVELOPE_CREATED") {

    return block([

      `Assignment boundary requires lifecycle_state=ENVELOPE_CREATED; received ${

        lifecycleState || "MISSING"

      }.`,

    ]);

  }

  const ellisDecision = invokeEllisFromEnvelope({

    envelope: input.envelope,

    available_departments: input.available_departments ?? [],

    available_actors: [],

  });

  if (!ellisDecision.ok) {

    return block(["Ellis could not resolve assignment readiness."], ellisDecision);

  }

  const departmentalEllisDecision = removeActorAssignment(ellisDecision);

  const handshake = evaluateDepartmentHandshake(input.department_handshake);

  if (!handshake.ok) {

    return block(handshake.findings, departmentalEllisDecision, {

      capability_status: handshake.capability_status,

      requires_ellis_recoordination: (handshake as any).requires_ellis_recoordination,

    });

  }

  return {

    ok: true,

    boundary: "governance_lifecycle_assignment",

    assignment_ready: true,

    department_acknowledged: true,

    capability_status: handshake.capability_status,

    requires_ellis_recoordination: false,

    lifecycle_transition_authorized: false,

    mutation_authorized: false,

    persistence_authorized: false,

    execution_authorized: false,

    actor_assignment_authorized: false,

    participation_resolution_authorized: false,

    ellis_decision: departmentalEllisDecision,

    findings: [

      "Assignment readiness established after Ellis departmental assignment and department capability confirmation.",

    ],

  };

}

