import assert from "node:assert/strict";
import test from "node:test";

import {
  analyzeGovernanceValidationSemantics,
} from "./governance-validation-semantic-adapter.ts";

function completeEvidence() {
  return {
    delegation: {
      delegation_id: "delegation-1",
      project_id: "hq",
      package_id: "pkg-1",
      package_version: 1,
      authorization_state: "AUTHORIZED",
    },
    package: {
      project_id: "hq",
      package_id: "pkg-1",
      package_version: 1,
      requested_outcome: "Deliver the approved bounded outcome.",
      scope: "Only the approved implementation corridor.",
      constraints: "Preserve all governance and authority boundaries.",
      success_criteria: "The bounded implementation passes its specified tests.",
    },
  };
}

test("semantic adapter accepts a schema-valid VALIDATION_PASSED result", async () => {
  const result = await analyzeGovernanceValidationSemantics(
    completeEvidence(),
    {
      generate: async () => ({
        response: JSON.stringify({
          validation_status: "VALIDATION_PASSED",
          governance_findings: "Evidence is coherent and sufficiently specific.",
          operational_requirements: null,
          capability_requirements: null,
          escalations: null,
        }),
      }),
    },
  );

  assert.equal(result.validation_status, "VALIDATION_PASSED");
  assert.equal(
    result.governance_findings,
    "Evidence is coherent and sufficiently specific.",
  );
});

test("semantic adapter preserves a schema-valid RESOLUTION_REQUIRED result", async () => {
  const result = await analyzeGovernanceValidationSemantics(
    completeEvidence(),
    {
      generate: async () => ({
        response: JSON.stringify({
          validation_status: "RESOLUTION_REQUIRED",
          governance_findings: "Scope remains semantically ambiguous.",
          operational_requirements: "Clarify the bounded operation.",
          capability_requirements: null,
          escalations: null,
        }),
      }),
    },
  );

  assert.equal(result.validation_status, "RESOLUTION_REQUIRED");
  assert.equal(
    result.operational_requirements,
    "Clarify the bounded operation.",
  );
});

test("semantic adapter does not invoke model when required evidence is incomplete", async () => {
  let invoked = false;
  const evidence = completeEvidence();
  evidence.package.success_criteria = "";

  const result = await analyzeGovernanceValidationSemantics(
    evidence,
    {
      generate: async () => {
        invoked = true;
        throw new Error("must not execute");
      },
    },
  );

  assert.equal(invoked, false);
  assert.equal(result.validation_status, "RESOLUTION_REQUIRED");
  assert.match(result.governance_findings ?? "", /success_criteria/i);
});

test("semantic adapter fails closed when transport fails", async () => {
  const result = await analyzeGovernanceValidationSemantics(
    completeEvidence(),
    {
      generate: async () => {
        throw new Error("Ollama unavailable");
      },
    },
  );

  assert.equal(result.validation_status, "RESOLUTION_REQUIRED");
  assert.match(result.governance_findings ?? "", /Ollama unavailable/i);
});

test("semantic adapter fails closed on malformed JSON", async () => {
  const result = await analyzeGovernanceValidationSemantics(
    completeEvidence(),
    {
      generate: async () => ({
        response: "not-json",
      }),
    },
  );

  assert.equal(result.validation_status, "RESOLUTION_REQUIRED");
});

test("semantic adapter fails closed on unauthorized model status", async () => {
  const result = await analyzeGovernanceValidationSemantics(
    completeEvidence(),
    {
      generate: async () => ({
        response: JSON.stringify({
          validation_status: "EXECUTION_AUTHORIZED",
          governance_findings: null,
          operational_requirements: null,
          capability_requirements: null,
          escalations: null,
        }),
      }),
    },
  );

  assert.equal(result.validation_status, "RESOLUTION_REQUIRED");
  assert.match(result.governance_findings ?? "", /invalid validation_status/i);
});
