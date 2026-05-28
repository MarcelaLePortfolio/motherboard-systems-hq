
import {

  normalizeGovernedResponse,

} from "./normalize-governed-response.mjs";

const success = normalizeGovernedResponse({

  ok: true,

  phase: "planning_only",

  envelope_version:

    "matilda.cade.exec.v1",

  governance_ok: true,

  approval_gate_ok: true,

  cade_plan_ok: true,

  mutation_performed: false,

  shell_execution_performed: false,

  autonomous_execution_performed: false,

  trace: [

    {

      event: "normalized",

      ok: true,

    },

  ],

});

const failure = normalizeGovernedResponse({

  ok: false,

  phase: "governance_failed",

  envelope_version:

    "matilda.cade.exec.v1",

  governance_ok: false,

  approval_gate_ok: false,

  cade_plan_ok: false,

  mutation_performed: false,

  shell_execution_performed: false,

  autonomous_execution_performed: false,

  error: {

    code: "MISSING_EXECUTION_OBJECTIVE",

    message:

      "execution intent requires objective",

  },

});

console.log(JSON.stringify({

  ok: true,

  response_normalizer:

    "governed_response_normalizer",

  success,

  failure,

}, null, 2));

