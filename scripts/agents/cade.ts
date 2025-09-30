import path from "path";
import { pathToFileURL } from "url";

const { runShell: execShell } = await import(
  pathToFileURL(path.resolve("scripts/utils/runShell.ts")).href
);
console.log("<0001FB1F> [Cade] dynamic import of runShell succeeded, type:", typeof execShell);

export const cadeCommandRouter = async (command: string, payload: any = {}) => {
  let result = "";

  try {
    console.log("<0001FB18> [Cade] cadeCommandRouter invoked with command:", command);
    console.log("<0001FB18> [Cade] typeof execShell at runtime:", typeof execShell);

    switch (command) {
      case "dev:clean": {
        console.log("<0001FB20> [Cade] running dev:clean via execShell");
        try {
          const out = await execShell("scripts/dev-clean.sh");
          return { status: "success", result: out };
        } catch (err) {
          console.error("<0001FB20> [Cade] execShell threw:", err);
          return { status: "error", message: "[Cade execShell fail] " + (err?.message || String(err)) };
        }
      }

      case "dev:fresh": {
        console.log("<0001FB20> [Cade] running dev:fresh via execShell");
        try {
          const out = await execShell("scripts/dev-fresh.sh");
          return { status: "success", result: out };
        } catch (err) {
          console.error("<0001FB20> [Cade] execShell threw:", err);
          return { status: "error", message: "[Cade execShell fail] " + (err?.message || String(err)) };
        }
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
