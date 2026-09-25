import test from "node:test";
import assert from "node:assert/strict";

import { composeProductionLifecycleScheduler } from "./production-lifecycle-scheduler-composition";
import type { ProductionLifecycleConsumerResult } from "../lifecycle/production-lifecycle-consumer";

const lifecycleSuccess = {
  ok: true,
  entry: { ok: true },
  operational_intake: {
    envelope_id: "envelope-test",
    package_id: "package-test",
    package_version: 1,
    assigned_department: "engineering",
    required_capabilities_snapshot: null,
    lifecycle_state_at_intake: "ASSIGNED",
    intake_status: "RECORDED",
  },
  operational_consumption: {
    ok: true,
    consumer: "production_operational_consumer",
    downstream_consumption_ready: true,
    scheduler_authorized: false,
    routing_authorized: false,
    worker_claim_authorized: false,
    orchestration_authorized: false,
    execution_authorized: false,
    new_authority_introduced: false,
    findings: ["test operational consumption"],
  },
  findings: ["test lifecycle success"],
} as unknown as ProductionLifecycleConsumerResult;

test("lifecycle-to-scheduler composition reaches production scheduler execution consumption without introducing authority", () => {
  const result = composeProductionLifecycleScheduler({
    production_lifecycle_consumer: lifecycleSuccess,
  });

  assert.equal(result.scheduler_readiness.ok, true);
  assert.equal(result.scheduler_entry_point.ok, true);
  assert.equal(result.production_scheduler_consumer.ok, true);
  assert.equal(result.scheduler_authorization.ok, true);
  assert.equal(result.scheduler_dispatch_contract.ok, true);
  assert.equal(result.production_scheduler_dispatch_consumer.ok, true);
  assert.equal(result.scheduler_execution_readiness.ok, true);
  assert.equal(result.scheduler_execution_entry_point.ok, true);
  assert.equal(result.production_scheduler_execution_consumer.ok, true);

  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});

test("lifecycle-to-scheduler composition fails closed when lifecycle consumption is unavailable", () => {
  const lifecycleFailure = {
    ok: false,
    entry: { ok: false },
    findings: ["test lifecycle failure"],
  } as unknown as ProductionLifecycleConsumerResult;

  const result = composeProductionLifecycleScheduler({
    production_lifecycle_consumer: lifecycleFailure,
  });

  assert.equal(result.production_scheduler_execution_consumer.ok, false);
  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.new_authority_introduced, false);
});
