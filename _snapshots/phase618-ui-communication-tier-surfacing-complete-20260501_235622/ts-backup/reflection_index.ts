import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";

export const reflection_index = sqliteTable("reflection_index", {
  id: text("id").primaryKey(),
  related_event_id: text("related_event_id"),
  agent: text("agent"),
  insight: text("insight"),
  confidence: integer("confidence"),
  created_at: text("created_at"),
});
