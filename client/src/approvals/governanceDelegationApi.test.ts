import assert from "node:assert/strict";
import test from "node:test";

import {
  delegateCanonicalPackage,
} from "./governanceDelegationApi";

test("posts exact Canonical Package identity to existing governance delegation route", async () => {
  const originalFetch = globalThis.fetch;
  let capturedUrl: string | URL | Request | null = null;
  let capturedInit: RequestInit | undefined;

  globalThis.fetch = async (
    input: string | URL | Request,
    init?: RequestInit,
  ) => {
    capturedUrl = input;
    capturedInit = init;

    return new Response(
      JSON.stringify({
        ok: true,
        findings: [],
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );
  };

  try {
    await delegateCanonicalPackage({
      delegation_id: "delegation-test",
      project_id: "hq",
      package_id: "pkg-test",
      package_version: 7,
      authorization_state: "AUTHORIZED",
      authorization_timestamp: "2026-09-22T20:10:00.000Z",
      delegated_by: "marcela",
    });

    assert.equal(
      capturedUrl,
      "/api/governance/delegation",
    );
    assert.equal(capturedInit?.method, "POST");

    assert.deepEqual(
      JSON.parse(String(capturedInit?.body)),
      {
        delegation_id: "delegation-test",
        project_id: "hq",
        package_id: "pkg-test",
        package_version: 7,
        authorization_state: "AUTHORIZED",
        authorization_timestamp: "2026-09-22T20:10:00.000Z",
        delegated_by: "marcela",
      },
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("rejects invalid package version before any mutation request", async () => {
  const originalFetch = globalThis.fetch;
  let fetchCalled = false;

  globalThis.fetch = async () => {
    fetchCalled = true;
    throw new Error("fetch should not be called");
  };

  try {
    await assert.rejects(
      delegateCanonicalPackage({
        delegation_id: "delegation-test",
        project_id: "hq",
        package_id: "pkg-test",
        package_version: 0,
        authorization_state: "AUTHORIZED",
        authorization_timestamp: "2026-09-22T20:10:00.000Z",
        delegated_by: "marcela",
      }),
      /positive integer/,
    );

    assert.equal(fetchCalled, false);
  } finally {
    globalThis.fetch = originalFetch;
  }
});
