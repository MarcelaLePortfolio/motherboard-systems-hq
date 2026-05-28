
import { normalizeExecutionIntent } from "./normalize-execution-intent.mjs";

const result = normalizeExecutionIntent({

  actor: "Matilda",

  target: "Cade",

  objective: "Prepare governed engineering plan",

  requested_outcome: "Dry-run reconciliation-ready planning artifact",

  source: "user_chat",

  tags: ["governance", "planning"],

});

console.log(JSON.stringify(result, null, 2));

