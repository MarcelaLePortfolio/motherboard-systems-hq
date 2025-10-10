import { spawn } from "child_process";
import fs from "fs";
import path from "path";

const DELEGATION_KEYWORDS = [/\btask\b/i, /\breflection\b/i, /\bCade\b/i, /\bprocess\b/i];

export async function matildaHandler(message: string): Promise<string> {
  const isDelegation = DELEGATION_KEYWORDS.some(rx => rx.test(message));

  // Conversational fallback
  if (!isDelegation) {
    return `Matilda 💁‍♀️: Hello there! You said, “${message}.” I’m here and listening — would you like me to log a reflection or pass this along to Cade?`;
  }

  console.log("🤖 Matilda delegating to Cade:", message);

  // Create reflection task
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

  // Trigger Cade
  try {
    const cade = spawn("npx", ["tsx", "scripts/agents/cade.ts", "process", taskFile]);
    cade.stdout.on("data", data => process.stdout.write(`🧩 Cade: ${data}`));
    cade.stderr.on("data", data => process.stderr.write(`⚠️ Cade error: ${data}`));
  } catch (err) {
    console.error("Failed to trigger Cade:", err);
  }

  return `Task queued for Cade → ${taskFile}`;
}
