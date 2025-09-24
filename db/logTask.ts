import { db } from './client';
import { tasks } from './schema';
import { task_events } from './audit';
import { v4 as uuidv4 } from 'uuid';

type Status = 'success' | 'error';

export async function logTask(
  type: string,
  payload: Record<string, any>,
  status: Status,
  result?: Record<string, any>,
  opts?: { actor?: string; taskId?: string; fileHash?: string }
) {
  const id = uuidv4();
  const createdAt = new Date().toISOString();

  const actor = opts?.actor ?? (process.env.CADE_ACTOR || 'cli');
  const taskId = opts?.taskId ?? id;
  const fileHash = opts?.fileHash;

  // legacy summary row in tasks (kept minimal & stable)
  db.insert(tasks).values({
    id: taskId,
    type,
    status,
    payload: JSON.stringify(payload),
    created_at: createdAt,
    completed_at: status === 'success' ? createdAt : null,
  }).run?.();

  // detailed immutable audit trail
  db.insert(task_events).values({
    id,
    task_id: taskId,
    type,
    status,
    actor,
    payload: JSON.stringify(payload),
    result: JSON.stringify(result ?? {}),
    file_hash: fileHash ?? null,
    created_at: createdAt
  }).run?.();

  return { id: taskId, audit_id: id, created_at: createdAt };
}
