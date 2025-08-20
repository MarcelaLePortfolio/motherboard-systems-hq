import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';

export const chunks = sqliteTable('chunks', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  namespace: text('namespace').notNull(),
  content: text('content').notNull(),
  embedding: text('embedding').notNull(),
  created_at: text('created_at').default(new Date().toISOString()),
});
