import { db } from './client';
import { tasks } from './schema';
import { task_events } from './audit';
import { v4 as uuidv4 } from 'uuid';
import { eq } from 'drizzle-orm';

type Status = 'success' | 'error' | 'delegated' | 'unknown';

export async function logTask(
  type: string,
  payload: Record<string, any>,
  status: Status,
  result?: Record<string, any>,
  opts?: { actor?: string; taskId?: string; fileHash?: string }
) {
  const id = uuidv4(); // unique audit row id
  const createdAt = new Date().toISOString();

  const actor = opts?.actor ?? (process.env.CADE_ACTOR || 'cli');
  const taskId = opts?.taskId ?? id;
  const fileHash = opts?.fileHash ?? null;

  const payloadStr = JSON.stringify(payload ?? {});
  const resultStr = JSON.stringify(result ?? {});

  // --- summary row in tasks ---
  try {
    if (status === 'delegated') {
      // First log: create the row
      await db.insert(tasks).values({
        id: taskId,
        type,
        status,
        payload: payloadStr,
        created_at: createdAt,
        completed_at: null,
      }).execute();
    } else {
      // Later logs: update the row
      await db.update(tasks)
        .set({
          status,
          completed_at: status === 'success' ? createdAt : null,
        })
        .where(eq(tasks.id, taskId))
        .execute();
    }
  } catch (err) {
    console.error('logTask: failed to insert/update tasks', err);
  }

  // --- detailed immutable audit trail ---
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
