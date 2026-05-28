
import { buildExecutionEnvelopeDraft } from "./build-execution-envelope-draft.mjs";

import { validateGovernedExecutionEnvelope } from "./governance-validator.mjs";

import { buildApprovalArtifact } from "./build-approval-artifact.mjs";

import { evaluateExecutionApproval } from "./execution-approval-gate.mjs";

import { planCadeEngineeringExecution } from "./cade-engineer-adapter.mjs";

export function runGovernedPlanningPipeline(input = {}) {

  const draft = buildExecutionEnvelopeDraft(input);

  const envelope = draft.envelope;

  const governance = validateGovernedExecutionEnvelope(envelope);

  const approval = buildApprovalArtifact({

    requested_by: "Matilda",

    approval_scope: "planning_only",

    justification: "Governed planning pipeline approval artifact",

  });

  const approvalGate = evaluateExecutionApproval({

    envelope,

    governance,

    approval,

  });

  const cadePlan = planCadeEngineeringExecution(envelope);

  return {

    ok: true,

    pipeline: "governed_planning_pipeline",

    phase: "planning_only",

    mutation_performed: false,

    shell_execution_performed: false,

    autonomous_execution_performed: false,

    draft,

    governance,

    approval_gate: approvalGate,

    cade_plan: cadePlan,

    trace: [

      {

        event: "intent_to_envelope_draft",

        ok: true,

      },

      {

        event: "canonical_governance_validated",

        ok: true,

      },

      {

        event: "approval_gate_evaluated",

        ok: true,

      },

      {

        event: "cade_engineering_plan_generated",

        ok: true,

      },

    ],

  };

}

