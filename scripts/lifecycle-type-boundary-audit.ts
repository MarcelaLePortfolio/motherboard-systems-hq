
import { execSync } from "child_process";

console.log("LIFECYCLE TYPE BOUNDARY AUDIT");

const result = execSync(

  `rg "GovernanceLifecyclePersistenceResult|mutation_authorized|execution_authorized" db server`,

  { encoding: "utf8" }

);

console.log(result || "NO MATCHES FOUND");

