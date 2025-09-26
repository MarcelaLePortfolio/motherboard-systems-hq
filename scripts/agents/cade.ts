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
        result = `❌ Error: ${err.message || String(err)}`;
      }
      break;
    }

    default: {
      result = "🤷 Unknown task type";
    }
  }







// 🔁 Auto-run tasks from memory/tasks/*.json
const TASK_FOLDER = "memory/tasks";

if (fs.existsSync(TASK_FOLDER)) {
  const taskFiles = fs.readdirSync(TASK_FOLDER).filter(f => f.endsWith(".json"));

  for (const file of taskFiles) {
    const taskPath = path.join(TASK_FOLDER, file);
    const raw = fs.readFileSync(taskPath, "utf8");
    const task = JSON.parse(raw);
    cadeCommandRouter(task.type, task.payload).then(res => {
      console.log(`📁 ${file} →`, res);
    });
  }
}

  return { status: "success", result }; }; export { cadeCommandRouter };
