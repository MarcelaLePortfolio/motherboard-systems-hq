import { sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const task_output = sqliteTable('task_output', {
  id: text('id').primaryKey().notNull(),     // uuid
  task_id: text('task_id').notNull(),        // FK to tasks.id
  actor: text('actor'),
  type: text('type'),                        // 'result' or other tags
  result: text('result'),                    // JSON string of the output
  reflection: text('reflection'),            // ✅ New: Human-friendly summary
  created_at: text('created_at'),            // ISO timestamp
});
