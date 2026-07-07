
import Database from "better-sqlite3";

const db = new Database("motherboard.sqlite");

export const sqlite = db;

export default db;

