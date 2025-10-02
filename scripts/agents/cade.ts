import { runShell } from "../utils/runShell";

export async function cadeCommandRouter(command: string, payload?: any) {
  switch (command) {
    case "dev:clean": {
      try {
        await runShell("scripts/dev-clean.sh");
        return { status: "success", message: "Clean build complete" };
      } catch (err) {
        return { status: "error", message: "[Cade execShell fail] " + ((err as any)?.message || String(err)) };
      }
    }

    case "dev:fresh": {
      try {
        await runShell("scripts/dev-fresh.sh");
        return { status: "success", message: "Fresh build complete" };
      } catch (err) {
        return { status: "error", message: "[Cade execShell fail] " + ((err as any)?.message || String(err)) };
      }
    }

    default:
      return { status: "error", message: `Unknown command: ${command}` };
  }
}
