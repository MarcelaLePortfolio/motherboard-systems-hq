export type GovernanceValidationRequest = {
  validation_result_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_status: string;
  governance_findings?: string | null;
  operational_requirements?: string | null;
  capability_requirements?: string | null;
  escalations?: string | null;
};

export type GovernanceValidationResponse = {
  ok: boolean;
  findings?: string[];
  [key: string]: unknown;
};

function requireText(value: string, field: string): string {
  const normalized = value.trim();
  if (!normalized) {
    throw new Error(`${field} is required.`);
  }
  return normalized;
}

export async function submitGovernanceValidation(
  input: GovernanceValidationRequest,
  fetchImpl: typeof fetch = fetch,
): Promise<GovernanceValidationResponse> {
  const request = {
    ...input,
    validation_result_id: requireText(
      input.validation_result_id,
      "validation_result_id",
    ),
    package_id: requireText(input.package_id, "package_id"),
    delegation_id: requireText(input.delegation_id, "delegation_id"),
    validation_status: requireText(input.validation_status, "validation_status"),
  };

  if (!Number.isInteger(request.package_version) || request.package_version <= 0) {
    throw new Error("package_version must be a positive integer.");
  }

  const response = await fetchImpl("/api/governance/validation", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(request),
  });

  const result =
    (await response.json()) as GovernanceValidationResponse;

  if (!response.ok || !result.ok) {
    throw new Error(
      result.findings?.[0] ?? "Governance Validation failed closed.",
    );
  }

  return result;
}
