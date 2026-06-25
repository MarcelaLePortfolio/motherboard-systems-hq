
export type EllisDecisionInput = {

  required_capabilities: string[];

  operational_corridor: string;

  available_departments?: string[];

  available_actors?: string[];

};

export type EllisDecision =

  | {

      ok: true;

      decision_type: "assignment";

      assigned_department: string;

      assigned_actor: string | null;

      ownership_basis: string;

      routing_basis: string;

      required_capabilities: string[];

      operational_corridor: string;

      escalation_required: false;

      findings: string[];

      mutation_authorized: false;

      execution_authorized: false;

      persistence_authorized: false;

      autonomous_authority: false;

    }

  | {

      ok: false;

      decision_type: "escalation";

      escalation_target: "Governance Validation";

      findings: string[];

      required_capabilities: string[];

      operational_corridor: string;

      mutation_authorized: false;

      execution_authorized: false;

      persistence_authorized: false;

      autonomous_authority: false;

    };

function normalizeList(values: string[] | undefined): string[] {

  return (values ?? []).map((value) => value.trim()).filter(Boolean);

}

function deny(findings: string[], input: EllisDecisionInput): EllisDecision {

  return {

    ok: false,

    decision_type: "escalation",

    escalation_target: "Governance Validation",

    findings,

    required_capabilities: normalizeList(input.required_capabilities),

    operational_corridor: input.operational_corridor?.trim() ?? "",

    mutation_authorized: false,

    execution_authorized: false,

    persistence_authorized: false,

    autonomous_authority: false,

  };

}

export function evaluateEllisDecision(input: EllisDecisionInput): EllisDecision {

  const requiredCapabilities = normalizeList(input.required_capabilities);

  const operationalCorridor = input.operational_corridor?.trim() ?? "";

  const availableDepartments = normalizeList(input.available_departments);

  const availableActors = normalizeList(input.available_actors);

  if (requiredCapabilities.length === 0) {

    return deny(["Missing required_capabilities."], input);

  }

  if (!operationalCorridor) {

    return deny(["Missing operational_corridor."], input);

  }

  const assignedDepartment =

    availableDepartments.find((department) => requiredCapabilities.includes(department)) ??

    availableDepartments[0] ??

    null;

  if (!assignedDepartment) {

    return deny(["No available department can satisfy required_capabilities."], input);

  }

  return {

    ok: true,

    decision_type: "assignment",

    assigned_department: assignedDepartment,

    assigned_actor: availableActors[0] ?? null,

    ownership_basis: "Department selected from available_departments within required_capabilities.",

    routing_basis: "Non-mutating Ellis V1 coordination decision over Envelope inputs.",

    required_capabilities: requiredCapabilities,

    operational_corridor: operationalCorridor,

    escalation_required: false,

    findings: ["Ellis V1 returned a non-mutating coordination decision."],

    mutation_authorized: false,

    execution_authorized: false,

    persistence_authorized: false,

    autonomous_authority: false,

  };

}

