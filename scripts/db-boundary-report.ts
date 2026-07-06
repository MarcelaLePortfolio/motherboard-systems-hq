
import { execSync } from "child_process";

const result = execSync("grep -R sqlite\\.prepare routes scripts || true")

  .toString()

  .trim();

if (!result) {

  console.log("✅ DB boundary clean");

} else {

  console.log("⚠️ Remaining violations:");

  console.log(result);

}

