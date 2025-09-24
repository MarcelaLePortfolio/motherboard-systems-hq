import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';
import * as baseSchema from './schema';
import * as auditSchema from './audit';

// Initialize SQLite database
const sqlite = new Database('./db/dev.db');

// Wrap with Drizzle ORM (merge schemas to one object)
export const db = drizzle(sqlite, { schema: { ...baseSchema, ...auditSchema } });

export type DB = typeof db;
