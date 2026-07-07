
import fs from "fs";

console.log("ESTABLISHING CANONICAL BOUNDARY");

// 1. Canonical DB client ONLY (no duplication allowed)

fs.writeFileSync(

  "db/client.ts",

  `import Database from "better-sqlite3";

export const sqlite = new Database("db/main.db");

export default sqlite;

`

);

// 2. Document contract ownership (prevents future drift)

fs.writeFileSync(

  "db/BOUNDARY_LOCK.json",

  JSON.stringify({

    db: "db/client.ts",

    lifecycle: "db/governance-lifecycle-composition.ts",

    rule: "ONLY these modules define system truth boundaries"

  }, null, 2)

);

console.log("Canonical boundary established");

