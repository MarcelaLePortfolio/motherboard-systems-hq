
import test from "node:test";

import assert from "node:assert/strict";

import {

  invokeProductionEnvelopeEntryPoint,

  type GovernanceEnvelopePersistenceFunction,

} from "./production-envelope-entry-point";

const fakeCreateEnvelope: GovernanceEnvelopePersistenceFunction = (input) => ({

  envelope_id: input.envelope_id,

  package_id: input.package_id,

  package_version: input.package_version,

  delegation_id: input.delegation_id,

  validation_result_id: input.validation_result_id,

  envelope_gate_id: input.envelope_gate_id,

  validation_status: input.validation_status,

  lifecycle_state: input.lifecycle_state,

  created_at: "2026-06-26T23:48:49.000Z",

});

test("production Envelope entry point creates only the canonical Envelope record", () => {

  const result = invokeProductionEnvelopeEntryPoint({

    envelope_id: "envelope-entry-point-success",

    package_id: "pkg-envelope-entry-point-success",

    package_version: 1,

    delegation_id: "delegation-envelope-entry-point-success",

    validation_result_id: "validation-envelope-entry-point-success",

    envelope_gate_id: "gate-envelope-entry-point-success",

    validation_status: "VALIDATION_PASSED",

    required_capabilities: "engineering",

    operational_corridor: "envelope test",

    lifecycle_state: "ENVELOPE_CREATED",

    create_governance_envelope: fakeCreateEnvelope,

  });

  assert.equal(result.ok, true);

  assert.equal(result.entry_point, "production_envelope_entry_point");

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.assignment_authorized, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

  if (!result.ok) assert.fail("Expected Envelope entry point to succeed.");

  assert.equal(result.envelope.envelope_id, "envelope-entry-point-success");

});

test("production Envelope entry point fails closed when persistence rejects input", () => {

  const result = invokeProductionEnvelopeEntryPoint({

    envelope_id: "",

    package_id: "pkg-envelope-entry-point-fail",

    package_version: 1,

    delegation_id: "delegation-envelope-entry-point-fail",

    validation_result_id: "validation-envelope-entry-point-fail",

    envelope_gate_id: "gate-envelope-entry-point-fail",

    validation_status: "VALIDATION_PASSED",

    lifecycle_state: "ENVELOPE_CREATED",

    create_governance_envelope: () => {

      throw new Error("envelope_id is required");

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.entry_point, "production_envelope_entry_point");

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.assignment_authorized, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

  assert.match(result.findings.join("\n"), /envelope_id is required/);

});

