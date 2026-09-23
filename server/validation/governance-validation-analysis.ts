export type GovernanceValidationAnalysisInput = {
  package_id: string;
  package_version: number;
  delegation_id: string;
  requested_outcome: string;
  success_criteria: unknown;
  constraints: unknown;
};

export type GovernanceValidationAnalysisResult = {
  validation_status: "RESOLUTION_REQUIRED";
  governance_findings: string[];
  operational_requirements: string[];
  capability_requirements: string[];
  escalations: string[];
};

function present(value: unknown): boolean {
  if (typeof value === "string") return value.trim().length > 0;
  if (Array.isArray(value)) return value.length > 0;
  return value !== null && value !== undefined;
}

export function analyzeGovernanceValidation(
  input: GovernanceValidationAnalysisInput,
): GovernanceValidationAnalysisResult {
  const governance_findings: string[] = [];

  if (!input.package_id.trim()) governance_findings.push("Package identity is missing.");
  if (!Number.isInteger(input.package_version) || input.package_version < 1)
    governance_findings.push("Package version is invalid.");
  if (!input.delegation_id.trim()) governance_findings.push("Delegation identity is missing.");
  if (!present(input.requested_outcome))
    governance_findings.push("Requested outcome is incomplete.");
  if (!present(input.success_criteria))
    governance_findings.push("Success criteria are incomplete.");
  if (!present(input.constraints))
    governance_findings.push("Constraints are incomplete.");

  if (governance_findings.length === 0) {
    governance_findings.push(
      "Structural prerequisites are present, but PASS requires authoritative governance analysis and capability derivation.",
    );
  }

  return {
    validation_status: "RESOLUTION_REQUIRED",
    governance_findings,
    operational_requirements: [],
    capability_requirements: [],
    escalations: [
      "Authoritative Governance Validation analysis is required before PASS may be issued.",
    ],
  };
}
