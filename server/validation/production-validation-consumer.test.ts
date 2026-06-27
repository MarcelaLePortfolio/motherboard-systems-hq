
import test from "node:test";

import assert from "node:assert/strict";

import { consumeProductionValidationEntryPoint } from "./production-validation-consumer";

test("production Validation consumer invokes Validation entry point with injected persistence", () => {

  const result = consumeProductionValidationEntryPoint({

    validation_result_id: "validation-consumer-success",

    package_id: "pkg-validation-consumer-success",

    package_version: 1,

    delegation_id: "delegation-validation-consumer-success",

    validation_status: "VALIDATION_PASSED",

    validation_timestamp: "2026-06-26T23:18:30.000Z",

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

