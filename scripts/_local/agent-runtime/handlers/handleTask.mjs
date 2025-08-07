import fs from "fs";
import path from "path";
import { execSync } from "child_process";

export function handleTask(task) {
  const log = (msg) => console.log(`[${new Date().toISOString()}] ${msg}`);
  const outputDir = path.join(process.cwd(), "scripts/_local/agent-runtime/output");

  if (!task?.type) {
    log("❌ No task type found.");
    return;
  }

  if (task.type === "generate_file") {
    const filePath = path.join(process.cwd(), task.path || "output.txt");
    const content = task.content || "";
    const dirPath = path.dirname(filePath);
    fs.mkdirSync(dirPath, { recursive: true });

    try {
      fs.writeFileSync(filePath, content, "utf8");
      log(`📄 File generated: ${filePath}`);
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

  const dbPath = path.join(process.cwd(), "scripts/_local/agent-runtime/memory/agent_brain.db");
  fs.appendFileSync(dbPath, `[${new Date().toISOString()}] ✅ Task recorded in DB.\n`);
}
