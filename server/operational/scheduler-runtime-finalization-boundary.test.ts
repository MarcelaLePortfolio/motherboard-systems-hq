
import test from "node:test";

import assert from "node:assert/strict";

import { authorizeSchedulerRuntimeFinalizationTransition } from "./scheduler-runtime-finalization-boundary.ts";

import type { ProductionSchedulerRuntimeDispatchContractConsumerResult } from "./production-scheduler-runtime-dispatch-contract-consumer.ts";

const consumedRuntimeDispatchContract: ProductionSchedulerRuntimeDispatchContractConsumerResult = {

  ok: true,

  consumer: "production_scheduler_runtime_dispatch_contract_consumer",

  scheduler_runtime_dispatch_contract_consumed: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime dispatch contract consumer success"],

};

test("scheduler runtime finalization boundary authorizes only runtime finalization transition", () => {

  const result = authorizeSchedulerRuntimeFinalizationTransition({

    production_scheduler_runtime_dispatch_contract_consumer:

      consumedRuntimeDispatchContract,

  });

  assert.equal(result.ok, true);

  assert.equal(result.scheduler_runtime_finalization_transition_authorized, true);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization boundary fails closed when runtime dispatch contract was not consumed", () => {

  const result = authorizeSchedulerRuntimeFinalizationTransition({

    production_scheduler_runtime_dispatch_contract_consumer: {

      ok: false,

      consumer: "production_scheduler_runtime_dispatch_contract_consumer",

      scheduler_runtime_dispatch_contract_consumed: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: ["test scheduler runtime dispatch contract consumer failure"],

    },

  });

  assert.equal(result.ok, false);

  assert.equal(result.scheduler_runtime_finalization_transition_authorized, false);

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

