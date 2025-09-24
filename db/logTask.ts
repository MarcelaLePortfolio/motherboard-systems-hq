import { db } from './db-core';
import { tasks } from './tasks';
import { task_events } from './audit';
import { task_output } from './output';
import { eq } from 'drizzle-orm';
import { v4 as uuidv4 } from 'uuid';

export async function logTask(
  type: string,
  payload: Record<string, any>,
  status: 'success' | 'error',
  result: Record<string, any>,
  {
    actor,
    taskId,
    fileHash,
    eventType = 'result'
  }: {
    actor: string;
    taskId: string;
    fileHash?: string;
    eventType?: string;
  }
) {
  const now = new Date().toISOString();
  const reflection = `✅ ${type} ${status} for ${payload?.path || '[no path]'}`;

  try {
    // tasks table
    await db.insert(tasks).values({
      id: taskId,
      type,
      status,
      actor,
      payload: JSON.stringify(payload),
      result: JSON.stringify(result),
      file_hash: fileHash,
      created_at: now,
      completed_at: now,
    });

    // task_events table
    await db.insert(task_events).values({
      id: uuidv4(),
      task_id: taskId,
      actor,
      type: eventType,
      status,
      payload: JSON.stringify(payload),
      result: JSON.stringify(result),
      file_hash: fileHash,
      created_at: now,
    });

    // task_output table
    await db.insert(task_output).values({
      id: uuidv4(),
      task_id: taskId,
      actor,
      type: eventType,
      result: JSON.stringify(result),
      reflection,
      created_at: now,
    });

  } catch (err) {
    console.error('logTask: failed to insert/update tasks', err);
  }
}
