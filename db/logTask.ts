// db/logTask.ts
import { db } from './client';
import { tasks } from './schema';
import { v4 as uuidv4 } from 'uuid';
import { eq } from 'drizzle-orm';

export interface TaskLog {
  id?: string;
  type: string;
  status: string;
  payload?: Record<string, any>;
  result?: Record<string, any>;
  triggered_by?: string;
}

export async function logTask(entry: TaskLog) {
  const id = entry.id || uuidv4();
  const now = new Date().toISOString();

  // Insert new row
  await db.insert(tasks).values({
    id,
    type: entry.type,
    status: entry.status,
    payload: entry.payload ? JSON.stringify(entry.payload) : null,
    completed_at: now,
    created_at: now,
    // only include if schema has triggered_by
    ...(entry.triggered_by ? { triggered_by: entry.triggered_by } : {}),
  });

  return { id, ...entry, created_at: now };
}

// Optional: mark task as updated (useful for retries/failures)
export async function updateTaskStatus(id: string, status: string, result?: Record<string, any>) {
  const now = new Date().toISOString();
  await db
    .update(tasks)
    .set({
      status,
      completed_at: now,
      ...(result ? { payload: JSON.stringify(result) } : {}),
    })
    .where(eq(tasks.id, id));
}
