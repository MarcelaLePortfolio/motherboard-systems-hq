
import test from "node:test";

import assert from "node:assert/strict";

import { evaluateSchedulerReadinessBoundary } from "./scheduler-readiness-boundary";

import type { ProductionOperationalConsumerResult } from "./production-operational-consumer";

import type { OperationalIntakeRecord } from "../../db/operational-intake-runtime.js";

const operationalIntake: OperationalIntakeRecord = {

  intake_id: "operational-intake:env-scheduler-readiness",

  envelope_id: "env-scheduler-readiness",

  package_id: "pkg-scheduler-readiness",

  package_version: 1,

  delegation_id: "del-scheduler-readiness",

  validation_result_id: "val-scheduler-readiness",

  envelope_gate_id: "gate-scheduler-readiness",

  lifecycle_state_at_intake: "ASSIGNED",

  assigned_department: "engineering",

  required_capabilities_snapshot: "engineering",

  intake_status: "RECORDED",

  intake_created_at: "2026-06-30T09:50:00.000Z",

  intake_updated_at: "2026-06-30T09:50:00.000Z",

  governance_authority_preserved: true,

  lifecycle_authority_preserved: true,

  assignment_authority_preserved: true,

  routing_authorized: false,

  scheduler_authorized: false,

  worker_claim_authorized: false,

  execution_authorized: false,

};

const successfulOperationalConsumption: ProductionOperationalConsumerResult = {

  ok: true,

  consumer: "production_operational_consumer",

  operational_intake: operationalIntake,

  downstream_consumption_ready: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test operational consumption success"],

};

test("scheduler readiness boundary confirms readiness without authorizing scheduler", () => {

  const result = evaluateSchedulerReadinessBoundary({

    operational_consumption: successfulOperationalConsumption,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_ready, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler readiness boundary fails closed when operational consumption fails", () => {

  const result = evaluateSchedulerReadinessBoundary({

    operational_consumption: {

            ok: false,

            consumer: "production_operational_consumer",

            operational_intake: operationalIntake,

            downstream_consumption_ready: false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: ["test operational consumption failure"],

          },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_ready, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

