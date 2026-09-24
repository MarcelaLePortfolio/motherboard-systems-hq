export type GovernanceEnvelopeGateInput = {
  gate_id: string;
  validation_result_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
};

export async function postGovernanceEnvelopeGate(
  input: GovernanceEnvelopeGateInput,
): Promise<unknown> {
  const gate_id = input.gate_id.trim();
  const validation_result_id = input.validation_result_id.trim();
  const package_id = input.package_id.trim();
  const delegation_id = input.delegation_id.trim();

  if (!gate_id) {
    throw new Error("Envelope Gate id is required.");
  }

  if (!validation_result_id) {
    throw new Error("Validation result id is required.");
  }

  if (!package_id) {
    throw new Error("Package id is required.");
  }

  if (
    !Number.isInteger(input.package_version) ||
    input.package_version < 1
  ) {
    throw new Error("Package version must be a positive integer.");
  }

  if (!delegation_id) {
    throw new Error("Delegation id is required.");
  }

  const response = await fetch("/api/governance/envelope-gate", {
    method: "POST",
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify({
      gate_id,
      validation_result_id,
      package_id,
      package_version: input.package_version,
      delegation_id,
    }),
  });

  const payload = (await response.json().catch(() => null)) as
    | { error?: string; findings?: string[] }
    | null;

  if (!response.ok) {
    const finding = payload?.findings?.[0]?.trim();
    const error = payload?.error?.trim();

    throw new Error(
      finding ||
        error ||
        `Governance Envelope Gate request failed with status ${response.status}.`,
    );
  }

  return payload;
}
