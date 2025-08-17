import path from 'path';
import fs from 'fs';

import { generateFileWithOllama } from './handlers/generateFileWithOllama';
import { summarizeWithOllama } from './handlers/summarizeWithOllama';
import { explainCodeWithOllama } from './handlers/explainCodeWithOllama';
import { formatCommentsWithOllama } from './handlers/formatCommentsWithOllama';
import { runCommandWithCade } from './handlers/runCommandWithCade';
import { commentCodeWithOllama } from './handlers/commentCodeWithOllama';
import { translateCommentsWithOllama } from './handlers/translateCommentsWithOllama';
import { convertCodeWithOllama } from './handlers/convertCodeWithOllama';
import { refactorCodeWithOllama } from './handlers/refactorCodeWithOllama';
import { installDepsWithCade } from './handlers/installDepsWithCade';
import { startAgentWithPM2 } from './handlers/startAgentWithPM2';

import { ensureDir } from '../../_local/utils/fsHelpers';

export async function cadeCommandRouter(command: string, args?: any) {
  try {
    switch (command) {
      case 'test': {
        return await runTestsWithCade(args);
      }
      case 'backup': {
        return await createBackupWithCade(args);
      }
      case 'status': {
        return await reportAgentStatusWithCade(args);
      }
      case 'translate': {
        return await translateCommentsWithOllama(args);
      }

      case 'convert': {
        return await convertCodeWithOllama(args);
      }

      case 'comment': {
        return await commentCodeWithOllama(args);
      }

      case 'refactor': {
        return await refactorCodeWithOllama(args);
      }

      case 'install dependencies': {
        return await installDepsWithCade(args);
      }

      case 'start agent': {
        return { status: 'error', message: `Unknown command: ${command}` };
    switch (command) {
      case 'test': {
        return await runTestsWithCade(args);
      }
      case 'backup': {
        return await createBackupWithCade(args);
      }
      case 'status': {
        return await reportAgentStatusWithCade(args);
      }
      case 'translate': {
        return await translateCommentsWithOllama(args);
      }
      case 'convert': {
        return await convertCodeWithOllama(args);
      }
      case 'comment': {
        return await commentCodeWithOllama(args);
      }
      case 'refactor': {
        return await refactorCodeWithCade(args);
      }
      case 'install dependencies': {
        return await installDepsWithCade(args);
      }
      case 'start agent': {
        return await startAgentWithPM2(args);
      }
      case 'generate': {
        return await generateFileWithOllama(args);
      }
      case 'summarize': {
        return await summarizeWithOllama(args);
      }
      case 'explain': {
        return await explainCodeWithOllama(args);
      }
      case 'format': {
        return await formatCommentsWithOllama(args);
      }
      case 'run command': {
        return await runCommandWithCade(args);
      }
      default:
        return { status: "error", message: `Unknown command: ${command}` };
    }
    }    }
  } catch (err: any) {
    return { status: 'error', message: err.message || String(err) };
  }
}

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