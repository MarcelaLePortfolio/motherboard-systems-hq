
import { execSync } from "child_process";

const result = execSync(

  `rg "mutation_authorized|execution_authorized|lifecycle_state" db server routes`,

  { encoding: "utf-8" }

);

console.log(result);

