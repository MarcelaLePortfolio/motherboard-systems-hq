import { sqliteTable, text } from "drizzle-orm/sqlite-core";

export const task_events = sqliteTable("task_events", {
  id: text("id").primaryKey().notNull(),
  task_id: text("task_id"),
  type: text("type"),
  status: text("status"),
  actor: text("actor"),
  payload: text("payload"),
  result: text("result"),
  file_hash: text("file_hash"),
  created_at: text("created_at"),
});
