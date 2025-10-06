import { nanoid } from "nanoid";
import { mockTasks, mockLogs } from "../utils/dashboardMocks";
import { runShell } from "../utils/runShell";

// 🧠 CadeDynamic — adds fallback to Ollama planning for unknown commands
export async function cadeCommandRouter(command: string, payload?: any) {
  let result: any = { status: "pending", message: "" };
  const safePayload = payload || {}; // ensure payload is always defined

  try {
    switch (true) {
      case command === "dev:clean": {
        result = await runShell("scripts/dev-clean.sh");
        break;
      }

      case command === "demo:init": {
        result = { status: "success", message: "Dynamic Cade initialized" };
        break;
      }

      default: {
        // <0001f9e0> CadeDynamic doesn’t know this one — ask Ollama for a plan
        try {
          const { ollamaPlan } = await import("../utils/ollamaPlan");
          const { runSkill } = await import("../utils/runSkill");
          const plan = await ollamaPlan(command, safePayload);
          if (plan?.action) result = await runSkill(plan);
          else result = { status: "error", message: `Unknown command: ${command}` };
        } catch (err) {
          console.error("❌ Ollama delegation failed:", err);
          result = { status: "error", message: "Ollama delegation failed" };
        }
        break;
      }
    }

    // ✅ Update dashboard mocks on success
    mockTasks.push({
      id: safePayload?.id || nanoid(),
      command,
      status: "success",
      ts: new Date().toISOString(),
    });
    mockLogs.push({
      id: nanoid(),
      reflection: result?.message || command,
      ts: new Date().toISOString(),
    });

    return result;
  } catch (err: any) {
    // ❌ Update dashboard mocks on failure
    mockTasks.push({
      id: safePayload?.id || nanoid(),
      command,
      status: "failed",
      ts: new Date().toISOString(),
    });
    mockLogs.push({
      id: nanoid(),
      reflection: `❌ ${command} failed: ${err?.message || String(err)}`,
      ts: new Date().toISOString(),
    });
    return { status: "error", message: err?.message || String(err) };
  }
}
