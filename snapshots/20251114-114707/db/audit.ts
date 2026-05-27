import { integer } from "drizzle-orm/sqlite-core";
import { sqliteTable, text } from "drizzle-orm/sqlite-core";

export const task_events = sqliteTable("task_events", {
  id: text("id").primaryKey().notNull(),
  id: integer("id").primaryKey({ autoIncrement: true }),
  type: text("type"),
  status: text("status"),
  payload: text("payload"),
  result: text("result"),
  file_hash: text("file_hash"),
  created_at: text("created_at"),
});
