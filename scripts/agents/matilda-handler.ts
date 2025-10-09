import { spawn } from "child_process";
import fs from "fs";
import path from "path";

export async function matildaHandler(message: string): Promise<string> {
  console.log("🤖 Matilda delegating to Cade:", message);

  // Create a reflection task file
  const taskDir = path.join(process.cwd(), "memory", "tasks");
  const taskFile = path.join(taskDir, `reflection_${Date.now()}.json`);

  const payload = {
    id: `reflection_${Date.now()}`,
    type: "reflection",
    actor: "matilda",
    message,
    created_at: new Date().toISOString()
  };

  fs.mkdirSync(taskDir, { recursive: true });
  fs.writeFileSync(taskFile, JSON.stringify(payload, null, 2), "utf8");

  // Optionally, trigger Cade immediately
  try {
    const cade = spawn("npx", ["tsx", "scripts/agents/cade.ts", "process", taskFile]);
    cade.stdout.on("data", data => process.stdout.write(`🧩 Cade: ${data}`));
    cade.stderr.on("data", data => process.stderr.write(`⚠️ Cade error: ${data}`));
  } catch (err) {
    console.error("Failed to trigger Cade:", err);
  }

  return `Task queued for Cade → ${taskFile}`;
}
