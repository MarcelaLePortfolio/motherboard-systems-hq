import Database from "better-sqlite3";
import { drizzle } from "drizzle-orm/better-sqlite3";

const dbPath = "/Users/marcela-dev/Projects/Motherboard_Systems_HQ/motherboard.sqlite";
console.log("🧩 Using SQLite database at:", dbPath);

const sqlite = new Database(dbPath, { fileMustExist: true });
export const db = drizzle(sqlite);
