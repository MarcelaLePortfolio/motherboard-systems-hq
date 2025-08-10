/**
 * Cade Runtime Loop — Milestone 1 (refined)
 * Reacts to new tasks written by Matilda in memory/agent_chain_state.json.
 * Implements:
 *  1) Poll + fs.watch on agent_chain_state.json
 *  2) Detect new task via task.id (compared to last seen / lastProcessedTaskId)
 *  3) Log execution start & completion (clear, colored)
 *  4) Persist status "Completed" | "Failed" back to disk (atomic write)
 *  5) Emits clear console logs for PM2
 */

import * as fs from 'fs';
import * as fsp from 'fs/promises';
import * as path from 'path';
import { exec as execCb } from 'child_process';
import { setTimeout as delay } from 'timers/promises';
import { promisify } from 'util';

const exec = promisify(execCb);

// ANSI helpers for readable PM2 logs
const c = {
  dim: (s: string) => `\x1b[2m${s}\x1b[0m`,
  green: (s: string) => `\x1b[32m${s}\x1b[0m`,
  yellow: (s: string) => `\x1b[33m${s}\x1b[0m`,
  red: (s: string) => `\x1b[31m${s}\x1b[0m`,
  cyan: (s: string) => `\x1b[36m${s}\x1b[0m`,
  bold: (s: string) => `\x1b[1m${s}\x1b[0m`,
};

// ---------------------------
// Paths & bootstrap
// ---------------------------
const PROJECT_ROOT = process.cwd();
const MEMORY_DIR = path.join(PROJECT_ROOT, 'memory');
const STATE_FILE = path.join(MEMORY_DIR, 'agent_chain_state.json');

type Json = Record<string, any>;

type CadeTask = {
  id: string;
  type: string;
  params?: Record<string, any>;
  [k: string]: any;
};

type CadeResult = {
  taskId?: string;
  status: 'Completed' | 'Failed';
  message?: string;
  stdout?: string;
  stderr?: string;
  finishedAt?: string;
};

type CadeState = {
  agent?: string;
  status?: string;
  ts?: number;
  task?: CadeTask | null;
  lastProcessedTaskId?: string | null;
  lastResult?: CadeResult | null; // always object or null (never string)
  [k: string]: any;
};

let lastSeenTaskId: string | null = null;
let busy = false;
let watcher: fs.FSWatcher | null = null;

// Ensure memory dir and state file exist
async function ensureScaffold() {
  await fsp.mkdir(MEMORY_DIR, { recursive: true });
  if (!(await exists(STATE_FILE))) {
    const init: CadeState = {
      agent: 'Cade',
      status: 'Idle',
      ts: Date.now(),
      task: null,
      lastProcessedTaskId: null,
      lastResult: null,
    };
    await atomicWriteJson(STATE_FILE, init);
  }
}

async function exists(p: string) {
  try {
    await fsp.access(p, fs.constants.R_OK);
    return true;
  } catch {
    return false;
  }
}

// ---------------------------
// State helpers
// ---------------------------
async function readJson<T = Json>(file: string): Promise<T> {
  let raw: string | null = null;
  try {
    raw = await fsp.readFile(file, 'utf8');
  } catch {
    return {} as T;
  }
  try {
    return JSON.parse(raw ?? 'null') as T;
  } catch (err: any) {
    console.error(`[CADE] ${c.red('❌ Failed to parse JSON')} @ ${file}: ${err?.message}`);
    return {} as T;
  }
}

async function atomicWriteJson(file: string, data: any) {
  const tmp = `${file}.tmp-${Date.now()}`;
  const body = JSON.stringify(data, null, 2);
  await fsp.writeFile(tmp, body, 'utf8');
  await fsp.rename(tmp, file);
}

function coerceTaskFromState(state: CadeState): CadeTask | null {
  if (state?.task && typeof state.task === 'object') return state.task as CadeTask;
  const { id, type, params } = (state as any) ?? {};
  if (id && type) return { id: String(id), type: String(type), params: (params ?? {}) as Record<string, any> };
  return null;
}

// ---------------------------
// Task executors
// ---------------------------
async function exec_run_shell(params: Record<string, any>) {
  const cmd = params?.command || params?.cmd;
  if (!cmd || typeof cmd !== 'string') {
    throw new Error(`run_shell requires "command" string param`);
  }
  const { stdout, stderr } = await exec(cmd, {
    shell: '/bin/bash',
    cwd: PROJECT_ROOT,
    maxBuffer: 10 * 1024 * 1024,
  });
  return { stdout, stderr };
}

async function exec_generate_file(params: Record<string, any>) {
  const relPath: string = params?.path || params?.file || params?.filepath;
  const content: string = params?.content ?? '';
  if (!relPath || typeof relPath !== 'string') {
    throw new Error(`generate_file requires "path" string param`);
  }
  const abs = path.resolve(PROJECT_ROOT, relPath);
  if (!abs.startsWith(PROJECT_ROOT)) {
    throw new Error(`Refusing to write outside project root: ${relPath}`);
  }
  await fsp.mkdir(path.dirname(abs), { recursive: true });
  await fsp.writeFile(abs, String(content), 'utf8');
  return { stdout: `Wrote ${relPath} (${Buffer.byteLength(String(content), 'utf8')} bytes)`, stderr: '' };
}

const EXECUTORS: Record<string, (params: Record<string, any>) => Promise<{ stdout: string; stderr: string }>> = {
  run_shell: exec_run_shell,
  generate_file: exec_generate_file,
};

