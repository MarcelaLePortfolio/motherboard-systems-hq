
import test from "node:test";

import assert from "node:assert/strict";

import {

  invokeProductionEnvelopeGateEntryPoint,

  type GovernanceEnvelopeGatePersistenceFunction,

} from "./production-envelope-gate-entry-point";

const fakeCreateEnvelopeGate: GovernanceEnvelopeGatePersistenceFunction = (input) => ({

  envelope_gate_id: input.envelope_gate_id,

  package_id: input.package_id,

  package_version: input.package_version,

  delegation_id: input.delegation_id,

  validation_result_id: input.validation_result_id,

  gate_status: input.gate_status,

  gate_decision_timestamp:

    input.gate_decision_timestamp ?? "2026-06-26T23:32:52.000Z",

  created_at: "2026-06-26T23:32:52.000Z",

});

test("production Envelope Gate entry point creates only the canonical Envelope Gate record", () => {

  const result = invokeProductionEnvelopeGateEntryPoint({

    envelope_gate_id: "gate-entry-point-success",

    package_id: "pkg-gate-entry-point-success",

    package_version: 1,

    delegation_id: "delegation-gate-entry-point-success",

    validation_result_id: "validation-gate-entry-point-success",

    gate_status: "OPEN",

    gate_reason: "Validation passed",

    gate_decision_timestamp: "2026-06-26T23:32:52.000Z",

    create_governance_envelope_gate: fakeCreateEnvelopeGate,

  });

  assert.equal(result.ok, true);

  assert.equal(result.entry_point, "production_envelope_gate_entry_point");

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.assignment_authorized, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.envelope_creation_authorized, false);

  assert.equal(result.new_authority_introduced, false);

  if (!result.ok) assert.fail("Expected Envelope Gate entry point to succeed.");

  assert.equal(result.envelope_gate.envelope_gate_id, "gate-entry-point-success");

});

test("production Envelope Gate entry point fails closed when persistence rejects input", () => {

  const result = invokeProductionEnvelopeGateEntryPoint({

    envelope_gate_id: "",

    package_id: "pkg-gate-entry-point-fail",

    package_version: 1,

    delegation_id: "delegation-gate-entry-point-fail",

    validation_result_id: "validation-gate-entry-point-fail",

    gate_status: "OPEN",

    create_governance_envelope_gate: () => {

      throw new Error("envelope_gate_id is required");

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.entry_point, "production_envelope_gate_entry_point");

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.assignment_authorized, false);

  assert.equal(result.lifecycle_transition_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.envelope_creation_authorized, false);

  assert.equal(result.new_authority_introduced, false);

  assert.match(result.findings.join("\n"), /envelope_gate_id is required/);

});

