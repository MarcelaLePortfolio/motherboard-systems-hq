import { createRequire } from "module";
const require = createRequire(import.meta.url);
const { runShell } = require("../utils/runShell");

export const cadeCommandRouter = async (command: string, payload: any = {}) => {
  let result = "";
  try {
    switch (command) {
      case "dev:clean": {
        console.log("<0001FB24> [Cade] running dev:clean via execShell");
        try {
          const out = await runShell("scripts/dev-clean.sh");
          return { status: "success", result: out };
        } catch (err) {
          console.error("<0001FB24> [Cade] execShell threw:", err);
          return { status: "error", message: "[Cade execShell fail] " + (err?.message || String(err)) };
        }
      }
  let result = "";

  try {
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

        break;
      }

      case "dev:fresh": {
        console.log("<0001FB24> [Cade] running dev:fresh via execShell");
        try {
          const out = await runShell("scripts/dev-fresh.sh");
          return { status: "success", result: out };
        } catch (err) {
          console.error("<0001FB24> [Cade] execShell threw:", err);
          return { status: "error", message: "[Cade execShell fail] " + (err?.message || String(err)) };
        }
      }

      default: {
        result = "�� Unknown task type";
      }
    }

    return { status: "success", result };
  } catch (err: any) {
    console.error("<0001FB16> [Cade Catch] FULL ERROR object:", err);
    console.error("<0001FB16> [Cade Catch] FULL ERROR stack:", err?.stack);
    return { status: "error", message: "[Cade Catch] " + (err?.message || String(err)) };
  }
};