// ---------------------------
// Core loop
// ---------------------------
async function handlePossibleChange(trigger: 'watch' | 'poll' | 'startup') {
  if (busy) return;
  busy = true;
  try {
    const state = await readJson<CadeState>(STATE_FILE);

    // Normalize legacy "lastResult" if it was a string in older builds
    if (state && state.lastResult && typeof state.lastResult === 'string') {
      state.lastResult = {
        status: 'Completed',
        message: state.lastResult,
        finishedAt: new Date().toISOString(),
      };
    }

    const task = coerceTaskFromState(state);

    if (!task || !task.id) {
      await heartbeat('Idle');
      return;
    }

    const currentId = String(task.id);
    const alreadyProcessed = currentId === lastSeenTaskId || currentId === (state.lastProcessedTaskId ?? null);

    if (alreadyProcessed) {
      await heartbeat('Waiting');
      return;
    }

    lastSeenTaskId = currentId;
    const taskType = String(task.type || task['action'] || task['taskType'] || '');
    const params = (task.params ?? task['payload'] ?? {}) as Record<string, any>;

    console.log(`[CADE] ${c.bold('🔔 Detected new task')} (${trigger}): id=${c.cyan(currentId)} type=${c.yellow(taskType)}`);

    // Mark Running
    await writeStatus(state, {
      status: 'Running',
      note: `Cade started task: ${taskType}`,
    });

    console.log(`[CADE] ${c.bold('🚀 Executing')} id=${c.cyan(currentId)} type=${c.yellow(taskType)}`);

    const execFn = EXECUTORS[taskType];
    if (!execFn) {
      throw new Error(`Unknown task type "${taskType}". Supported: ${Object.keys(EXECUTORS).join(', ')}`);
    }

    const { stdout, stderr } = await execFn(params);

    console.log(`[CADE] ${c.green('✅ Completed')} id=${c.cyan(currentId)} type=${c.yellow(taskType)}`);
    await writeResult(state, {
      taskId: currentId,
      status: 'Completed',
      message: `Task ${taskType} completed`,
      stdout: safeSlice(stdout),
      stderr: safeSlice(stderr),
    });
  } catch (err: any) {
    const msg = err?.message || String(err);
    console.error(`[CADE] ${c.red('❌ Task failed')}: ${msg}`);
    try {
      const state = await readJson<CadeState>(STATE_FILE);
      const task = coerceTaskFromState(state);
      const failingId = task?.id ?? lastSeenTaskId ?? 'unknown';
      await writeResult(state, {
        taskId: String(failingId),
        status: 'Failed',
        message: msg,
        stdout: '',
        stderr: msg,
      });
    } catch (inner) {
      console.error(`[CADE] ${c.red('⚠️ Additionally failed writing failure status')}:`, inner);
    }
  } finally {
    busy = false;
  }
}

function safeSlice(s: string, max = 10000) {
  if (!s) return '';
  if (s.length <= max) return s;
  return s.slice(0, max) + `\n...[truncated ${s.length - max} chars]`;
}

async function heartbeat(status: 'Idle' | 'Waiting' | 'Running' = 'Idle') {
  const state = await readJson<CadeState>(STATE_FILE);
  const next: CadeState = {
    ...state,
    agent: 'Cade',
    status,
    ts: Date.now(),
  };
  await atomicWriteJson(STATE_FILE, next);
}

async function writeStatus(prev: CadeState, opts: { status: 'Running'; note?: string }) {
  const next: CadeState = {
    ...prev,
    agent: 'Cade',
    status: opts.status,
    ts: Date.now(),
  };
  await atomicWriteJson(STATE_FILE, next);
}

async function writeResult(prev: CadeState, result: {
  taskId: string;
  status: 'Completed' | 'Failed';
  message?: string;
  stdout?: string;
  stderr?: string;
}) {
  const next: CadeState = {
    ...prev,
    agent: 'Cade',
    status: result.status === 'Completed' ? 'Idle' : 'Failed',
    ts: Date.now(),
    lastProcessedTaskId: result.taskId,
    lastResult: {
      taskId: result.taskId,
      status: result.status,
      message: result.message,
      stdout: result.stdout,
      stderr: result.stderr,
      finishedAt: new Date().toISOString(),
    },
  };
  // Do NOT convert lastResult to a string; always keep object
  await atomicWriteJson(STATE_FILE, next);
}

// ---------------------------
// Watch + Poll orchestrator
// ---------------------------
async function start() {
  console.log(`[CADE] ${c.bold('🧠 Runtime loop starting')} @ ${new Date().toLocaleString()}`);
  await ensureScaffold();

  const initial = await readJson<CadeState>(STATE_FILE);
  if (initial?.lastProcessedTaskId) {
    lastSeenTaskId = String(initial.lastProcessedTaskId);
  }

  try {
    watcher = fs.watch(STATE_FILE, { persistent: true }, () => {
      handlePossibleChange('watch');
    });
    console.log(`[CADE] ${c.dim('Watching')} ${path.relative(PROJECT_ROOT, STATE_FILE)} ${c.dim('for changes')}`);
  } catch (err) {
    console.warn(`[CADE] ${c.yellow('⚠️ fs.watch failed; relying on polling')}`, err);
  }

  (async () => {
    while (true) {
      await handlePossibleChange('poll');
      await delay(1000);
    }
  })();

  await handlePossibleChange('startup');
}

function setupSignals() {
  const stop = async (sig: string) => {
    console.log(`[CADE] ${c.dim('🛑 Received')} ${sig}, ${c.dim('shutting down...')}`);
    try {
      watcher?.close();
    } catch {}
    process.exit(0);
  };
  process.on('SIGINT', () => stop('SIGINT'));
  process.on('SIGTERM', () => stop('SIGTERM'));
}

setupSignals();
start().catch(err => {
  console.error(`[CADE] ${c.red('Fatal error')}:`, err);
  process.exit(1);
});
