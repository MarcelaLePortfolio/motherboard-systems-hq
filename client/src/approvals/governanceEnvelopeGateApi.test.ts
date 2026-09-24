import assert from "node:assert/strict";
import test from "node:test";

import { postGovernanceEnvelopeGate } from "./governanceEnvelopeGateApi";

test("posts exact Validation lineage and returns exact persisted Gate id", async () => {
  const originalFetch = globalThis.fetch;
  let requestUrl = "";
  let requestInit: RequestInit | undefined;

  globalThis.fetch = (async (
    input: string | URL | Request,
    init?: RequestInit,
  ) => {
    requestUrl =
      typeof input === "string"
        ? input
        : input instanceof URL
          ? input.toString()
          : input.url;
    requestInit = init;

    return new Response(
      JSON.stringify({
        ok: true,
        envelope_gate: {
          envelope_gate_id: "gate-1",
          package_id: "package-1",
          package_version: 4,
          delegation_id: "delegation-1",
          validation_result_id: "validation-1",
          gate_status: "OPEN",
          gate_reason: null,
          gate_decision_timestamp: "2026-09-24T00:00:00.000Z",
          created_at: "2026-09-24T00:00:00.000Z",
        },
      }),
      {
        status: 200,
        headers: {
          "content-type": "application/json",
        },
      },
    );
  }) as typeof fetch;

  try {
    const result = await postGovernanceEnvelopeGate({
      gate_id: "gate-1",
      validation_result_id: "validation-1",
      package_id: "package-1",
      package_version: 4,
      delegation_id: "delegation-1",
    });

    assert.equal(requestUrl, "/api/governance/envelope-gate");
    assert.equal(requestInit?.method, "POST");

    const body = JSON.parse(String(requestInit?.body));

    assert.equal(body.envelope_gate_id, "gate-1");
    assert.equal(body.validation_result_id, "validation-1");
    assert.equal(body.package_id, "package-1");
    assert.equal(body.package_version, 4);
    assert.equal(body.delegation_id, "delegation-1");
    assert.equal(body.gate_status, "OPEN");
    assert.equal(body.gate_reason, null);
    assert.equal(
      typeof body.gate_decision_timestamp,
      "string",
    );

    assert.equal(
      result.envelope_gate.envelope_gate_id,
      "gate-1",
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("fails closed when successful Gate response omits exact persisted Gate id", async () => {
  const originalFetch = globalThis.fetch;

  globalThis.fetch = (async () =>
    new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: {
        "content-type": "application/json",
      },
    })) as typeof fetch;

  try {
    await assert.rejects(
      postGovernanceEnvelopeGate({
        gate_id: "gate-1",
        validation_result_id: "validation-1",
        package_id: "package-1",
        package_version: 4,
        delegation_id: "delegation-1",
      }),
      /exact persisted Envelope Gate id/,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("rejects missing Validation lineage before fetch", async () => {
  const originalFetch = globalThis.fetch;
  let fetchCalled = false;

  globalThis.fetch = (async () => {
    fetchCalled = true;
    throw new Error("fetch must not be called");
  }) as typeof fetch;

  try {
    await assert.rejects(
      postGovernanceEnvelopeGate({
        gate_id: "gate-1",
        validation_result_id: " ",
        package_id: "package-1",
        package_version: 4,
        delegation_id: "delegation-1",
      }),
      /Validation result id is required/,
    );

    assert.equal(fetchCalled, false);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("surfaces Envelope Gate route failure", async () => {
  const originalFetch = globalThis.fetch;

  globalThis.fetch = (async () =>
    new Response(
      JSON.stringify({
        findings: [
          "Validation result is not eligible for Envelope Gate.",
        ],
      }),
      {
        status: 409,
        headers: {
          "content-type": "application/json",
        },
      },
    )) as typeof fetch;

  try {
    await assert.rejects(
      postGovernanceEnvelopeGate({
        gate_id: "gate-1",
        validation_result_id: "validation-1",
        package_id: "package-1",
        package_version: 4,
        delegation_id: "delegation-1",
      }),
      /Validation result is not eligible for Envelope Gate/,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});
