import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';

export const tasks = sqliteTable('tasks', {
  id: text('id').primaryKey(),
  type: text('type'),
  payload: text('payload'),
  status: text('status'),
  created_at: text('created_at'),
  completed_at: text('completed_at').nullable(),
});

export const agent_state = sqliteTable('agent_state', {
  agent: text('agent').primaryKey(),
  status: text('status'),
  last_ts: integer('last_ts'),
});
