import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";

export const agentTasks = sqliteTable("agent_tasks", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  agent: text("agent").notNull(),
  type: text("type").notNull(),
  status: text("status").default("Idle"),
  content: text("content"),
  ts: integer("ts", { mode: "timestamp" }).default(() => Date.now()),
});
