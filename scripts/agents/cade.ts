import { runShell } from "../utils/runShell";

export async function cadeCommandRouter(command: string, payload?: any) {
  let result: any;

  try {
    switch (command) {
      case "dev:clean": {
        result = await runShell("scripts/dev-clean.sh");
        break;
      }

      case "dev:fresh": {
        result = await runShell("scripts/dev-fresh.sh");
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
