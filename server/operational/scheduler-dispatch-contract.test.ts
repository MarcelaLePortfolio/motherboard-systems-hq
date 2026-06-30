
import test from "node:test";

import assert from "node:assert/strict";

import { buildSchedulerDispatchContract } from "./scheduler-dispatch-contract.ts";

import type { SchedulerAuthorizationBoundaryResult } from "./scheduler-authorization-boundary.ts";

import type { OperationalIntakeRecord } from "../../db/operational-intake-runtime.ts";

const schedulerAuthorization: SchedulerAuthorizationBoundaryResult = {

  ok: true,

  boundary: "scheduler_authorization",

  scheduler_transition_authorized: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler authorization success"],

};

const operationalIntake: OperationalIntakeRecord = {

  intake_id: "operational-intake:env-scheduler-dispatch",

  envelope_id: "env-scheduler-dispatch",

  package_id: "pkg-scheduler-dispatch",

  package_version: 1,

  delegation_id: "del-scheduler-dispatch",

  validation_result_id: "val-scheduler-dispatch",

  envelope_gate_id: "gate-scheduler-dispatch",

  lifecycle_state_at_intake: "ASSIGNED",

  assigned_department: "engineering",

  required_capabilities_snapshot: "engineering",

  intake_status: "RECORDED",

  intake_created_at: "2026-06-30T10:15:00.000Z",

  intake_updated_at: "2026-06-30T10:15:00.000Z",

  governance_authority_preserved: true,

  lifecycle_authority_preserved: true,

  assignment_authority_preserved: true,

  routing_authorized: false,

  scheduler_authorized: false,

  worker_claim_authorized: false,

  execution_authorized: false,

};

test("scheduler dispatch contract builds canonical handoff without scheduling authority", () => {

  const result = buildSchedulerDispatchContract({

    scheduler_authorization: schedulerAuthorization,

    operational_intake: operationalIntake,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_dispatch_ready, true);

  assert.equal(result.scheduler_transition_authorized, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

  if (!result.ok) {

    assert.fail("Expected scheduler dispatch contract to succeed.");

  }

  assert.equal(result.envelope_id, "env-scheduler-dispatch");

  assert.equal(result.package_id, "pkg-scheduler-dispatch");

  assert.equal(result.package_version, 1);

  assert.equal(result.assigned_department, "engineering");

  assert.equal(result.required_capabilities_snapshot, "engineering");

});

test("scheduler dispatch contract fails closed without scheduler transition authorization", () => {

  const result = buildSchedulerDispatchContract({

    scheduler_authorization: {

      ok: false,

      boundary: "scheduler_authorization",

      scheduler_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: ["test scheduler authorization failure"],

    },

    operational_intake: operationalIntake,

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_dispatch_ready, false);

  assert.equal(result.scheduler_transition_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

