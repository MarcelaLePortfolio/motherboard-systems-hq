import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import Database from "better-sqlite3";

const source = "db/main.db";
const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "project-scoped-delegation-"));
const target = path.join(tempDir, "main.db");
fs.copyFileSync(source, target);

const db = new Database(target);

try {
  db.pragma("foreign_keys = OFF");
  db.exec(fs.readFileSync("drizzle/0010_project_scoped_delegation_reference.sql", "utf8"));
  db.pragma("foreign_keys = ON");

  const cols = db.prepare("PRAGMA table_info(governance_delegations)").all();
  if (!cols.some((row) => row.name === "project_id")) {
    throw new Error("governance_delegations.project_id missing after migration");
  }

  const fks = db.prepare("PRAGMA foreign_key_list(governance_delegations)").all();
  const composite = fks.filter((row) => row.table === "matilda_canonical_packages");
  const mapping = new Set(composite.map((row) => `${row.from}->${row.to}`));

  for (const required of [
    "project_id->project_id",
    "package_id->package_id",
    "package_version->package_version",
  ]) {
    if (!mapping.has(required)) {
      throw new Error(`Missing composite FK component: ${required}`);
    }
  }

  const canonical = db.prepare(`
    SELECT project_id, package_id, package_version
    FROM matilda_canonical_packages
    WHERE project_id IS NOT NULL
      AND TRIM(project_id) <> ''
      AND status = 'canonical_approved'
    LIMIT 1
  `).get();

  if (!canonical) {
    throw new Error("No project-bound canonical approved Package available.");
  }

  db.prepare(`
    INSERT INTO governance_delegations (
      delegation_id,
      project_id,
      package_id,
      package_version,
      authorization_state,
      authorization_timestamp,
      delegated_by,
      created_at
    ) VALUES (?, ?, ?, ?, 'AUTHORIZED', ?, 'validation-probe', ?)
  `).run(
    "project-scoped-delegation-valid-probe",
    canonical.project_id,
    canonical.package_id,
    canonical.package_version,
    new Date().toISOString(),
    new Date().toISOString(),
  );

  let mismatchRejected = false;
  try {
    db.prepare(`
      INSERT INTO governance_delegations (
        delegation_id,
        project_id,
        package_id,
        package_version,
        authorization_state,
        authorization_timestamp,
        delegated_by,
        created_at
      ) VALUES (?, ?, ?, ?, 'AUTHORIZED', ?, 'validation-probe', ?)
    `).run(
      "project-scoped-delegation-mismatch-probe",
      "__wrong_project__",
      canonical.package_id,
      canonical.package_version,
      new Date().toISOString(),
      new Date().toISOString(),
    );
  } catch {
    mismatchRejected = true;
  }

  if (!mismatchRejected) {
    throw new Error("Cross-project canonical Package reference was accepted.");
  }

  const targeted = db.prepare(`
    SELECT *
    FROM pragma_foreign_key_check
    WHERE "table" = 'governance_delegations'
  `).all();

  console.log("PROJECT_SCOPED_DELEGATION_SCHEMA=PASS");
  console.log("VALID_PROJECT_PACKAGE_REFERENCE=PASS");
  console.log("CROSS_PROJECT_PACKAGE_REFERENCE=REJECTED");
  console.log(
    "TARGETED_DELEGATION_FOREIGN_KEY_CHECK=" +
      (targeted.length === 0 ? "PASS" : "FAIL"),
  );

  if (targeted.length !== 0) {
    console.log(JSON.stringify(targeted, null, 2));
    process.exitCode = 1;
  }
} finally {
  db.close();
  fs.rmSync(tempDir, { recursive: true, force: true });
}
