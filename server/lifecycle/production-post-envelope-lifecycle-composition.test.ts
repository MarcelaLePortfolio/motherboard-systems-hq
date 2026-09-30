import assert from "node:assert/strict";
import test from "node:test";

import {
  composeProductionPostEnvelopeLifecycle,
} from "./production-post-envelope-lifecycle-composition.js";

test("post-envelope composition reuses existing lifecycle inputs without new authority", () => {
  const result = composeProductionPostEnvelopeLifecycle({
    envelope_result: {
      ok: true,
      route: "governance_envelope_route",
      envelope: {
        ok: true,
        entry_point: "production_envelope_entry_point",
        envelope: {
          envelope_id: "env-live-composition",
          lifecycle_state: "ENVELOPE_CREATED",
        },
        findings: [],
      } as never,
      endpoint_authorized: true,
      scheduler_authorized: false,
      worker_claim_authorized: false,
      orchestration_authorized: false,
      routing_authorized: false,
      assignment_authorized: false,
      lifecycle_transition_authorized: false,
      execution_authorized: false,
      new_authority_introduced: false,
      findings: [],
    },
    lifecycle_input: {
      envelope_id: "env-live-composition",
      envelope: {
        lifecycle_state: "ENVELOPE_CREATED",
        required_capabilities: "engineering_planning",
        operational_corridor: "planning_only",
      },
      available_departments: ["engineering_planning"],
      department_handshake: {
        status: "ACKNOWLEDGED",
      } as never,
      persist_lifecycle_transition: (() =>
        ({
          envelope_id: "env-live-composition",
          lifecycle_state: "ASSIGNED",
          persisted_at: "2026-09-30T00:00:00.000Z",
        })) as never,
    },
  });

  assert.equal(result.new_authority_introduced, false);
});

test("post-envelope composition fails closed when envelope result is unsuccessful", () => {
  const result = composeProductionPostEnvelopeLifecycle({
    envelope_result: {
      ok: false,
      route: "governance_envelope_route",
      endpoint_authorized: true,
      scheduler_authorized: false,
      worker_claim_authorized: false,
      orchestration_authorized: false,
      routing_authorized: false,
      assignment_authorized: false,
      lifecycle_transition_authorized: false,
      execution_authorized: false,
      new_authority_introduced: false,
      findings: [],
    },
    lifecycle_input: {} as never,
  });

  assert.equal(result.ok, false);
  assert.equal(result.new_authority_introduced, false);
});
