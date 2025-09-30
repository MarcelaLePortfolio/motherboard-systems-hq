import { runShell } from "../utils/runShell";
const execShell = runShell;

console.log("<0001f7e2> [Cade] execShell available:", typeof execShell);

const cadeCommandRouter = async (command: string, payload: any = {}) => {
  let result = "";

  try {
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
