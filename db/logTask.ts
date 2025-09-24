import { db } from './client';
import { tasks } from './schema';
import { task_events } from './audit';
import { v4 as uuidv4 } from 'uuid';

type Status = 'success' | 'error' | 'delegated' | 'unknown';

interface LogTaskOptions {
  actor?: string;
  taskId?: string;
  fileHash?: string | null;
  id?: string;
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

  const payloadStr = JSON.stringify(payload ?? {});
  const resultStr = JSON.stringify(result ?? {});

  try {
    await db.insert(tasks).values({
      id: taskId,
      type,
      status,
      payload: payloadStr,
      created_at: createdAt,
      completed_at: status === 'success' ? createdAt : null,
    }).execute();
  } catch (err) {
    console.error('logTask: failed to insert into tasks', err);
  }

  try {
    await db.insert(task_events).values({
      id,
      task_id: taskId,
      type,
      status,
      actor,
      payload: payloadStr,
      result: resultStr,
      file_hash: fileHash,
      created_at: createdAt,
    }).execute();
  } catch (err) {
    console.error('logTask: failed to insert into task_events', err);
  }

  return { id: taskId, audit_id: id, created_at: createdAt };
}
