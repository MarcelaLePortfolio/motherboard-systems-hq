
import { readFileSync } from "fs";

import { runGovernedPlanningPipeline }

  from "./governed-planning-pipeline.mjs";

const payload = JSON.parse(

  readFileSync(

    new URL(

      "./smoke-test-governed-route-payload.json",

      import.meta.url,

    ),

    "utf8",

  ),

);

const result = await runGovernedPlanningPipeline({

  intent: {

    actor: payload.actor || "Matilda",

    target: payload.target || "Cade",

    objective:

      payload.objective ||

      "Prepare governed engineering plan",

    requested_outcome:

      payload.requested_outcome ||

      "Dry-run reconciliation-ready planning artifact",

    raw_user_intent:

      payload.raw_user_intent ||

      payload.objective ||

      "Prepare governed engineering plan",

    source: payload.source || "route_smoke_test",

    tags: Array.isArray(payload.tags)

      ? payload.tags

      : ["governance", "dry_run"],

  },

  mutation_scope: {

    scope_type: "file",

    allowed_paths: ["docs/contracts/"],

    forbidden_paths: ["secrets/", ".env"],

    scope_constraints: "Governed planning route smoke is docs-only",

  },

  execution_plan: {

    summary:

      payload.objective ||

      "Prepare governed engineering plan",

    steps: [

      {

        step_id: "step-1",

        action: "inspect",

        target: "docs/contracts/example.md",

        instructions: "Plan route smoke only",

        expected_output: "Dry-run route planning artifact",

      },

    ],

  },

  patch_spec: {

    format: "structured_patch",

    patches: Array.isArray(payload.proposed_changes)

      ? payload.proposed_changes

      : [],

  },

});

console.log(JSON.stringify({

  ok: true,

  route_validation: "governed_planning_route_smoke",

  phase: result.phase,

  envelope_version:

    result.draft.envelope.envelope_version,

  governance_ok:

    result.governance.ok,

  approval_gate_ok:

    result.approval_gate.ok,

  cade_plan_ok:

    result.cade_plan.ok,

  mutation_performed:

    result.mutation_performed,

  shell_execution_performed:

    result.shell_execution_performed,

  autonomous_execution_performed:

    result.autonomous_execution_performed,

  trace:

    result.trace,

}, null, 2));

