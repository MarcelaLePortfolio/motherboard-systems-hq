/* eslint-disable import/no-commonjs */
import fs from "fs";
import path from "path";
import { spawn } from "child_process";
import lockfile from "proper-lockfile";
import { AnyTask, ShellTask, FileWriteTask, HttpRequestTask, AnyTaskT } from "./taskTypes";

const ROOT = process.cwd();
const STATE_PATH = path.join(ROOT, "memory/agent_chain_state.json");
const LEDGER_PATH = path.join(ROOT, "memory/cade_ledger.jsonl");
const LOG_DIR = path.join(ROOT, "logs");
fs.mkdirSync(LOG_DIR, { recursive: true });

const QUEUE_DIR = path.join(ROOT, "memory/queue");
fs.mkdirSync(QUEUE_DIR, { recursive: true });

function log(msg: string) {
  const line = `[${new Date().toISOString()}] ${msg}\n`;
  fs.appendFileSync(path.join(LOG_DIR, "cade.log"), line);
  // eslint-disable-next-line no-console
  console.log(line.trim());
}

function writeLedger(entry: object) {
  fs.appendFileSync(LEDGER_PATH, JSON.stringify(entry) + "\n");
}

function isDuplicate(taskId: string) {
  if (!fs.existsSync(LEDGER_PATH)) return false;
  const lines = fs.readFileSync(LEDGER_PATH, "utf8").trim().split("\n").slice(-1000);
  for (let i = lines.length - 1; i >= 0; i--) {
    try {
      const row = JSON.parse(lines[i]);
      if (row.taskId === taskId && row.status === "success") return true;
    } catch {}
  }
  return false;
}

async function runShell(task: AnyTaskT) {
  const t = ShellTask.parse(task);
  log(`🛠️ shell: ${t.command} (cwd=${t.cwd || ROOT})`);
  return await new Promise<{ exitCode: number | null; stdout: string; stderr: string }>((resolve, reject) => {
    const child = spawn(t.command, { shell: true, cwd: t.cwd || ROOT, env: process.env });
    let stdout = ""; let stderr = "";
    const to = setTimeout(() => child.kill("SIGTERM"), t.timeoutMs);
    child.stdout.on("data", d => (stdout += String(d)));
    child.stderr.on("data", d => (stderr += String(d)));
    child.on("error", reject);
    child.on("close", code => { clearTimeout(to); resolve({ exitCode: code, stdout, stderr }); });
  });
}

async function runFileWrite(task: AnyTaskT) {
  const t = FileWriteTask.parse(task);
  fs.mkdirSync(path.dirname(t.path), { recursive: true });
  fs.writeFileSync(t.path, t.contents, { mode: t.mode });
  return { ok: true, path: t.path };
}

async function runHttpRequest(task: AnyTaskT) {
  const t = HttpRequestTask.parse(task);
  const ctrl = new AbortController();
  const timeout = setTimeout(() => ctrl.abort(), t.timeoutMs);
  const res = await fetch(t.url, {
    method: t.method,
    headers: t.headers,
    body: t.body ? JSON.stringify(t.body) : undefined,
    signal: ctrl.signal
  });
  clearTimeout(timeout);
  const text = await res.text();
  return { status: res.status, ok: res.ok, text };
}

export async function processOnce() {
  // 1) Promote oldest queued task if no active state
  if (!fs.existsSync(STATE_PATH) || fs.statSync(STATE_PATH).size === 0) {
    const files = fs.readdirSync(QUEUE_DIR).filter(f => f.endsWith(".json")).sort();
    if (files.length === 0) { log("🟡 No runnable task in queue."); return; }
    const next = path.join(QUEUE_DIR, files[0]);
    try {
      fs.renameSync(next, STATE_PATH); // atomic promotion
    } catch {
      // Another process grabbed it; try next tick
      return;
    }
  }

  // 2) Now we must have a state file
  if (!fs.existsSync(STATE_PATH)) { log("🟡 No task file for Cade."); return; }

  // 3) Lock while we process
  const release = await lockfile.lock(STATE_PATH, { retries: { retries: 3, minTimeout: 100, maxTimeout: 1000 } });
  try {
    const raw = fs.readFileSync(STATE_PATH, "utf8").trim();
    if (!raw) { log("🟡 State file empty."); return; }

    let candidate: any;
    try {
      candidate = JSON.parse(raw);
    } catch {
      log("🟡 State file not valid JSON.");
      return;
    }
    if (!candidate || typeof candidate !== "object" || !candidate.taskId || !candidate.type) {
      log("🟡 No runnable task in state file.");
      return;
    }

if (!candidate || typeof candidate !== "object") {
  throw new Error("Invalid task object: " + JSON.stringify(candidate));
}

const taskPath = path.join(ROOT, "memory/queue/test-http-task.json");
const candidateRaw = fs.readFileSync(taskPath, "utf8");
try {
  candidate = JSON.parse(candidateRaw);
} catch (e) {
  throw new Error("❌ Invalid JSON in task file: " + e);
}
let task: AnyTaskT;
try {
  task = AnyTask.parse(candidate);
} catch (err) {
  console.error("❌ Failed to parse task with Zod:", err);
  throw err;
}
    if (isDuplicate(task.taskId)) { log(`⚠️ Duplicate taskId ${task.taskId}, skipping.`); return; }

    log(`📥 Task ${task.taskId} (${task.type})`);
    const startedAt = Date.now();
    let result: any;

    switch (task.type) {
      case "shell":       result = await runShell(task); break;
      case "fileWrite":   result = await runFileWrite(task); break;
      case "httpRequest": result = await runHttpRequest(task); break;
      case "noop":        result = { ok: true }; break;
      default:            throw new Error(`Unknown task type: ${(task as any).type}`);
    }

    const entry = { taskId: task.taskId, status: "success", type: task.type, result, startedAt, finishedAt: Date.now() };
    writeLedger(entry);
    log(`✅ Done ${task.taskId}`);

    // 4) Remove state so the next tick can promote from queue
    try { fs.rmSync(STATE_PATH, { force: true }); } catch {}
  } catch (err: any) {
    writeLedger({ status: "error", error: err?.message || String(err), when: Date.now() });
    log(`❌ Error: ${err?.message || String(err)}`);
  } finally {
    await release();
  }
}
await processOnce();


