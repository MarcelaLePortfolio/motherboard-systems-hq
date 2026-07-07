
import { execSync } from "child_process";

const result = execSync(

  `rg "new Database|sqlite|db/client|prepare\\(" -l || true`,

  { encoding: "utf8" }

);

const files = result

  .split("\n")

  .filter(Boolean);

console.log(JSON.stringify({

  count: files.length,

  critical_surface: files

}, null, 2));

