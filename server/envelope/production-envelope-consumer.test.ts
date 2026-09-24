import test from "node:test";
import assert from "node:assert/strict";

import {
  consumeProductionEnvelopeEntryPoint,
} from "./production-envelope-consumer.js";

const baseInput = {
  envelope_id: "envelope-1",
  package_id: "package-1",
  package_version: 1,
  delegation_id: "delegation-1",
  validation_result_id: "validation-1",
  envelope_gate_id: "gate-1",
  validation_status: "caller-status-must-not-win",
  required_capabilities: "caller-capabilities-must-not-win",
  operational_corridor: "caller-corridor-must-not-win",
  lifecycle_state: "ENVELOPE_CREATED",
};

const exactReadChain = {
  validation_result: {
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
  },
  envelope_gate: {
    envelope_gate_id: "gate-1",
    package_id: "package-1",
    package_version: 1,
    delegation_id: "delegation-1",
    validation_result_id: "validation-1",
    gate_status: "OPEN",
    gate_reason: null,
    gate_decision_timestamp: "2026-09-24T00:01:00.000Z",
    created_at: "2026-09-24T00:01:00.000Z",
  },
};

test("uses exact persisted lineage and authoritative Validation semantics", () => {
  let persistedInput: Record<string, unknown> | undefined;

  const result = consumeProductionEnvelopeEntryPoint(
    {
      ...baseInput,
      create_governance_envelope: (input) => {
        persistedInput = input;
        return {
          ...input,
          created_at: "2026-09-24T00:02:00.000Z",
        };
      },
    },
    {
      load_exact_governance_envelope_creation_read_chain: () =>
        exactReadChain,
    },
  );

  assert.equal(result.ok, true);
  assert.equal(persistedInput?.validation_status, "VALIDATION_PASSED");
  assert.equal(
    persistedInput?.required_capabilities,
    "engineering_planning",
  );
  assert.equal(persistedInput?.operational_corridor, "planning_only");

  if (result.ok) {
    assert.equal(result.scheduler_authorized, false);
    assert.equal(result.worker_claim_authorized, false);
    assert.equal(result.orchestration_authorized, false);
    assert.equal(result.routing_authorized, false);
    assert.equal(result.assignment_authorized, false);
    assert.equal(result.lifecycle_transition_authorized, false);
    assert.equal(result.execution_authorized, false);
    assert.equal(result.new_authority_introduced, false);
  }
});

test("fails closed before persistence when Validation is not passed", () => {
  let persistenceCalled = false;

  const result = consumeProductionEnvelopeEntryPoint(
    {
      ...baseInput,
      create_governance_envelope: () => {
        persistenceCalled = true;
        throw new Error("must not persist");
      },
    },
    {
      load_exact_governance_envelope_creation_read_chain: () => ({
        ...exactReadChain,
        validation_result: {
          ...exactReadChain.validation_result,
          validation_status: "RESOLUTION_REQUIRED",
        },
      }),
    },
  );

  assert.equal(result.ok, false);
  assert.equal(persistenceCalled, false);
  assert.match(result.findings[0], /VALIDATION_PASSED/);
});

test("fails closed before persistence when Gate is not OPEN", () => {
  let persistenceCalled = false;

  const result = consumeProductionEnvelopeEntryPoint(
    {
      ...baseInput,
      create_governance_envelope: () => {
        persistenceCalled = true;
        throw new Error("must not persist");
      },
    },
    {
      load_exact_governance_envelope_creation_read_chain: () => ({
        ...exactReadChain,
        envelope_gate: {
          ...exactReadChain.envelope_gate,
          gate_status: "CLOSED",
        },
      }),
    },
  );

  assert.equal(result.ok, false);
  assert.equal(persistenceCalled, false);
  assert.match(result.findings[0], /OPEN Envelope Gate/);
});

test("fails closed before persistence when capability semantics are absent", () => {
  let persistenceCalled = false;

  const result = consumeProductionEnvelopeEntryPoint(
    {
      ...baseInput,
      create_governance_envelope: () => {
        persistenceCalled = true;
        throw new Error("must not persist");
      },
    },
    {
      load_exact_governance_envelope_creation_read_chain: () => ({
        ...exactReadChain,
        validation_result: {
          ...exactReadChain.validation_result,
          capability_requirements: " ",
        },
      }),
    },
  );

  assert.equal(result.ok, false);
  assert.equal(persistenceCalled, false);
  assert.match(result.findings[0], /capability_requirements/);
});

test("fails closed before persistence when operational semantics are absent", () => {
  let persistenceCalled = false;

  const result = consumeProductionEnvelopeEntryPoint(
    {
      ...baseInput,
      create_governance_envelope: () => {
        persistenceCalled = true;
        throw new Error("must not persist");
      },
    },
    {
      load_exact_governance_envelope_creation_read_chain: () => ({
        ...exactReadChain,
        validation_result: {
          ...exactReadChain.validation_result,
          operational_requirements: null,
        },
      }),
    },
  );

  assert.equal(result.ok, false);
  assert.equal(persistenceCalled, false);
  assert.match(result.findings[0], /operational_requirements/);
});
