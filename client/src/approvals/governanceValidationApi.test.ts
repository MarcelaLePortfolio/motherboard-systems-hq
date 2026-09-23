import assert from "node:assert/strict";
import test from "node:test";

import {
  submitGovernanceValidation,
} from "./governanceValidationApi";

const validInput = {
  validation_result_id: "validation-result-test",
  package_id: "pkg-test",
  package_version: 7,
  delegation_id: "delegation-test",
  validation_status: "VALIDATION_PASSED",
};

test("posts exact Validation identity to existing governance Validation route", async () => {
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
        headers: { "Content-Type": "application/json" },
      },
    );
  };

  try {
    await submitGovernanceValidation(validInput);

    assert.equal(capturedUrl, "/api/governance/validation");
    assert.equal(capturedInit?.method, "POST");
    assert.deepEqual(
      JSON.parse(String(capturedInit?.body)),
      validInput,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("rejects invalid Validation identity before fetch", async () => {
  const originalFetch = globalThis.fetch;
  let fetchCalled = false;

  globalThis.fetch = async () => {
    fetchCalled = true;
    throw new Error("fetch should not be called");
  };

  try {
    await assert.rejects(
      submitGovernanceValidation({
        ...validInput,
        delegation_id: "",
      }),
      /delegation_id is required/,
    );

    assert.equal(fetchCalled, false);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("surfaces governance Validation route failure", async () => {
  const originalFetch = globalThis.fetch;

  globalThis.fetch = async () =>
    new Response(
      JSON.stringify({
        ok: false,
        findings: ["Validation rejected."],
      }),
      {
        status: 400,
        headers: { "Content-Type": "application/json" },
      },
    );

  try {
    await assert.rejects(
      submitGovernanceValidation(validInput),
      /Validation rejected/,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});
