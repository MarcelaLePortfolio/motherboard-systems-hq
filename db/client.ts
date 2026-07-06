
import Database from "better-sqlite3";

import { drizzle } from "drizzle-orm/better-sqlite3";

import * as schema from "./governance.schema.js";

const sqlite = new Database("db/main.db");

// RAW sqlite exposed for legacy routes

export { sqlite };

// DRIZZLE DB for new system

export const db = drizzle(sqlite, { schema });

