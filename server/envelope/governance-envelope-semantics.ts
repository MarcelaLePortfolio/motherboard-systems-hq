import type {
  GovernanceEnvelopeCreationValidationRecord,
} from "../../db/governance-envelope-creation-read-repository.js";

export type GovernanceEnvelopeSemantics = {
  required_capabilities: string;
  operational_corridor: string;
};

function requireSemanticText(value: string | null, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(
      `Authoritative Governance Envelope semantic field is missing: ${field}`,
    );
  }

  return value.trim();
}

export function resolveGovernanceEnvelopeSemantics(
  validationResult: GovernanceEnvelopeCreationValidationRecord,
): GovernanceEnvelopeSemantics {
  return {
    required_capabilities: requireSemanticText(
      validationResult.capability_requirements,
      "capability_requirements",
    ),
    operational_corridor: requireSemanticText(
      validationResult.operational_requirements,
      "operational_requirements",
    ),
  };
}
