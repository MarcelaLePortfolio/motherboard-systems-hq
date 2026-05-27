import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";
export const task_events = sqliteTable("task_events", {
  // Most common pattern in this repo:
  id: integer("id").primaryKey({ autoIncrement: true }),

  // Adjust these to match your CREATE TABLE statement exactly:
  kind: text("kind"),
  payload: text("payload"),
  created_at: text("created_at"),
});
