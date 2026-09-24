export type GovernanceEnvelopeInput = {
  envelope_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_result_id: string;
  envelope_gate_id: string;
};

export type GovernanceEnvelopeSuccess = {
  ok: true;
  envelope: {
    envelope: {
      envelope_id: string;
      package_id: string;
      package_version: number;
      delegation_id: string;
      validation_result_id: string;
      envelope_gate_id: string;
      validation_status: string;
      lifecycle_state: string;
      created_at: string;
    };
  };
};

export async function postGovernanceEnvelope(
  input: GovernanceEnvelopeInput,
): Promise<GovernanceEnvelopeSuccess> {
  const envelope_id = input.envelope_id.trim();
  const package_id = input.package_id.trim();
  const delegation_id = input.delegation_id.trim();
  const validation_result_id = input.validation_result_id.trim();
  const envelope_gate_id = input.envelope_gate_id.trim();

  if (!envelope_id) {
    throw new Error("Envelope id is required.");
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

  if (!validation_result_id) {
    throw new Error("Validation result id is required.");
  }

  if (!envelope_gate_id) {
    throw new Error("Envelope Gate id is required.");
  }

  const response = await fetch("/api/governance/envelope", {
    method: "POST",
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify({
      envelope_id,
      package_id,
      package_version: input.package_version,
      delegation_id,
      validation_result_id,
      envelope_gate_id,
      lifecycle_state: "ENVELOPE_CREATED",
    }),
  });

  const payload = (await response.json().catch(() => null)) as
    | GovernanceEnvelopeSuccess
    | { error?: string; findings?: string[] }
    | null;

  if (!response.ok) {
    const finding =
      payload && "findings" in payload
        ? payload.findings?.[0]?.trim()
        : undefined;
    const error =
      payload && "error" in payload
        ? payload.error?.trim()
        : undefined;

    throw new Error(
      finding ||
        error ||
        `Governance Envelope request failed with status ${response.status}.`,
    );
  }

  if (
    !payload ||
    !("ok" in payload) ||
    payload.ok !== true ||
    !("envelope" in payload)
  ) {
    throw new Error(
      "Governance Envelope success response was incomplete.",
    );
  }

  return payload;
}
