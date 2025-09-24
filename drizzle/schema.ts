import { sqliteTable, AnySQLiteColumn, text, integer } from "drizzle-orm/sqlite-core"
  import { sql } from "drizzle-orm"

export const agentState = sqliteTable("agent_state", {
	agent: text().primaryKey().notNull(),
	status: text(),
	lastTs: integer("last_ts"),
});

export const tasks = sqliteTable("tasks", {
	id: text().primaryKey().notNull(),
	type: text(),
	payload: text(),
	status: text(),
	createdAt: text("created_at"),
	completedAt: text("completed_at"),
});

