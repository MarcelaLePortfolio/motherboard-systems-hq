import test from "node:test";
import assert from "node:assert/strict";

import {
  resolveGovernanceEnvelopeSemantics,
} from "./governance-envelope-semantics.js";

const validation = {
  validation_result_id: "validation-1",
  package_id: "package-1",
  package_version: 1,
  delegation_id: "delegation-1",
  validation_status: "VALIDATION_PASSED",
  governance_findings: null,
  operational_requirements: " planning_only ",
  capability_requirements: " engineering_planning ",
  escalations: null,
  validation_timestamp: "2026-09-24T00:00:00.000Z",
  created_at: "2026-09-24T00:00:00.000Z",
};

test("uses only lossless trim-only semantic transformation", () => {
  assert.deepEqual(resolveGovernanceEnvelopeSemantics(validation), {
    required_capabilities: "engineering_planning",
    operational_corridor: "planning_only",
  });
});

test("fails closed without required capabilities", () => {
  assert.throws(() =>
    resolveGovernanceEnvelopeSemantics({
      ...validation,
      capability_requirements: " ",
    }),
  );
});

test("fails closed without operational corridor source", () => {
  assert.throws(() =>
    resolveGovernanceEnvelopeSemantics({
      ...validation,
      operational_requirements: null,
    }),
  );
});
