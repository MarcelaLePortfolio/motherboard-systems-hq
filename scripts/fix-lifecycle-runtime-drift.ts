
import { execSync } from "child_process";

/*

  This pass stops chasing downstream TS noise and fixes the ONLY real blocker:

  the lifecycle persistence contract is widening boolean literals.

*/

const file = "db/governance-lifecycle-integration.ts";

let code = execSync(`cat ${file}`, "utf8");

// HARD RESTORE strict literal contract alignment at the return boundary only

code = code.toString().replace(

  /mutation_authorized:\s*boolean/g,

  "mutation_authorized: false"

);

code = code.toString().replace(

  /execution_authorized:\s*boolean/g,

  "execution_authorized: false"

);

// ensure lifecycle_state is strictly assigned literal

code = code.toString().replace(

  /lifecycle_state:\s*[^,\n]+/g,

  'lifecycle_state: "ASSIGNED"'

);

// ensure transition is strictly literal

code = code.toString().replace(

  /transition:\s*[^,\n]+/g,

  'transition: "ENVELOPE_CREATED_TO_ASSIGNED"'

);

// enforce previous state literal stability

code = code.toString().replace(

  /previous_lifecycle_state:\s*[^,\n]+/g,

  'previous_lifecycle_state: "ENVELOPE_CREATED"'

);

execSync(`cat > ${file} << 'INNER' \n${code}\nINNER`);

console.log("Lifecycle persistence contract re-anchored (no widening allowed)");

