import fs from "fs";
import path from "path";
import { execSync } from "child_process";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const outputDir = path.join(__dirname, "../output");

function log(msg) {
  console.log(`[${new Date().toISOString()}] ${msg}`);
}

function handleTask(task) {
  if (!task?.type) {
    log("❌ No task type found.");
    return;
  }

  if (task.type === "generate_file") {
    const filePath = path.join(outputDir, task.path || "output.txt");
    const content = task.content || "";

    try {
      fs.writeFileSync(filePath, content, "utf8");
      log(`�� File generated: ${filePath}`);
    } catch (err) {
      log(`❌ File write error: ${err.message}`);
    }
  }

  if (task.type === "run_shell") {
    try {
      const result = execSync(task.command, { encoding: "utf8" });
      log(`💻 Shell result:\n${result}`);
    } catch (err) {
      log(`❌ Shell execution error:\n${err.message}`);
    }
  }

  const dbPath = path.join(__dirname, "../memory/agent_brain.db");
  fs.appendFileSync(dbPath, `[${new Date().toISOString()}] ✅ Task recorded in DB.\n`);
}

export default handleTask;
