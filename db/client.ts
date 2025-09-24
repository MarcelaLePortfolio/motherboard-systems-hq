import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';
import * as schema from './schema';

// Initialize SQLite database
const sqlite = new Database('./db/dev.db');

// Wrap with Drizzle ORM
export const db = drizzle(sqlite, { schema });

export type DB = typeof db;
