import fs from "fs";
import path from "path";
import { handleGenerateFile } from "./handlers/handleGenerateFile.js";

const memoryPath = path.join(__dirname, "memory/agent_chain_state.json");

function log(msg) {
  const ts = new Date().toISOString();
  console.log(\`[\${ts}] Cade: \${msg}\`);
}

function main() {
  if (!fs.existsSync(memoryPath)) {
    log("⚠️ No task file found.");
    return;
  }

  let task;
  try {
    const raw = fs.readFileSync(memoryPath, "utf8");
    task = JSON.parse(raw);
  } catch (err) {
    log(\`❌ Failed to parse task: \${err.message}\`);
    return;
  }

  const { type, summary } = task || {};
  log(\`📬 Received task of type '\${type}' — \${summary || "No summary"}\`);

  if (type === "generate_file") {
    handleGenerateFile(summary);
  } else {
    log(\`⚠️ Unknown task type: \${type}\`);
  }
}

main();
