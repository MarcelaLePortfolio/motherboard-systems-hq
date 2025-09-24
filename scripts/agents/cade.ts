import fs from 'fs';
import path from 'path';
import lockfile from 'proper-lockfile';
import { v4 as uuidv4 } from 'uuid';
import { logTask } from '../../db/logTask';
import { sha256File } from '../utils/hash';
import { db } from '../../db/db-core';
import { task_output } from '../../db/output';

const TASKS_DIR = path.resolve('./memory/tasks');
const ROOT_MEMORY = path.resolve('./memory');
const LOG_DIR = path.resolve('./logs');
const JSONL_PATH = path.join(LOG_DIR, 'cade.jsonl');

// Configurable limits
const MAX_BYTES = Number(process.env.CADE_MAX_FILE_BYTES ?? 2_000_000); // 2MB
const ALLOW_EXTS = (process.env.CADE_ALLOWED_EXTS ?? '.txt,.md,.json,.yaml,.yml').split(',').map(s => s.trim().toLowerCase());
const READ_ONLY = String(process.env.CADE_READ_ONLY ?? 'false').toLowerCase() === 'true';

if (!fs.existsSync(LOG_DIR)) fs.mkdirSync(LOG_DIR, { recursive: true });
console.log('🟢 Cade starting... task folder:', TASKS_DIR);

// Minimal JSON-line logger (append-only)
function jsonl(data: Record<string, any>) {
  fs.appendFileSync(JSONL_PATH, JSON.stringify({ ts: new Date().toISOString(), ...data }) + '\n', 'utf-8');
}

function isInsideMemory(p: string) {
  const abs = path.resolve(p);
  return abs.startsWith(ROOT_MEMORY + path.sep) || abs === ROOT_MEMORY;
}

function extAllowed(p: string) {
  const ext = path.extname(p).toLowerCase() || '';
  return ALLOW_EXTS.includes(ext);
}

export async function cadeCommandRouter(
  type: 'read file' | 'write to file' | 'delete file',
  payload: { path: string; content?: string }
) {
  const taskId = uuidv4();
  const actor = process.env.CADE_ACTOR || 'cli';
  const filePath = path.resolve(payload.path);

  // Safety checks
  if (!isInsideMemory(filePath)) {
    const result = { message: 'Unsafe file path.' };
    jsonl({ taskId, actor, type, status: 'error', payload, result });
    await logTask(type, payload, 'error', result, { actor, taskId });
    return { status: 'error', result };
  }

  if (!extAllowed(filePath)) {
    const result = { message: `Extension not allowed. Allowed: ${ALLOW_EXTS.join(', ')}` };
    jsonl({ taskId, actor, type, status: 'error', payload, result });
    await logTask(type, payload, 'error', result, { actor, taskId });
    return { status: 'error', result };
  }

  if (READ_ONLY && type !== 'read file') {
    const result = { message: 'Read-only mode enabled.' };
    jsonl({ taskId, actor, type, status: 'error', payload, result });
    await logTask(type, payload, 'error', result, { actor, taskId });
    return { status: 'error', result };
  }

  // Ensure parent dirs
  fs.mkdirSync(path.dirname(filePath), { recursive: true });

  try {
    switch (type) {
      case 'read file': {
        if (!fs.existsSync(filePath)) {
          const result = { message: 'File does not exist.' };
          jsonl({ taskId, actor, type, status: 'error', payload, result });
          await logTask(type, payload, 'error', result, { actor, taskId });
          return { status: 'error', result };
        }
        const content = fs.readFileSync(filePath, 'utf-8');
        const result = { content };
        jsonl({ taskId, actor, type, status: 'success', payload, result });
        await logTask(type, payload, 'success', result, { actor, taskId, fileHash: sha256File(filePath) });
        await db.insert(task_output).values({
          id: uuidv4(),
          task_id: taskId,
          actor,
          field: 'result',
          value: JSON.stringify(result),
          created_at: new Date().toISOString(),
        });
        return { status: 'success', result };
      }

      case 'write to file': {
        const bytes = Buffer.byteLength(payload.content || '', 'utf8');
        if (bytes > MAX_BYTES) {
          const result = { message: `Content too large (${bytes} bytes). Max ${MAX_BYTES}.` };
          jsonl({ taskId, actor, type, status: 'error', payload: { ...payload, bytes }, result });
          await logTask(type, payload, 'error', result, { actor, taskId });
          return { status: 'error', result };
        }

        const release = await lockfile.lock(filePath, { realpath: false, retries: { retries: 4, minTimeout: 50, maxTimeout: 200 } }).catch(() => null);
        try {
          fs.writeFileSync(filePath, payload.content || '', 'utf-8');
          const hash = sha256File(filePath);
          const result = { message: `File written to ${payload.path}`, bytes, hash };
          jsonl({ taskId, actor, type, status: 'success', payload: { ...payload, bytes }, result });
          await logTask(type, payload, 'success', result, { actor, taskId, fileHash: hash });
          await db.insert(task_output).values({
            id: uuidv4(),
            task_id: taskId,
            actor,
            field: 'result',
            value: JSON.stringify(result),
            created_at: new Date().toISOString(),
          });
          return { status: 'success', result };
        } finally {
          await release?.();
        }
      }

      case 'delete file': {
        const release = await lockfile.lock(filePath, { realpath: false, retries: { retries: 3, minTimeout: 50, maxTimeout: 150 } }).catch(() => null);
        try {
          if (fs.existsSync(filePath)) {
            const hash = sha256File(filePath);
            fs.unlinkSync(filePath);
            const result = { message: `File deleted ${payload.path}`, prev_hash: hash };
            jsonl({ taskId, actor, type, status: 'success', payload, result });
            await logTask(type, payload, 'success', result, { actor, taskId, fileHash: hash });
            await db.insert(task_output).values({
              id: uuidv4(),
              task_id: taskId,
              actor,
              field: 'result',
              value: JSON.stringify(result),
              created_at: new Date().toISOString(),
            });
            return { status: 'success', result };
          } else {
            const result = { message: 'File does not exist.' };
            jsonl({ taskId, actor, type, status: 'error', payload, result });
            await logTask(type, payload, 'error', result, { actor, taskId });
            return { status: 'error', result };
          }
        } finally {
          await release?.();
        }
      }
    }
  } catch (err: any) {
    const result = { message: err.message || String(err) };
    jsonl({ taskId, actor, type, status: 'error', payload, result });
    await logTask(type, payload, 'error', result, { actor, taskId });
    return { status: 'error', result };
  }
}
