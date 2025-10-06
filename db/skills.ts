import { sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const skills = sqliteTable('skills', {
  id: text('id').primaryKey().notNull(),
  name: text('name'),
  description: text('description'),
  code: text('code'),
  created_at: text('created_at'),
});
