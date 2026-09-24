import assert from "node:assert/strict";
import test from "node:test";

import { postGovernanceEnvelope } from "./governanceEnvelopeApi";

test("posts only exact retained lineage to existing Envelope route", async () => {
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
        envelope: {
          envelope: {
            envelope_id: "envelope-1",
            package_id: "package-1",
            package_version: 4,
            delegation_id: "delegation-1",
            validation_result_id: "validation-1",
            envelope_gate_id: "gate-1",
            validation_status: "VALIDATION_PASSED",
            lifecycle_state: "ENVELOPE_CREATED",
            created_at: "2026-09-24T00:01:00.000Z",
          },
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
    await postGovernanceEnvelope({
      envelope_id: "envelope-1",
      package_id: "package-1",
      package_version: 4,
      delegation_id: "delegation-1",
      validation_result_id: "validation-1",
      envelope_gate_id: "gate-1",
    });

    assert.equal(requestUrl, "/api/governance/envelope");
    assert.equal(requestInit?.method, "POST");

    assert.deepEqual(
      JSON.parse(String(requestInit?.body)),
      {
        envelope_id: "envelope-1",
        package_id: "package-1",
        package_version: 4,
        delegation_id: "delegation-1",
        validation_result_id: "validation-1",
        envelope_gate_id: "gate-1",
        lifecycle_state: "ENVELOPE_CREATED",
      },
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("rejects missing exact Gate lineage before fetch", async () => {
  const originalFetch = globalThis.fetch;
  let fetchCalled = false;

  globalThis.fetch = (async () => {
    fetchCalled = true;
    throw new Error("fetch must not be called");
  }) as typeof fetch;

  try {
    await assert.rejects(
      postGovernanceEnvelope({
        envelope_id: "envelope-1",
        package_id: "package-1",
        package_version: 4,
        delegation_id: "delegation-1",
        validation_result_id: "validation-1",
        envelope_gate_id: " ",
      }),
      /Envelope Gate id is required/,
    );

    assert.equal(fetchCalled, false);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("surfaces Envelope route failure", async () => {
  const originalFetch = globalThis.fetch;

  globalThis.fetch = (async () =>
    new Response(
      JSON.stringify({
        findings: [
          "Governance Envelope route failed closed because the production Envelope consumer rejected the request.",
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
      postGovernanceEnvelope({
        envelope_id: "envelope-1",
        package_id: "package-1",
        package_version: 4,
        delegation_id: "delegation-1",
        validation_result_id: "validation-1",
        envelope_gate_id: "gate-1",
      }),
      /production Envelope consumer rejected the request/,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});
