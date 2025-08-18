import path from 'path';
import fs from 'fs';

import { generateFileWithOllama } from './handlers/generateFileWithOllama';
import { explainCodeWithOllama } from './handlers/summarizeWithOllama';
import { explainCodeWithOllama } from './handlers/explainCodeWithOllama';
import { formatCommentsWithOllama } from './handlers/formatCommentsWithOllama';
import { cadeCommandRouter } from "../handlers/cade_router";
import { runCommandWithCade } from './handlers/runCommandWithCade';
import { commentCodeWithOllama } from './handlers/commentCodeWithOllama';
import { translateCommentsWithOllama } from './handlers/translateCommentsWithOllama';
import { convertCodeWithOllama } from './handlers/convertCodeWithOllama';
import { refactorCodeWithOllama } from './handlers/refactorCodeWithOllama';
import { installDepsWithCade } from './handlers/installDepsWithCade';
import { startAgentWithPM2 } from './handlers/startAgentWithPM2';

import { ensureDir } from '../../_local/utils/fsHelpers';


function validateSafePath(inputPath: string, opts: { allowNonexistent?: boolean; mustBeWithinCwd?: boolean } = {}) {
  if (!inputPath || typeof inputPath !== 'string') throw new Error('No file path provided.');
  const resolved = path.resolve(inputPath);
  const cwd = process.cwd();

  if (opts.mustBeWithinCwd !== false) {
    if (!resolved.startsWith(cwd + path.sep) && resolved !== cwd) {
      throw new Error('Unsafe file path.');
    }
  }

  if (!opts.allowNonexistent && !fs.existsSync(resolved)) {
    throw new Error('File does not exist.');
  }

  return resolved;
}

async function reportAgentStatusWithCade(_: any) {
  const { execSync } = await import('node:child_process');
  try {
    const output = execSync('pm2 jlist', { encoding: 'utf8' });
    const list = JSON.parse(output);
    const agentNames = ['cade', 'matilda', 'effie'];
    const statuses = Object.fromEntries(
      agentNames.map(name => {
        const found = list.find(proc => proc.name === name);
        return [name, found ? found.pm2_env.status : 'offline'];
      })
    );
    return { status: "success", agents: statuses };
  } catch (err: any) {
    return { status: "error", message: err.message };
  }
}

async function createBackupWithCade(_: any) {
  const { spawn } = await import("node:child_process");
  return new Promise((resolve) => {
    const child = spawn("bash", ["scripts/_local/create_full_backup.sh"], {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"]
    });
    let output = "";
    let error = "";
    child.stdout.on("data", (data) => {
      output += data.toString();
    });
    child.stderr.on("data", (data) => {
      error += data.toString();
    });
    child.on("close", (code) => {
      if (code === 0) {
        resolve({ status: "success", message: output.trim() });
      } else {
        resolve({ status: "error", message: error.trim() || "Backup failed" });
      }
    });
    child.on("error", (err) => {
      resolve({ status: "error", message: err.message });
    });
  });
}
async function runTestsWithCade(_: any) {
  const { readdirSync } = await import("node:fs");
  const { spawnSync } = await import("node:child_process");
  const path = "scripts/tests";
  const skip = ["watch_agent_state.sh"];
  const files = readdirSync(path).filter(f => f.endsWith(".sh") && !skip.includes(f));

  const results = files.map(file => {
    const fullPath = `${path}/${file}`;
    const result = spawnSync("bash", [fullPath], { encoding: "utf8", timeout: 10000 });
    return {
      file,
      success: result.status === 0,
      output: result.stdout?.trim() || result.stderr?.trim() || "No output"
    };
  });

  return { status: "success", results };
}
async function listFilesWithCade(args: any) {
  const { readdirSync, statSync } = await import("node:fs");
  const { join, resolve } = await import("node:path");
  const ROOT = resolve(".");

  function walk(dir: string) {
    const result: any[] = [];
    const entries = readdirSync(dir);

    for (const entry of entries) {
      const fullPath = resolve(dir, entry);
      if (!fullPath.startsWith(ROOT)) continue;

      const stats = statSync(fullPath);
      result.push(
        stats.isDirectory()
          ? { type: "folder", name: entry, children: walk(fullPath) }
          : { type: "file", name: entry }
      );
    }

    return result;
  }

  const targetDir = args?.path || ".";
  try {
    const tree = walk(targetDir);
    return { status: "success", tree };
  } catch (err: any) {
    return { status: "error", message: err.message };
  }
}
async function deleteWithCade(args: any) {
  const { rmSync, statSync } = await import("node:fs");
  const { resolve } = await import("node:path");

  const ROOT = resolve(".");
  const target = resolve(args?.path || "");

  if (!target.startsWith(ROOT)) {
    return { status: "error", message: "Unsafe delete path rejected." };
  }

  try {
    const stats = statSync(target);
    rmSync(target, { recursive: stats.isDirectory(), force: true });
    return { status: "success", message: `🗑️ Deleted: ${target}` };
  } catch (err: any) {
    return { status: "error", message: err.message };
  }
}

async function commitChangesWithCade(args: any) {
  const { exec } = await import("node:child_process");

  const commitMessage =
    args?.message?.trim() || "🧠 Cade auto-commit: unspecified changes";

  const commands = `
    git add . &&
    git commit -m "${commitMessage.replace(/"/g, '\\"')}"
  `;

  return new Promise((resolve) => {
    exec(commands, (err, stdout, stderr) => {
      if (err) {
        resolve({ status: "error", message: stderr.trim() || err.message });
      } else {
        resolve({ status: "success", message: stdout.trim() });
      }
    });
  });
}

async function inferAgentWithCade(args: any) {
  const description = (args?.description || "").toLowerCase();

  const rules = [
    { keywords: ["local", "desktop", "screenshot", "open app"], agent: "Effie", reason: "Desktop or local operations" },
    { keywords: ["code", "script", "file", "backup", "test", "git", "commit"], agent: "Cade", reason: "Backend or file-based task" },
    { keywords: ["message", "delegate", "ask", "respond", "friendly"], agent: "Matilda", reason: "Conversation or delegation task" },
  ];

  for (const rule of rules) {
    if (rule.keywords.some(k => description.includes(k))) {
      return {
        status: "success",
        agent: rule.agent,
        reason: rule.reason,
      };
    }
  }

  return {
    status: "uncertain",
    agent: "Matilda",
    reason: "Defaulting to Matilda (no strong match)",
  };
}

export async function handleTask(task: any) {
  const { command, args } = task;

  switch (command) {
    case "chain": {
      const steps = [
        { command: "generate", args: { type: "README" } },
        { command: "commit", args: { message: "📄 Initial scaffold commit" } }
      ];

      const results = [];

      for (const step of steps) {
        console.log(`🔁 Running step: ${step.command}`);
  console.log("<0001f9eb> Type of cadeCommandRouter:", typeof cadeCommandRouter);
        const result = await cadeCommandRouter(step.command, step.args);
  console.log("🧪 Raw result:", result);

  if (!result || typeof result !== "object") {
    console.log(`❌ Invalid result for step: ${step.command}`);
    break;
  }
        results.push({ step: step.command, result });

        if (result.status !== "success") {
          console.log(`❌ Step failed: ${step.command}`);
          break;
        }
      }

      return { status: "completed", results };
    }

    default:
      return { status: "error", message: `Unknown command: ${command}` };
  }
}
