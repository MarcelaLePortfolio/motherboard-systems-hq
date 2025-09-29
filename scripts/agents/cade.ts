console.log("🔍 <0001FAC7> Cade command router loaded from", import.meta.url);
import fs from "fs";
import path from "path";
import crypto from "crypto";

const cadeCommandRouter = async (command: string, payload: any = {}) => {
  let result = "";

  switch (command) {
    case "write to file": {
      const { path: filePath, content } = payload;
      const resolvedPath = path.resolve(filePath);
      try {
        fs.writeFileSync(resolvedPath, content, "utf8");
        const fileBuffer = fs.readFileSync(resolvedPath);
        const hash = crypto.createHash("sha256").update(fileBuffer).digest("hex");
        result = `📝 File written to "${filePath}" (sha256: ${hash})`;
      } catch (err: any) {
  console.error("❌ CAUGHT ERROR:", err);        result = `❌ Error: ${err.message || String(err)}`;
      }
      break;
    }

    case "dev:clean": {
      return await runShell("scripts/dev-clean.sh");
    }

    case "dev:fresh": {
      return await runShell("scripts/dev-fresh.sh");
    }
    default: {
      result = "🤷 Unknown task type";
    }



    }

    return { status: "success", result };
};

export { cadeCommandRouter };


// 🔁 Run Cade if executed directly (ESM-compatible)
if (import.meta.url === `file://${process.argv[1]}`) {
  const TASK_FOLDER = "memory/tasks";

  if (fs.existsSync(TASK_FOLDER)) {
    const taskFiles = fs.readdirSync(TASK_FOLDER).filter(f => f.endsWith(".json"));

    for (const file of taskFiles) {
      const taskPath = path.join(TASK_FOLDER, file);
      const raw = fs.readFileSync(taskPath, "utf8");
      const task = JSON.parse(raw);
      console.log("📦 Running task:", task);
      cadeCommandRouter(task.type, task.payload).then(res => {
        console.log("🤖 Cade ran the command");
        console.log(`📁 ${file} →`, res);
      });
    }
  }
}

// 🧩 Added by <0001f9f9> — Dev maintenance commands
