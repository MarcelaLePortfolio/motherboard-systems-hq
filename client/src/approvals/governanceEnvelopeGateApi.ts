export type GovernanceEnvelopeGateInput = {
  gate_id: string;
  validation_result_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
};

export type GovernanceEnvelopeGateRecord = {
  envelope_gate_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_result_id: string;
  gate_status: string;
  gate_reason: string | null;
  gate_decision_timestamp: string | null;
  created_at: string;
};

export type GovernanceEnvelopeGateSuccess = {
  ok: true;
  envelope_gate: GovernanceEnvelopeGateRecord;
};

export async function postGovernanceEnvelopeGate(
  input: GovernanceEnvelopeGateInput,
): Promise<GovernanceEnvelopeGateSuccess> {
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
      envelope_gate_id: gate_id,
      validation_result_id,
      package_id,
      package_version: input.package_version,
      delegation_id,
      gate_status: "OPEN",
      gate_reason: null,
      gate_decision_timestamp: new Date().toISOString(),
    }),
  });

  const payload = (await response.json().catch(() => null)) as
    | GovernanceEnvelopeGateSuccess
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
        `Governance Envelope Gate request failed with status ${response.status}.`,
    );
  }

  if (
    !payload ||
    !("ok" in payload) ||
    payload.ok !== true ||
    !("envelope_gate" in payload) ||
    !payload.envelope_gate?.envelope_gate_id?.trim()
  ) {
    throw new Error(
      "Governance Envelope Gate success response did not include the exact persisted Envelope Gate id.",
    );
  }

  return payload;
}
