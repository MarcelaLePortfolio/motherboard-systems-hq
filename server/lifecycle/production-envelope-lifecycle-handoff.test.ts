import assert from "node:assert/strict";
import test from "node:test";

import {
  handoffProductionEnvelopeToLifecycle,
} from "./production-envelope-lifecycle-handoff.js";

test("production envelope lifecycle handoff preserves existing lifecycle authority only", () => {
  const result = handoffProductionEnvelopeToLifecycle({
    envelope_id: "env-handoff-test",
    envelope: {
      lifecycle_state: "ENVELOPE_CREATED",
      required_capabilities: "engineering_planning",
      operational_corridor: "planning_only",
    },
    available_departments: ["engineering_planning"],
    available_actors: ["cade"],
    department_handshake: {
      acknowledgement_status: "ACKNOWLEDGED",
      capability_status: "CAPABILITY_CONFIRMED",
      response_basis: "existing department assignment readiness",
    },
    persist_lifecycle_transition: () => ({
      envelope_id: "env-handoff-test",
      previous_lifecycle_state: "ENVELOPE_CREATED",
      lifecycle_state: "ASSIGNED",
      transition: "ENVELOPE_CREATED_TO_ASSIGNED",
      persisted_at: "2026-09-29T00:00:00.000Z",
      mutation_authorized: false,
      execution_authorized: false,
    }),
  });

  assert.equal(result.ok, true);
  assert.equal(result.handoff, "production_envelope_to_lifecycle");
  assert.equal(result.new_authority_introduced, false);
  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.execution_authorized, false);
});

test("production envelope lifecycle handoff fails closed without existing assignment readiness", () => {
  const result = handoffProductionEnvelopeToLifecycle({
    envelope_id: "env-handoff-blocked",
    envelope: {
      lifecycle_state: "ENVELOPE_CREATED",
      required_capabilities: "engineering_planning",
      operational_corridor: "planning_only",
    },
    available_departments: ["engineering_planning"],
    available_actors: ["cade"],
    persist_lifecycle_transition: () => {
      throw new Error("persistence must not be reached");
    },
  });

  assert.equal(result.ok, false);
  assert.equal(result.handoff, "production_envelope_to_lifecycle");
  assert.equal(result.new_authority_introduced, false);
});
