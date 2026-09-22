export interface GovernanceDelegationRequest {
  delegation_id: string;
  project_id: string;
  package_id: string;
  package_version: number;
  authorization_state: "AUTHORIZED";
  authorization_timestamp: string;
  delegated_by: string;
}

type GovernanceDelegationRouteResult = {
  ok: boolean;
  findings?: string[];
};

function requireText(
  value: string,
  fieldName: string,
): string {
  const normalized = value.trim();

  if (!normalized) {
    throw new Error(`${fieldName} is required.`);
  }

  return normalized;
}

export async function delegateCanonicalPackage(
  input: GovernanceDelegationRequest,
): Promise<void> {
  const request: GovernanceDelegationRequest = {
    delegation_id: requireText(
      input.delegation_id,
      "delegation_id",
    ),
    project_id: requireText(input.project_id, "project_id"),
    package_id: requireText(input.package_id, "package_id"),
    package_version: input.package_version,
    authorization_state: "AUTHORIZED",
    authorization_timestamp: requireText(
      input.authorization_timestamp,
      "authorization_timestamp",
    ),
    delegated_by: requireText(input.delegated_by, "delegated_by"),
  };

  if (
    !Number.isInteger(request.package_version) ||
    request.package_version <= 0
  ) {
    throw new Error("package_version must be a positive integer.");
  }

  const response = await fetch("/api/governance/delegation", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(request),
  });

  const result =
    (await response.json()) as GovernanceDelegationRouteResult;

  if (!response.ok || !result.ok) {
    throw new Error(
      result.findings?.[0] ??
        "The Canonical Package could not be delegated.",
    );
  }
}
