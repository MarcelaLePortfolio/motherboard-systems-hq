/* eslint-disable import/no-commonjs */
import fs from "fs";
import path from "path";
import { execSync } from "child_process";

function handleTask(task) {
  const log = (msg) => console.log(`[${new Date().toISOString()}] ${msg}`);

  if (!task?.type) {
    log("❌ No task type found.");
    return;
  }

  if (task.type === "generate_file") {
    const isCustomPath = !!task.path;
    const filePath = isCustomPath
      ? path.join(process.cwd(), task.path)
      : path.join(process.cwd(), "scripts/_local/agent-runtime/output/output.txt");

    const dirPath = path.dirname(filePath);
    const content = task.content || "";
    try {
      fs.mkdirSync(dirPath, { recursive: true });
      fs.writeFileSync(filePath, content, "utf8");
      log(`📄 File generated: ${filePath}`);
    } catch (err) {
      log(`❌ File write error: ${err.message}`);
    }
  }

  if (task.type === "run_shell") {
    try {
      const result = execSync(task.command, { encoding: "utf8" });
      log(`💻 Shell result:
${result}`);
    } catch (err) {
      log(`❌ Shell execution error:
${err.message}`);
    }
  }

  const dbPath = path.join(process.cwd(), "scripts/_local/agent-runtime/memory/agent_brain.db");
  fs.appendFileSync(dbPath, `[${new Date().toISOString()}] ✅ Task recorded in DB.
`);
}

export { handleTask };
