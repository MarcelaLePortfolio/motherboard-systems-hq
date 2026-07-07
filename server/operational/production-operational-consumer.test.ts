
import test from "node:test";

import assert from "node:assert/strict";

import { consumeOperationalIntakeForProduction } from "./production-operational-consumer";

import type { OperationalIntakeRecord } from "../../db/operational-intake-runtime.js";

const recordedOperationalIntake: OperationalIntakeRecord = {

  intake_id: "operational-intake:env-production-operational-consumer",

  envelope_id: "env-production-operational-consumer",

  package_id: "pkg-production-operational-consumer",

  package_version: 1,

  delegation_id: "del-production-operational-consumer",

  validation_result_id: "val-production-operational-consumer",

  envelope_gate_id: "gate-production-operational-consumer",

  lifecycle_state_at_intake: "ASSIGNED",

  assigned_department: "engineering",

  required_capabilities_snapshot: "engineering",

  intake_status: "RECORDED",

  intake_created_at: "2026-06-30T09:00:00.000Z",

  intake_updated_at: "2026-06-30T09:00:00.000Z",

  governance_authority_preserved: true,

  lifecycle_authority_preserved: true,

  assignment_authority_preserved: true,

  routing_authorized: false,

  scheduler_authorized: false,

  worker_claim_authorized: false,

  execution_authorized: false,

};

test("production operational consumer consumes recorded intake without adding downstream authority", () => {

  const result = consumeOperationalIntakeForProduction({

    operational_intake: recordedOperationalIntake,

  });

  assert.equal(result.ok, true);

  assert.equal(result.consumer, "production_operational_consumer");

  assert.equal(result.downstream_consumption_ready, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

  if (!result.ok) {

    assert.fail("Expected production operational consumer to accept recorded intake.");

  }

  assert.equal(result.operational_intake.intake_status, "RECORDED");

  assert.equal(result.operational_intake.lifecycle_state_at_intake, "ASSIGNED");

});

test("production operational consumer fails closed for non-recorded intake status", () => {

  const result = consumeOperationalIntakeForProduction({

    operational_intake: {

      ...recordedOperationalIntake,

      intake_status: "PENDING" as never,

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.downstream_consumption_ready, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

