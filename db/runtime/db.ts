
import Database from "better-sqlite3";

const sqliteInstance = new Database("motherboard.sqlite");

// single source of truth

export const db = sqliteInstance;

// compatibility alias (safe, no circular reference)

export const sqlite = sqliteInstance;

export default db;

