
import Database from "better-sqlite3";

const db = new Database("motherboard.sqlite");

export { db };

export default db;

