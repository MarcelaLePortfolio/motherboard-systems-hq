
import test from "node:test";

import assert from "node:assert/strict";

import { buildSchedulerRuntimeFinalizationReadinessCompletionContract } from "./scheduler-runtime-finalization-readiness-completion-contract.ts";

import type { SchedulerRuntimeFinalizationReadinessCompletionAuthorizationBoundaryResult } from "./scheduler-runtime-finalization-readiness-completion-authorization-boundary.ts";

const authorizedCompletionTransition: SchedulerRuntimeFinalizationReadinessCompletionAuthorizationBoundaryResult = {

  ok: true,

  boundary: "scheduler_runtime_finalization_readiness_completion_authorization",

  scheduler_runtime_finalization_readiness_completion_transition_authorized: true,

  scheduler_authorized: false,

  routing_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

  findings: ["test scheduler runtime finalization readiness completion authorization success"],

};

test("scheduler runtime finalization readiness completion contract builds completion handoff without authorizing scheduler runtime finalization", () => {

  const result = buildSchedulerRuntimeFinalizationReadinessCompletionContract({

    scheduler_runtime_finalization_readiness_completion_authorization:

      authorizedCompletionTransition,

  });

  assert.equal(result.ok, true);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_contract_ready,

    true,

  );

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_transition_authorized,

    true,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization readiness completion contract fails closed without completion transition authorization", () => {

  const result = buildSchedulerRuntimeFinalizationReadinessCompletionContract({

    scheduler_runtime_finalization_readiness_completion_authorization: {

      ok: false,

      boundary: "scheduler_runtime_finalization_readiness_completion_authorization",

      scheduler_runtime_finalization_readiness_completion_transition_authorized: false,

      scheduler_authorized: false,

      routing_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      execution_authorized: false,

      new_authority_introduced: false,

      findings: [

        "test scheduler runtime finalization readiness completion authorization failure",

      ],

    },

  });

  assert.equal(result.ok, false);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_contract_ready,

    false,

  );

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_transition_authorized,

    false,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

