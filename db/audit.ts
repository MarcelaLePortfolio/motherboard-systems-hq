import { sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const task_events = sqliteTable('task_events', {
  id: text('id').primaryKey().notNull(),                 // uuid
  task_id: text('task_id'),                              // optional link to tasks.id
  type: text('type'),                                    // e.g., 'write to file'
  status: text('status'),                                // 'success' | 'error'
  actor: text('actor'),                                  // 'matilda' | 'cli' | 'system'
  payload: text('payload'),                              // JSON string
  result: text('result'),                                // JSON string
  file_hash: text('file_hash'),                          // sha256 for file writes
  created_at: text('created_at')                         // ISO timestamp
});
