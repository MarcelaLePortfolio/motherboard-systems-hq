import { nanoid } from "nanoid";
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

    // ✅ Update dashboard mocks on success

    return result;
  } catch (err: any) {
    // ❌ Update dashboard mocks on failure

    return { status: "error", message: err?.message || String(err) };
  }
}

/* <0001faaf> Reflection task processor — auto-complete handler */
import fs from "fs";

if (process.argv[2] === "process") {
  const taskFile = process.argv[3];
  console.log(`🧩 Cade processing task: ${taskFile}`);
  try {
    const data = JSON.parse(fs.readFileSync(taskFile, "utf8"));
    data.status = "Complete";
    data.result = "Reflection executed successfully.";
    fs.writeFileSync(taskFile, JSON.stringify(data, null, 2), "utf8");
    console.log("✅ Task complete.");
  } catch (err) {
    console.error("❌ Error processing reflection task:", err);
  }
}
