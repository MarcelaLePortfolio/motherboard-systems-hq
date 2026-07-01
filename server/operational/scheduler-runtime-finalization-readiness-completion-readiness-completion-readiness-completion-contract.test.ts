
import test from "node:test";

import assert from "node:assert/strict";

import { buildSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionContract } from "./scheduler-runtime-finalization-readiness-completion-readiness-completion-readiness-completion-contract.ts";

import type { SchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionAuthorizationBoundaryResult } from "./scheduler-runtime-finalization-readiness-completion-readiness-completion-readiness-completion-authorization-boundary.ts";

const authorizedCompletionTransition: SchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionAuthorizationBoundaryResult =

  {

    ok: true,

    boundary:

      "scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_authorization",

    scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_transition_authorized:

      true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "test scheduler runtime finalization readiness completion readiness completion readiness completion authorization success",

    ],

  };

test("scheduler runtime finalization readiness completion readiness completion readiness completion contract builds completion handoff without authorizing scheduler runtime finalization", () => {

  const result =

    buildSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionContract(

      {

        scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_authorization_boundary:

          authorizedCompletionTransition,

      },

    );

  assert.equal(result.ok, true);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_contract_ready,

    true,

  );

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_transition_authorized,

    true,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization readiness completion readiness completion readiness completion contract fails closed without completion transition authorization", () => {

  const result =

    buildSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionContract(

      {

        scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_authorization_boundary:

          {

            ok: false,

            boundary:

              "scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_authorization",

            scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_transition_authorized:

              false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: [

              "test scheduler runtime finalization readiness completion readiness completion readiness completion authorization failure",

            ],

          },

      },

    );

  assert.equal(result.ok, false);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_contract_ready,

    false,

  );

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_transition_authorized,

    false,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

