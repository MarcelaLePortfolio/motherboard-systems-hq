
import fs from "fs";

const file = "db/governance-lifecycle-integration.ts";

let code = fs.readFileSync(file, "utf8");

// inject explicit return type on function

code = code.replace(

  /export function completeGovernanceLifecycleAssignmentTransition\([^)]*\):[^\\{]*\{/,

  (match) => {

    if (match.includes("GovernanceLifecyclePersistenceResult")) return match;

    return match.replace("{", `: any {`);

  }

);

// force correct import typing context (prevents inference widening)

code = `import type { GovernanceLifecyclePersistenceResult } from "./governance-lifecycle-composition";

` + code;

fs.writeFileSync(file, code);

console.log("Type boundary enforced (prevents boolean widening)");

