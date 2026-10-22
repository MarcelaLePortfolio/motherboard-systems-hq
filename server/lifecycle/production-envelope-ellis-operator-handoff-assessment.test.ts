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

test("assesses complete supplied evidence without granting authority", () => {
  const result = assessEnvelopeEllisOperatorHandoff(validInput);

  assert.equal(result.ok, true);
  assert.equal(result.assessment_ready, true);
  assert.equal(result.production_transition_authorized, false);
  assert.equal(result.assignment_authorized, false);
  assert.equal(result.lifecycle_transition_authorized, false);
  assert.equal(result.credential_issuance_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});

test("rejects mismatched canonical package lineage", () => {
  const result = assessEnvelopeEllisOperatorHandoff({
    ...validInput,
    envelope_package_version: 2,
  });

  assert.equal(result.ok, false);
  assert.equal(result.assessment_ready, false);
});

test("rejects ineligible department selection", () => {
  const result = assessEnvelopeEllisOperatorHandoff({
    ...validInput,
    selected_department_id: "finance",
  });

  assert.equal(result.ok, false);
});

test("rejects missing verified operator authorization", () => {
  const result = assessEnvelopeEllisOperatorHandoff({
    ...validInput,
    operator_authorization_verified: false,
  });

  assert.equal(result.ok, false);
});

test("rejects unverified departmental acknowledgement", () => {
  const result = assessEnvelopeEllisOperatorHandoff({
    ...validInput,
    department_acknowledgement_verified: false,
  });

  assert.equal(result.ok, false);
});

test("rejects unconfirmed departmental capability", () => {
  const result = assessEnvelopeEllisOperatorHandoff({
    ...validInput,
    department_capability_confirmed: false,
  });

  assert.equal(result.ok, false);
});

test("rejects envelopes outside ENVELOPE_CREATED", () => {
  const result = assessEnvelopeEllisOperatorHandoff({
    ...validInput,
    envelope_lifecycle_state: "ASSIGNED",
  });

  assert.equal(result.ok, false);
});
