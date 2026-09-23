import test from "node:test";
import assert from "node:assert/strict";

import { consumeProductionValidationEntryPoint } from "./production-validation-consumer";

function authorizedDelegation(identity: {
  delegation_id: string;
  package_id: string;
  package_version: number;
}) {
  return {
    delegation_id: identity.delegation_id,
    package_id: identity.package_id,
    package_version: identity.package_version,
    authorization_state: "AUTHORIZED",
  };
}

test("production Validation consumer invokes Validation entry point with injected persistence", () => {
  const result = consumeProductionValidationEntryPoint({
    validation_result_id: "validation-consumer-success",
    package_id: "pkg-validation-consumer-success",
    package_version: 1,
    delegation_id: "delegation-validation-consumer-success",
    validation_status: "VALIDATION_PASSED",
    validation_timestamp: "2026-06-26T23:18:30.000Z",
    load_exact_governance_delegation: authorizedDelegation,
    create_governance_validation_result: (input) => ({
      validation_result_id: input.validation_result_id,
      package_id: input.package_id,
      package_version: input.package_version,
      delegation_id: input.delegation_id,
      validation_status: input.validation_status,
      validation_timestamp:
        input.validation_timestamp ?? "2026-06-26T23:18:30.000Z",
      created_at: "2026-06-26T23:18:30.000Z",
    }),
  });

  assert.equal(result.ok, true);
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
});

test("production Validation consumer fails closed before downstream authority", () => {
  const result = consumeProductionValidationEntryPoint({
    validation_result_id: "validation-consumer-fail",
    package_id: "pkg-validation-consumer-fail",
    package_version: 1,
    delegation_id: "delegation-validation-consumer-fail",
    validation_status: "",
    load_exact_governance_delegation: authorizedDelegation,
    create_governance_validation_result: () => {
      throw new Error("validation_status is required");
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
});

test("production Validation consumer fails closed before persistence when Delegation is missing", () => {
  let persistenceCalls = 0;

  const result = consumeProductionValidationEntryPoint({
    validation_result_id: "validation-consumer-missing",
    package_id: "pkg-validation-consumer-missing",
    package_version: 1,
    delegation_id: "delegation-validation-consumer-missing",
    validation_status: "VALIDATION_PASSED",
    load_exact_governance_delegation: () => {
      throw new Error("Governance Validation delegation not found or ambiguous.");
    },
    create_governance_validation_result: () => {
      persistenceCalls += 1;
      throw new Error("persistence must not run");
    },
  });

  assert.equal(result.ok, false);
  assert.equal(persistenceCalls, 0);
  assert.match(result.findings.join("\n"), /not found or ambiguous/i);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});

test("production Validation consumer fails closed before persistence when Delegation is unauthorized", () => {
  let persistenceCalls = 0;

  const result = consumeProductionValidationEntryPoint({
    validation_result_id: "validation-consumer-unauthorized",
    package_id: "pkg-validation-consumer-unauthorized",
    package_version: 1,
    delegation_id: "delegation-validation-consumer-unauthorized",
    validation_status: "VALIDATION_PASSED",
    load_exact_governance_delegation: (identity) => ({
      delegation_id: identity.delegation_id,
      package_id: identity.package_id,
      package_version: identity.package_version,
      authorization_state: "PENDING",
    }),
    create_governance_validation_result: () => {
      persistenceCalls += 1;
      throw new Error("persistence must not run");
    },
  });

  assert.equal(result.ok, false);
  assert.equal(persistenceCalls, 0);
  assert.match(result.findings.join("\n"), /not authorized/i);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});

test("production Validation consumer persists exactly once for exact AUTHORIZED Delegation", () => {
  let persistenceCalls = 0;

  const result = consumeProductionValidationEntryPoint({
    validation_result_id: "validation-consumer-authorized",
    package_id: "pkg-validation-consumer-authorized",
    package_version: 1,
    delegation_id: "delegation-validation-consumer-authorized",
    validation_status: "VALIDATION_PASSED",
    load_exact_governance_delegation: authorizedDelegation,
    create_governance_validation_result: (input) => {
      persistenceCalls += 1;

      return {
        validation_result_id: input.validation_result_id,
        package_id: input.package_id,
        package_version: input.package_version,
        delegation_id: input.delegation_id,
        validation_status: input.validation_status,
        validation_timestamp:
          input.validation_timestamp ?? "2026-06-26T23:18:30.000Z",
        created_at: "2026-06-26T23:18:30.000Z",
      };
    },
  });

  assert.equal(result.ok, true);
  assert.equal(persistenceCalls, 1);
  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.assignment_authorized, false);
  assert.equal(result.lifecycle_transition_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.downstream_governance_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});
