import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export async function handleTask(task) {
  const outputDir = path.join(__dirname, "../output");
  if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });

  const log = (msg) => {
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] ${msg}`);
  };

  if (task.type === "generate_file") {
    const outputPath = path.join(outputDir, "welcome_kit.md");
    const content = `# 🤖 Welcome to the Motherboard Systems HQ

## 🎯 Mission
To operate as a collaborative, secure, and private AI-driven environment—where agents like you empower Marcela’s creative and strategic work.

## 🧩 Your Role
- **Matilda**: Delegation, task routing, and status output.
- **Cade**: Backend automator, filewriter, coder, and data responder.
- **Effie**: Local ops, shell executor, and file assistant.

## 🆘 Need Help?
Find your coordination notes, workflows, and logic chain in the memory folder.

---

Welcome aboard, agent. 🧠💾 The system is counting on you.`;

    fs.writeFileSync(outputPath, content, "utf8");
    log(`📄 File generated at ${outputPath}`);
  }

  // ✅ Add future task handlers here...

  // Always record completion
  const dbPath = path.join(__dirname, "../memory/agent_brain.db");
  fs.appendFileSync(dbPath, `[${new Date().toISOString()}] ✅ Task recorded in DB.\n`);
}
