import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';

export const tasks = sqliteTable('tasks', {
  id: text('id').primaryKey().notNull(),
  type: text('type').notNull(),
  payload: text('payload').notNull(),
  status: text('status').notNull(),
  created_at: text('created_at').notNull(),
  completed_at: text('completed_at'), // may be null
});

export const agent_state = sqliteTable('agent_state', {
  agent: text('agent').primaryKey().notNull(),
  status: text('status').notNull(),
  last_ts: integer('last_ts').notNull(),
});
