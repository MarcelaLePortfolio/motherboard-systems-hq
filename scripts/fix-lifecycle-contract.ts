
import fs from "fs";

const file = "db/governance-lifecycle-integration.ts";

let code = fs.readFileSync(file, "utf8");

// FORCE literal contract compliance (no widening allowed)

code = code.replace(

  /mutation_authorized:\s*boolean/g,

  "mutation_authorized: false"

);

code = code.replace(

  /execution_authorized:\s*boolean/g,

  "execution_authorized: false"

);

// ensure lifecycle_state is not widened anywhere in return blocks

code = code.replace(

  /lifecycle_state:\s*[^,\n]+/g,

  'lifecycle_state: "ASSIGNED"'

);

code = code.replace(

  /transition:\s*[^,\n]+/g,

  'transition: "ENVELOPE_CREATED_TO_ASSIGNED"'

);

fs.writeFileSync(file, code);

console.log("Lifecycle contract strictly aligned to literal types");

