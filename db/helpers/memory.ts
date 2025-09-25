import { db } from '../db-core';
import { task_events } from '../schema';
import { and, eq, like } from 'drizzle-orm';

/**
 * Search past task results for a given agent (actor).
 * Optionally filter by type or match result content.
 */
export async function queryTaskOutput({
  actor,
  type,
  contains
}: {
  actor?: string;
  type?: string;
  contains?: string;
}) {
  let conditions = [];

  if (actor) conditions.push(eq(task_events.actor, actor));
  if (type) conditions.push(eq(task_events.type, type));
  if (contains) conditions.push(like(task_events.result, `%${contains}%`));

  return db
    .select()
    .from(task_events)
    .where(conditions.length ? and(...conditions) : undefined)
    .orderBy(task_events.created_at)
    .all();
}
