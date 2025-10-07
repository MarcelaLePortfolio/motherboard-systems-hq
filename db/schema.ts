// <0001fb38> reflections schema definition
import { sqliteTable, text } from "drizzle-orm/sqlite-core";

export const reflections = sqliteTable("reflections", {
  id: text("id").primaryKey().notNull(),
  created_at: text("created_at").notNull(),
  summary: text("summary"),
});
