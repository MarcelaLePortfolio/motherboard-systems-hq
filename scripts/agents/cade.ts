import { mockTasks, mockLogs } from "../routes/dashboard";
import { runShell } from "../utils/runShell";

export async function cadeCommandRouter(command: string, payload?: any) {
  let result: any;

  try {
    switch (command) {
      case "dev:clean": {
        const output = await runShell("scripts/dev-clean.sh");
        console.log("🧹 dev:clean full output:", output);
        result = { status: "success", message: "Clean build complete" };
        break;
      }

      case "dev:fresh": {
        const output = await runShell("scripts/dev-fresh.sh");
        console.log("🚀 dev:fresh full output:", output);
        result = { status: "success", message: "Fresh build complete" };
        break;
      }

      case "chat": {
        const message = payload?.message || "";
        result = {
          status: "success",
          message: `Matilda heard: ${message}`
        };
        break;
      }

      default: {
        result = {
          status: "error",
          message: `Unknown command: ${command}`
        };
      }
    }

    return result;
  } catch (err: any) {
    return {
      status: "error",
      message: err?.message || String(err)
    };
  }
}
