import { drizzle } from 'drizzle-orm/better-sqlite3';
import Database from 'better-sqlite3';
import { tasks, task_events } from './schema';

export const sqlite = new Database('db/dev.db');
export const db = drizzle(sqlite, {
  schema: { tasks, task_events },
});
