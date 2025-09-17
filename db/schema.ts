import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';

export const tasks = sqliteTable('tasks', {
  uuid: text('uuid').primaryKey(),
  type: text('type'),
  content: text('content'),
  status: text('status'),
  agent: text('agent'),
  created_at: integer('created_at', { mode: 'timestamp' }),
  triggered_by: text('triggered_by'), // if you use this field
});
