import assert from "node:assert/strict";
import test from "node:test";

import {
  assessEnvelopeEllisOperatorHandoff,
  type EnvelopeEllisOperatorHandoffAssessmentInput,
} from "./production-envelope-ellis-operator-handoff-assessment.js";

const validInput: EnvelopeEllisOperatorHandoffAssessmentInput = {
  envelope_id: "env-1",
  envelope_lifecycle_state: "ENVELOPE_CREATED",
  package_id: "pkg-1",
  package_version: 1,
  envelope_package_id: "pkg-1",
  envelope_package_version: 1,
  selected_department_id: "engineering",
  eligible_department_ids: ["engineering"],
  operator_authorization_id: "authorization-1",
  operator_authorization_verified: true,
  department_acknowledgement_verified: true,
  department_capability_confirmed: true,
};

function assertNoAuthority(
  result: ReturnType<typeof assessEnvelopeEllisOperatorHandoff>,
): void {
  assert.equal(result.production_transition_authorized, false);
  assert.equal(result.assignment_authorized, false);
  assert.equal(result.lifecycle_transition_authorized, false);
  assert.equal(result.credential_issuance_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
}

test("assesses complete supplied assertions without granting authority", () => {
  const result = assessEnvelopeEllisOperatorHandoff(validInput);

  assert.equal(result.ok, true);
  assert.equal(result.assessment_ready, true);
  assertNoAuthority(result);

  assert.ok(
    result.findings.some((finding) =>
      finding.includes("not been independently verified"),
    ),
  );

  assert.ok(
    result.findings.some((finding) =>
      finding.includes("must not be used as a trusted lifecycle"),
    ),
  );
});

test("rejects mismatched canonical package lineage", () => {
  const result = assessEnvelopeEllisOperatorHandoff({
    ...validInput,
    envelope_package_version: 2,
  });

  assert.equal(result.ok, false);
  assert.equal(result.assessment_ready, false);
  assertNoAuthority(result);
});

test("rejects ineligible department selection", () => {
  const result = assessEnvelopeEllisOperatorHandoff({
    ...validInput,
    selected_department_id: "finance",
  });

  assert.equal(result.ok, false);
  assertNoAuthority(result);
});

test("rejects missing verified operator authorization assertion", () => {
  const result = assessEnvelopeEllisOperatorHandoff({
    ...validInput,
    operator_authorization_verified: false,
  });

  assert.equal(result.ok, false);
  assertNoAuthority(result);
});

test("rejects unverified departmental acknowledgement assertion", () => {
  const result = assessEnvelopeEllisOperatorHandoff({
    ...validInput,
    department_acknowledgement_verified: false,
  });

  assert.equal(result.ok, false);
  assertNoAuthority(result);
});

test("rejects unconfirmed departmental capability assertion", () => {
  const result = assessEnvelopeEllisOperatorHandoff({
    ...validInput,
    department_capability_confirmed: false,
  });

  assert.equal(result.ok, false);
  assertNoAuthority(result);
});

test("rejects envelopes outside ENVELOPE_CREATED", () => {
  const result = assessEnvelopeEllisOperatorHandoff({
    ...validInput,
    envelope_lifecycle_state: "ASSIGNED",
  });

  assert.equal(result.ok, false);
  assertNoAuthority(result);
});

test("rejects missing operator authorization identifier", () => {
  const result = assessEnvelopeEllisOperatorHandoff({
    ...validInput,
    operator_authorization_id: " ",
  });

  assert.equal(result.ok, false);
  assertNoAuthority(result);
});

test("rejects missing envelope identity", () => {
  const result = assessEnvelopeEllisOperatorHandoff({
    ...validInput,
    envelope_id: " ",
  });

  assert.equal(result.ok, false);
  assertNoAuthority(result);
});

test("rejects malformed package versions", () => {
  for (const version of [0, -1, 1.5, Number.NaN, Number.POSITIVE_INFINITY]) {
    const result = assessEnvelopeEllisOperatorHandoff({
      ...validInput,
      package_version: version,
    });

    assert.equal(result.ok, false);
    assertNoAuthority(result);
  }
});

test("rejects non-boolean verification assertions", () => {
  for (const value of ["true", 1, null, undefined]) {
    const result = assessEnvelopeEllisOperatorHandoff({
      ...validInput,
      operator_authorization_verified: value as never,
    });

    assert.equal(result.ok, false);
    assertNoAuthority(result);
  }
});

test("rejects malformed runtime eligibility lists", () => {
  const result = assessEnvelopeEllisOperatorHandoff({
    ...validInput,
    eligible_department_ids: null as never,
  });

  assert.equal(result.ok, false);
  assertNoAuthority(result);
});

test("rejects malformed runtime authorization identifiers", () => {
  const result = assessEnvelopeEllisOperatorHandoff({
    ...validInput,
    operator_authorization_id: 123 as never,
  });

  assert.equal(result.ok, false);
  assertNoAuthority(result);
});
