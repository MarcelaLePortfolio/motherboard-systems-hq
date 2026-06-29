
export type EllisDecisionInput = {

  required_capabilities?: string | string[] | null;

  operational_corridor?: string | null;

  available_departments?: string[];

  available_actors?: string[];

};

export type EllisDecision =

  | {

      ok: true;

      decision_type: "assignment";

      assigned_department: string;

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

      decision_type: "assignment";

      escalation_required: true;

      findings: string[];

      mutation_authorized: false;

      execution_authorized: false;

      persistence_authorized: false;

      autonomous_authority: false;

      input_snapshot: {

        required_capabilities: string[];

        operational_corridor: string | null;

        available_departments: string[];

      };

    };

function normalizeCapabilities(

  value: EllisDecisionInput["required_capabilities"],

): string[] {

  if (Array.isArray(value)) {

    return value

      .map((item) => String(item).trim())

      .filter(Boolean);

  }

  if (typeof value === "string") {

    return value

      .split(",")

      .map((item) => item.trim())

      .filter(Boolean);

  }

  return [];

}

function normalizeCorridor(value: string | null | undefined): string | null {

  const normalized = value?.trim();

  return normalized || null;

}

function deny(

  findings: string[],

  input: {

    requiredCapabilities: string[];

    operationalCorridor: string | null;

    availableDepartments: string[];

  },

): Extract<EllisDecision, { ok: false }> {

  return {

    ok: false,

    decision_type: "assignment",

    escalation_required: true,

    findings,

    mutation_authorized: false,

    execution_authorized: false,

    persistence_authorized: false,

    autonomous_authority: false,

    input_snapshot: {

      required_capabilities: input.requiredCapabilities,

      operational_corridor: input.operationalCorridor,

      available_departments: input.availableDepartments,

    },

  };

}

export function evaluateEllisDecision(

  input: EllisDecisionInput,

): EllisDecision {

  const requiredCapabilities = normalizeCapabilities(input.required_capabilities);

  const operationalCorridor = normalizeCorridor(input.operational_corridor);

  const availableDepartments = (input.available_departments ?? [])

    .map((department) => department.trim())

    .filter(Boolean);

  if (requiredCapabilities.length === 0) {

    return deny(["Missing required_capabilities."], {

      requiredCapabilities,

      operationalCorridor,

      availableDepartments,

    });

  }

  if (!operationalCorridor) {

    return deny(["Missing operational_corridor."], {

      requiredCapabilities,

      operationalCorridor,

      availableDepartments,

    });

  }

  const assignedDepartment =

    availableDepartments.find((department) =>

      requiredCapabilities.includes(department),

    ) ??

    availableDepartments[0] ??

    null;

  if (!assignedDepartment) {

    return deny(["No available department can satisfy required_capabilities."], {

      requiredCapabilities,

      operationalCorridor,

      availableDepartments,

    });

  }

  return {

    ok: true,

    decision_type: "assignment",

    assigned_department: assignedDepartment,

    ownership_basis:

      "Department selected from available_departments within required_capabilities.",

    routing_basis:

      "Non-mutating Ellis V1 coordination decision over Envelope inputs.",

    required_capabilities: requiredCapabilities,

    operational_corridor: operationalCorridor,

    escalation_required: false,

    findings: ["Ellis V1 returned a non-mutating departmental coordination decision."],

    mutation_authorized: false,

    execution_authorized: false,

    persistence_authorized: false,

    autonomous_authority: false,

  };

}

