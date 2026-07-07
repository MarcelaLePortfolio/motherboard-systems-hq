
import Database from "better-sqlite3";

export const db = new Database("motherboard.sqlite");

// legacy compatibility layer (temporary)

export const sqlite = db;

export default db;

