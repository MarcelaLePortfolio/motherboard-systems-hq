
import fs from "fs";

console.log("🔒 DB LAYER FREEZE INITIATED");

// restore canonical db client if missing

const client = `

import Database from "better-sqlite3";

const sqlite = new Database("db/main.db");

export default sqlite;

export { sqlite };

`;

fs.writeFileSync("db/client.ts", client);

console.log("DB client restored to canonical singleton");

