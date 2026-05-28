
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

const result = await runGovernedPlanningPipeline(payload);

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

