import { exec } from "child_process";

export async function runShell(cmd: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const child = exec(cmd, { cwd: process.cwd(), env: process.env });
    let output = "";
    child.stdout?.on("data", (data) => {
      process.stdout.write(data);
      output += data;
    });
    child.stderr?.on("data", (data) => {
      process.stderr.write(data);
      output += data;
    });
    child.on("close", (code) => {
      if (code === 0) resolve(output.trim());
      else reject(new Error(`Command \"${cmd}\" failed with code ${code}\n${output}`));
    });
  });
}
import { exec } from "child_process";

async function runShell(cmd: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const child = exec(cmd, { cwd: process.cwd(), env: process.env });
    let output = "";
    child.stdout?.on("data", (data) => {
      process.stdout.write(data);
      output += data;
    });
    child.stderr?.on("data", (data) => {
      process.stderr.write(data);
      output += data;
    });
    child.on("close", (code) => {
      if (code === 0) resolve(output.trim());
      else reject(new Error(`Command \"${cmd}\" failed with code ${code}\n${output}`));
    });
  });
}
console.log("🔍 <0001FAE5> Cade command router loaded from", import.meta.url);

import fs from "fs";
import crypto from "crypto";
import { exec } from "child_process";


console.log("🔧 runShell type at runtime:", typeof runShell);

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
        console.error("❌ CAUGHT ERROR:", err);
        result = `❌ Error: ${err.message || String(err)}`;
      }
      break;
    }

      console.log("🔧 runShell inside dev:clean:", typeof runShell);
    case "dev:clean": {
      return { status: "success", result: await (await import("./cade")).runShell("scripts/dev-clean.sh") };
    }
      console.log("🔧 runShell inside dev:fresh:", typeof runShell);

    case "dev:fresh": {
      return { status: "success", result: await (await import("./cade")).runShell("scripts/dev-fresh.sh") };
    }

    default: {
      result = "🤷 Unknown task type";
    }
  }

  return { status: "success", result };
};

export { cadeCommandRouter };

// 🔁 Run Cade if executed directly
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
