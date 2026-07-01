
import test from "node:test";

import assert from "node:assert/strict";

import { buildSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionReadinessContract } from "./scheduler-runtime-finalization-readiness-completion-readiness-completion-readiness-completion-readiness-contract.ts";

import type { SchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionReadinessAuthorizationBoundaryResult } from "./scheduler-runtime-finalization-readiness-completion-readiness-completion-readiness-completion-readiness-authorization-boundary.ts";

const authorizedTransition: SchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionReadinessAuthorizationBoundaryResult =

  {

    ok: true,

    boundary:

      "scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_authorization",

    scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_transition_authorized:

      true,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    execution_authorized: false,

    new_authority_introduced: false,

    findings: [

      "test scheduler runtime finalization readiness completion readiness completion readiness completion readiness authorization success",

    ],

  };

test("scheduler runtime finalization readiness completion readiness completion readiness completion readiness contract builds readiness handoff without authorizing scheduler runtime finalization", () => {

  const result =

    buildSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionReadinessContract(

      {

        scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_authorization_boundary:

          authorizedTransition,

      },

    );

  assert.equal(result.ok, true);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_contract_ready,

    true,

  );

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_transition_authorized,

    true,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("scheduler runtime finalization readiness completion readiness completion readiness completion readiness contract fails closed without readiness transition authorization", () => {

  const result =

    buildSchedulerRuntimeFinalizationReadinessCompletionReadinessCompletionReadinessCompletionReadinessContract(

      {

        scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_authorization_boundary:

          {

            ok: false,

            boundary:

              "scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_authorization",

            scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_transition_authorized:

              false,

            scheduler_authorized: false,

            routing_authorized: false,

            worker_claim_authorized: false,

            orchestration_authorized: false,

            execution_authorized: false,

            new_authority_introduced: false,

            findings: [

              "test scheduler runtime finalization readiness completion readiness completion readiness completion readiness authorization failure",

            ],

          },

      },

    );

  assert.equal(result.ok, false);

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_contract_ready,

    false,

  );

  assert.equal(

    result.scheduler_runtime_finalization_readiness_completion_readiness_completion_readiness_completion_readiness_transition_authorized,

    false,

  );

  assert.equal(result.scheduler_authorized, false);

  assert.equal(result.routing_authorized, false);

  assert.equal(result.worker_claim_authorized, false);

  assert.equal(result.orchestration_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

