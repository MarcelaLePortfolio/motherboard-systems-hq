import path from "path";
import { pathToFileURL } from "url";
import { runShell } from "../utils/runShell";
const { runShell: execShell } = await import(pathToFileURL(path.resolve("scripts/utils/runShell.ts")).href); console.log("<0001FB1F> [Cade] dynamic import of runShell succeeded, type:", typeof execShell);

console.log("<0001f7e2> [Cade] execShell available:", typeof execShell);

const cadeCommandRouter = async (command: string, payload: any = {}) => {
  let result = "";

  try {
  console.log("<0001FB18> [Cade] cadeCommandRouter invoked with command:", command);
  console.log("<0001FB18> [Cade] typeof execShell at runtime:", typeof execShell);
console.log("<0001FB1E> [Cade] raw runShell reference:", runShell);
    switch (command) {
      case "dev:clean": {
        console.log("<0001FB07> [Cade] running dev:clean via execShell");
        console.log("<0001FB0E> [Cade] about to call execShell for dev:clean");
        return { status: "success", result: await execShell("scripts/dev-clean.sh") };
      }

      case "dev:fresh": {
        console.log("<0001FB07> [Cade] running dev:fresh via execShell");
        console.log("<0001FB0E> [Cade] about to call execShell for dev:fresh");
        return { status: "success", result: await execShell("scripts/dev-fresh.sh") };
      }

      default: {
        result = "🤷 Unknown task type";
      }
    }

    return { status: "success", result };
  } catch (err: any) {
    console.error("<0001FB16> [Cade Catch] FULL ERROR object:", err);
    console.error("<0001FB16> [Cade Catch] FULL ERROR stack:", err?.stack);
    return { status: "error", message: "[Cade Catch] " + (err?.message || String(err)) };
  }
};

export { cadeCommandRouter };
