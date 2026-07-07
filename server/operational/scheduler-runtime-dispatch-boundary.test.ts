
import test from "node:test";

import assert from "node:assert/strict";

import { evaluateSchedulerRuntimeDispatchBoundary } from "./scheduler-runtime-dispatch-boundary";

import type { ProductionSchedulerRuntimeContractConsumerResult } from "./production-scheduler-runtime-contract-consumer";

const consumedRuntimeContract: ProductionSchedulerRuntimeContractConsumerResult = {

  ok: true,

  consumer: "production_scheduler_runtime_contract_consumer",

  scheduler_runtime_contract_consumed: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime contract consumer success"],

};

test("scheduler runtime dispatch boundary confirms dispatch readiness without authorizing scheduler runtime", () => {

  const result = evaluateSchedulerRuntimeDispatchBoundary({

    production_scheduler_runtime_contract_consumer: consumedRuntimeContract,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_dispatch_ready, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime dispatch boundary fails closed when runtime contract was not consumed", () => {

  const result = evaluateSchedulerRuntimeDispatchBoundary({

    production_scheduler_runtime_contract_consumer: {

            ok: false,

            consumer: "production_scheduler_runtime_contract_consumer",

            scheduler_runtime_contract_consumed: false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: ["test scheduler runtime contract consumer failure"],

          },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_dispatch_ready, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

