
import { runGovernedPlanningPipeline } from "./governed-planning-pipeline.mjs";

const result = runGovernedPlanningPipeline({

  intent: {

    actor: "Matilda",

    target: "Cade",

    objective: "Prepare governed documentation plan through full planning pipeline",

    requested_outcome: "Dry-run Cade plan with governance and approval artifacts",

    raw_user_intent: "Plan a safe docs-only change",

    source: "user_chat",

    tags: ["governance", "pipeline"],

  },

  mutation_scope: {

    scope_type: "file",

    allowed_paths: ["docs/contracts/"],

    forbidden_paths: ["secrets/", ".env"],

    scope_constraints: "Docs-only full pipeline smoke",

  },

  execution_plan: {

    summary: "Prepare governed documentation plan through full planning pipeline",

    steps: [

      {

        step_id: "step-1",

        action: "inspect",

        target: "docs/contracts/pipeline-example.md",

        instructions: "Plan only",

        expected_output: "Dry-run governed plan",

      },

    ],

  },

  patch_spec: {

    format: "structured_patch",

    patches: [

      {

        file: "docs/contracts/pipeline-example.md",

        operation: "modify",

        content: "planned only",

      },

    ],

  },

});

console.log(JSON.stringify({

  ok: result.ok,

  pipeline: result.pipeline,

  phase: result.phase,

  envelope_version: result.draft.envelope.envelope_version,

  governance_ok: result.governance.ok,

  approval_gate_ok: result.approval_gate.ok,

  cade_plan_ok: result.cade_plan.ok,

  mutation_performed: result.mutation_performed,

  shell_execution_performed: result.shell_execution_performed,

  autonomous_execution_performed: result.autonomous_execution_performed,

  trace: result.trace,

}, null, 2));

