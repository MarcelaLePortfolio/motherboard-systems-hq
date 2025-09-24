import { db } from './client';
import { tasks } from './schema';
import { task_events } from './audit';
import { v4 as uuidv4 } from 'uuid';

type Status = 'success' | 'error' | 'delegated' | 'unknown';

interface LogTaskOptions {
  actor?: string;
  taskId?: string;
  fileHash?: string | null;
  id?: string; // allow reuse of id across multiple inserts
}

export async function logTask(
  type: string,
  payload: Record<string, any>,
  status: Status,
  result?: Record<string, any>,
  opts?: LogTaskOptions
) {
  const id = opts?.id ?? uuidv4();
  const createdAt = new Date().toISOString();

  const actor = opts?.actor ?? (process.env.CADE_ACTOR || 'cli');
  const taskId = opts?.taskId ?? id;
  const fileHash = opts?.fileHash ?? null;

  // ensure strings for JSON columns
  const payloadStr = JSON.stringify(payload ?? {});
  const resultStr = JSON.stringify(result ?? {});

  // legacy summary row in tasks (kept minimal & stable)
  try {
    db.insert(tasks).values({
      id: taskId,
      type,
      status,
      payload: payloadStr,
      created_at: createdAt,
      completed_at: status === 'success' ? createdAt : null,
    }).run?.();
  } catch (err) {
    console.error('logTask: failed to insert into tasks', err);
  }

  // detailed immutable audit trail
  try {
    db.insert(task_events).values({
      id,
      task_id: taskId,
      type,
      status,
      actor,
      payload: payloadStr,
      result: resultStr,
      file_hash: fileHash,
      created_at: createdAt,
    }).run?.();
  } catch (err) {
    console.error('logTask: failed to insert into task_events', err);
  }

  return { id: taskId, audit_id: id, created_at: createdAt };
}
