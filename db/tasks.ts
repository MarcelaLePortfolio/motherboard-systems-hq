import { sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const tasks = sqliteTable('tasks', {
  id: text('id').primaryKey().notNull(),
  type: text('type'),
  status: text('status'),
  actor: text('actor'),
  payload: text('payload'),
  result: text('result'),
  file_hash: text('file_hash'),
  created_at: text('created_at'),
  completed_at: text('completed_at'),         // ✅ add this missing field
  triggered_by: text('triggered_by'),         // optional FK
});
