
import test from "node:test";

import assert from "node:assert/strict";

import {

  invokeProductionValidationEntryPoint,

  type GovernanceValidationPersistenceFunction,

} from "./production-validation-entry-point";

const fakeCreateValidation: GovernanceValidationPersistenceFunction = (input) => ({

  validation_result_id: input.validation_result_id,

  package_id: input.package_id,

  package_version: input.package_version,

  delegation_id: input.delegation_id,

  validation_status: input.validation_status,

  validation_timestamp:

    input.validation_timestamp ?? "2026-06-26T23:18:30.000Z",

  created_at: "2026-06-26T23:18:30.000Z",

});

test("production Validation entry point creates only the canonical Validation Result", () => {

  const result = invokeProductionValidationEntryPoint({

    validation_result_id: "validation-entry-point-success",

    package_id: "pkg-validation-entry-point-success",

    package_version: 1,

    delegation_id: "delegation-validation-entry-point-success",

    validation_status: "VALIDATION_PASSED",

    governance_findings: "No blockers",

    operational_requirements: "None",

    capability_requirements: "engineering",

    escalations: null,

    validation_timestamp: "2026-06-26T23:18:30.000Z",

    create_governance_validation_result: fakeCreateValidation,

  });

  assert.equal(result.ok, true);

  assert.equal(result.entry_point, "production_validation_entry_point");

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.assignment_authorized, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.downstream_governance_authorized, false);

  assert.equal(result.new_authority_introduced, false);

  if (!result.ok) {

    assert.fail("Expected Validation entry point to succeed.");

  }

  assert.equal(result.validation.validation_result_id, "validation-entry-point-success");

});

test("production Validation entry point fails closed when persistence rejects input", () => {

  const result = invokeProductionValidationEntryPoint({

    validation_result_id: "",

    package_id: "pkg-validation-entry-point-fail",

    package_version: 1,

    delegation_id: "delegation-validation-entry-point-fail",

    validation_status: "VALIDATION_PASSED",

    create_governance_validation_result: () => {

      throw new Error("validation_result_id is required");

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.entry_point, "production_validation_entry_point");

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.assignment_authorized, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.downstream_governance_authorized, false);

  assert.equal(result.new_authority_introduced, false);

  assert.match(result.findings.join("\n"), /validation_result_id is required/);

});

