const TASKS_DIR = path.resolve("./memory/tasks");
import fs from "fs";
import path from "path";
import crypto from "crypto";

export const cadeCommandRouter = async (command: string, payload: any = {}) => {
  console.log("🧠 Cade ready to receive commands.");
  let result;

  switch (command) {
    case "write to file": {
        const { path: filePath, content } = payload;
      try {
        const resolvedPath = path.resolve(payload.path);
        fs.writeFileSync(resolvedPath, payload.content, "utf8");

        const fileBuffer = fs.readFileSync(resolvedPath);
        const hash = crypto.createHash("sha256").update(fileBuffer).digest("hex");

} catch (err: any) {
  result = `❌ Error: ${err.message || String(err)}`;
}
result = `📝 File written to "${filePath}"`;
return { status: "success", result };
      break;
    }

    default: {
    }
  }

  return result;
};

// �� Auto-run tasks from memory/tasks/*.json

// �� Auto-run tasks from memory/tasks/*.json

// �� Auto-run tasks from memory/tasks/*.json

// �� Auto-run tasks from memory/tasks/*.json
const isMain = import.meta.url === `file://${process.argv[1]}`;
if (isMain) {
  const files = fs.readdirSync(TASKS_DIR).filter(f => f.endsWith('.json'));

  for (const file of files) {
    try {
      const taskPath = path.join(TASKS_DIR, file);
      const raw = fs.readFileSync(taskPath, 'utf-8');
      const { type, payload } = JSON.parse(raw);

      console.log(`⚙️  Cade running task from file: ${file}`);
      cadeCommandRouter(type, payload).then(res => {
        console.log(`✅ Task complete: ${file}`, res);
        fs.unlinkSync(taskPath); // delete after success
      }).catch(err => {
        console.error(`❌ Task failed: ${file}`, err);
      });

    } catch (err) {
      console.error(`⚠️ Failed to process task file: ${file}`, err);
    }
  }
}
