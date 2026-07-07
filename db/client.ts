import Database from "better-sqlite3";

export const sqlite = new Database("db/main.db");

export default sqlite;

