#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db");

db.pragma("foreign_keys = OFF");

const tx = db.transaction(() => {
  db.exec(`
    ALTER TABLE governance_delegations
    RENAME TO governance_delegations_legacy_root;
  `);

  db.exec(`
    CREATE TABLE governance_delegations (
      delegation_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      authorization_state TEXT NOT NULL,
      authorization_timestamp TEXT NOT NULL,
      delegated_by TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES matilda_canonical_packages(package_id, package_version)
    );
  `);

  db.exec(`
    INSERT INTO governance_delegations (
      delegation_id,
      package_id,
      package_version,
      authorization_state,
      authorization_timestamp,
      delegated_by,
      created_at
    )
    SELECT
      delegation_id,
      package_id,
      package_version,
      authorization_state,
      authorization_timestamp,
      delegated_by,
      created_at
    FROM governance_delegations_legacy_root;
  `);

  db.exec(`
    DROP TABLE governance_delegations_legacy_root;
  `);
});

tx();

db.pragma("foreign_keys = ON");

console.log("=== NEW DELEGATION FOREIGN KEY ===");
console.log(db.prepare("PRAGMA foreign_key_list(governance_delegations)").all());

console.log("\n=== PRESERVED HISTORICAL ROW ===");
console.log(
  db.prepare(`
    SELECT *
    FROM governance_delegations
    WHERE delegation_id = 'corridor-delegation'
  `).get()
);

db.close();
NODE

./scripts/validate-canonical-delegation-root.sh

git add scripts/migrate-delegation-root-to-canonical.sh
git commit -m "Reanchor Delegation persistence to canonical Packages"
git push
