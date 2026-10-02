import {
  ollamaGenerate,
  type OllamaGenerateOptions,
} from "../../scripts/utils/ollamaGenerate.js";

import type {
  GovernanceValidationEvidence,
} from "./governance-validation-evidence-loader.js";

export type GovernanceValidationSemanticStatus =
  | "VALIDATION_PASSED"
  | "RESOLUTION_REQUIRED";

export type GovernanceValidationSemanticResult = {
  validation_status: GovernanceValidationSemanticStatus;
  governance_findings: string | null;
  operational_requirements: string | null;
  capability_requirements: string | null;
  escalations: string | null;
};

export type GovernanceValidationGenerationFunction = (
  input: OllamaGenerateOptions,
) => Promise<{ response: string }>;

export type GovernanceValidationSemanticAdapterOptions = {
  generate?: GovernanceValidationGenerationFunction;
};

const GOVERNANCE_VALIDATION_SCHEMA = {
  type: "object",
  properties: {
    validation_status: {
      type: "string",
      enum: ["VALIDATION_PASSED", "RESOLUTION_REQUIRED"],
    },
    governance_findings: {
      type: ["string", "null"],
    },
    operational_requirements: {
      type: ["string", "null"],
    },
    capability_requirements: {
      type: ["string", "null"],
    },
    escalations: {
      type: ["string", "null"],
    },
  },
  required: [
    "validation_status",
    "governance_findings",
    "operational_requirements",
    "capability_requirements",
    "escalations",
  ],
  additionalProperties: false,
} as const;

function normalizeOptionalText(value: unknown): string | null {
  if (value === null) {
    return null;
  }

  if (typeof value !== "string") {
    throw new Error("Governance Validation semantic result contains a non-text field.");
  }

  const normalized = value.trim();
  return normalized.length > 0 ? normalized : null;
}

function resolutionRequired(reason: string): GovernanceValidationSemanticResult {
  return {
    validation_status: "RESOLUTION_REQUIRED",
    governance_findings: reason,
    operational_requirements: null,
    capability_requirements: null,
    escalations: null,
  };
}

function requireSemanticEvidence(
  evidence: GovernanceValidationEvidence,
): string | null {
  const fields: Array<[string, string]> = [
    ["requested_outcome", evidence.package.requested_outcome],
    ["scope", evidence.package.scope],
    ["constraints", evidence.package.constraints],
    ["success_criteria", evidence.package.success_criteria],
  ];

  const missing = fields
    .filter(([, value]) => typeof value !== "string" || value.trim().length === 0)
    .map(([field]) => field);

  return missing.length > 0
    ? `Governance Validation requires complete semantic evidence; missing: ${missing.join(", ")}.`
    : null;
}

function buildPrompt(evidence: GovernanceValidationEvidence): string {
  return [
    "You are the semantic analysis component of Governance Validation.",
    "",
    "Evaluate only the supplied authorized governance evidence.",
    "Do not invent authority, requirements, scope, facts, or missing evidence.",
    "Return VALIDATION_PASSED only when the requested outcome, scope, constraints, and success criteria are semantically coherent, mutually compatible, and sufficiently specific to validate the bounded proposed work.",
    "Return RESOLUTION_REQUIRED when there is ambiguity, contradiction, missing semantic information, unresolved governance risk, or insufficient specificity.",
    "Do not authorize scheduling, routing, assignment, lifecycle transition, execution, downstream governance, or any new authority.",
    "",
    `Project ID: ${evidence.package.project_id}`,
    `Package ID: ${evidence.package.package_id}`,
    `Package Version: ${evidence.package.package_version}`,
    `Delegation ID: ${evidence.delegation.delegation_id}`,
    "",
    "REQUESTED OUTCOME:",
    evidence.package.requested_outcome,
    "",
    "SCOPE:",
    evidence.package.scope,
    "",
    "CONSTRAINTS:",
    evidence.package.constraints,
    "",
    "SUCCESS CRITERIA:",
    evidence.package.success_criteria,
  ].join("\n");
}

function parseSemanticResult(raw: string): GovernanceValidationSemanticResult {
  const parsed = JSON.parse(raw) as Record<string, unknown>;

  if (
    parsed === null
    || typeof parsed !== "object"
    || Array.isArray(parsed)
  ) {
    throw new Error("Governance Validation semantic result is not an object.");
  }

  const status = parsed.validation_status;

  if (
    status !== "VALIDATION_PASSED"
    && status !== "RESOLUTION_REQUIRED"
  ) {
    throw new Error(
      "Governance Validation semantic result contains an invalid validation_status.",
    );
  }

  return {
    validation_status: status,
    governance_findings: normalizeOptionalText(parsed.governance_findings),
    operational_requirements: normalizeOptionalText(parsed.operational_requirements),
    capability_requirements: normalizeOptionalText(parsed.capability_requirements),
    escalations: normalizeOptionalText(parsed.escalations),
  };
}

export async function analyzeGovernanceValidationSemantics(
  evidence: GovernanceValidationEvidence,
  options: GovernanceValidationSemanticAdapterOptions = {},
): Promise<GovernanceValidationSemanticResult> {
  const incompleteEvidence = requireSemanticEvidence(evidence);

  if (incompleteEvidence) {
    return resolutionRequired(incompleteEvidence);
  }

  const generate = options.generate ?? ollamaGenerate;

  try {
    const generation = await generate({
      prompt: buildPrompt(evidence),
      format: GOVERNANCE_VALIDATION_SCHEMA,
      options: {
        temperature: 0,
      },
    });

    return parseSemanticResult(generation.response);
  } catch (error) {
    return resolutionRequired(
      `Governance Validation semantic analysis failed closed: ${
        error instanceof Error ? error.message : String(error)
      }`,
    );
  }
}
