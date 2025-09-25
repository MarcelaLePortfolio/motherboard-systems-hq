import { db } from '../db-core';
import { task_events } from '../schema';
import { and, eq } from 'drizzle-orm';

export async function getRecentReflections({
  actor,
  type
}: {
  actor?: string;
  type?: string;
}) {
  let conditions = [];

  if (actor) conditions.push(eq(task_events.actor, actor));
  if (type) conditions.push(eq(task_events.type, type));

  return db
    .select()
    .from(task_events)
    .where(conditions.length ? and(...conditions) : undefined)
    .orderBy(task_events.created_at)
    .all();
}
