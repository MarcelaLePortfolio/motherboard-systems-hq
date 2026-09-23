import assert from "node:assert/strict";
import test from "node:test";

import { analyzeGovernanceValidation } from "./governance-validation-analysis.ts";

test("fails closed when package requirements are incomplete", () => {
  const result = analyzeGovernanceValidation({
    package_id: "pkg-1",
    package_version: 1,
    delegation_id: "delegation-1",
    requested_outcome: "",
    success_criteria: [],
    constraints: [],
  });

  assert.equal(result.validation_status, "RESOLUTION_REQUIRED");
  assert.ok(result.governance_findings.length > 0);
});

test("structural completeness cannot manufacture PASS", () => {
  const result = analyzeGovernanceValidation({
    package_id: "pkg-1",
    package_version: 1,
    delegation_id: "delegation-1",
    requested_outcome: "Deliver the delegated outcome.",
    success_criteria: ["Outcome complete."],
    constraints: ["Preserve governance boundaries."],
  });

  assert.equal(result.validation_status, "RESOLUTION_REQUIRED");
  assert.deepEqual(result.capability_requirements, []);
  assert.match(result.escalations.join(" "), /before PASS/i);
});

test("analysis result contains no downstream authority", () => {
  const result = analyzeGovernanceValidation({
    package_id: "pkg-1",
    package_version: 1,
    delegation_id: "delegation-1",
    requested_outcome: "Deliver outcome.",
    success_criteria: ["Complete."],
    constraints: ["Governed."],
  });

  assert.equal("routing_authorized" in result, false);
  assert.equal("assignment_authorized" in result, false);
  assert.equal("scheduler_authorized" in result, false);
  assert.equal("execution_authorized" in result, false);
});
