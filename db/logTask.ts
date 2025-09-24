import { db } from './client';
import { tasks } from './tasks';
import { task_events } from './audit';
import { task_output } from './output';
import { v4 as uuidv4 } from 'uuid';

export async function logTask({
  taskId,
  eventType,
  status,
  actor,
  payload,
  result,
  file_hash,
  reflection,
  completed_at
}: {
  taskId?: string;
  eventType: string;
  status: string;
  actor: string;
  payload?: string;
  result?: string;
  file_hash?: string;
  reflection?: string;
  completed_at?: string | null;
}) {
  try {
    const now = new Date().toISOString();
    const id = taskId ?? uuidv4();

    await db.insert(tasks).values({
      id,
      type: eventType,
      status,
      actor,
      payload,
      result,
      file_hash,
      created_at: now,
      completed_at: completed_at ?? (status !== 'delegated' ? now : null),
      triggered_by: null,
    });

    await db.insert(task_events).values({
      id: uuidv4(),
      task_id: id,
      actor,
      type: eventType,
      status,
      payload,
      result,
      file_hash,
      created_at: now,
    });

    await db.insert(task_output).values({
      id: uuidv4(),
      task_id: id,
      actor,
      type: eventType,
      result,
      reflection,
      created_at: now,
    });

  } catch (err) {
    console.error('logTask: failed to insert/update tasks', err);
  }
}
