import { sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const task_output = sqliteTable('task_output', {
  id: text('id').primaryKey().notNull(),
  task_id: text('task_id').notNull(),
  actor: text('actor'),
  field: text('field').notNull(),
  value: text('value'),
  created_at: text('created_at').notNull(),
});
