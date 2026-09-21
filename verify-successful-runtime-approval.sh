#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="f94913479"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== HUMAN RUNTIME OBSERVATION ===\n'
echo "APPROVE_CLICKED_BY_HUMAN=YES"
echo "PENDING_APPROVAL_DISAPPEARED=YES"
echo "DRAFT_REVISION_ID_ERROR_RECURRED=NO_OBSERVED_ERROR"
echo "CORRIDOR_CLOSURE=NOT_YET_DECLARED"

printf '\n=== VERIFY APPROVAL REQUEST RESOLVED ===\n'
curl -fsS \
  'http://localhost:3000/api/approval-requests?project_id=hq' \
  > /tmp/post-approval-requests.json

cat /tmp/post-approval-requests.json
printf '\n'

node <<'NODE'
const fs = require("fs");

const body = JSON.parse(
  fs.readFileSync("/tmp/post-approval-requests.json", "utf8"),
);

const requests = Array.isArray(body.requests)
  ? body.requests
  : [];

console.log(`PENDING_APPROVAL_REQUEST_COUNT=${requests.length}`);

if (requests.length !== 0) {
  throw new Error(
    `Expected zero pending Approval Requests; received ${requests.length}`,
  );
}
NODE

printf '\n=== VERIFY CANONICAL PACKAGE AND EXACT REVISION ===\n'
node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });

try {
  const revision = db.prepare(`
    SELECT *
    FROM matilda_draft_revisions
    WHERE draft_revision_id =
      'draft-revision-7d868f8c-1661-4547-8a8e-5eaf5c286736'
  `).get();

  if (!revision) {
    throw new Error("Reviewed Draft Revision was not found");
  }

  console.log(`REVIEWED_REVISION=${JSON.stringify(revision)}`);

  const canonicals = db.prepare(`
    SELECT *
    FROM matilda_canonical_packages
    WHERE draft_package_id =
      'matilda-draft-matilda-conversation-hq'
    ORDER BY rowid DESC
  `).all();

  console.log(`MATCHING_CANONICAL_PACKAGE_COUNT=${canonicals.length}`);

  for (const row of canonicals) {
    console.log(`CANONICAL=${JSON.stringify(row)}`);
  }

  if (canonicals.length < 1) {
    throw new Error(
      "Pending request resolved but matching Canonical Package was not found",
    );
  }

  const exactRevision = canonicals.find(
    row =>
      row.draft_revision_id ===
      'draft-revision-7d868f8c-1661-4547-8a8e-5eaf5c286736'
  );

  if (!exactRevision) {
    throw new Error(
      "Canonical Package does not reference the exact reviewed Draft Revision",
    );
  }

  console.log("EXACT_REVIEWED_REVISION_CANONICALIZED=YES");
} finally {
  db.close();
}
NODE

printf '\n=== VERIFY AUTHORITY BOUNDARY ===\n'
node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });

try {
  const tables = db.prepare(`
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
      AND (
        lower(name) LIKE '%delegat%'
        OR lower(name) LIKE '%execution%approval%'
        OR lower(name) LIKE '%execution%author%'
      )
    ORDER BY name
  `).pluck().all();

  console.log(`AUTHORITY_RELEVANT_TABLE_COUNT=${tables.length}`);

  for (const table of tables) {
    const quoted =
      '"' + String(table).replace(/"/g, '""') + '"';

    const result = db.prepare(
      `SELECT COUNT(*) AS count FROM ${quoted}`
    ).get();

    console.log(`${table}_ROW_COUNT=${result.count}`);
  }
} finally {
  db.close();
}
NODE

printf '\n=== VERIFY REPOSITORY UNCHANGED ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== STOPPING POINT ===\n'
echo "POST_APPROVAL_RUNTIME_VERIFICATION_COMPLETE=YES"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED_BY_VERIFICATION=NO"
echo "APPROVAL_RETRIED=NO"
echo "NEXT_ACTION=CLASSIFY_RESULTS_AND_CLOSE_APPROVAL_DEFECT_CORRIDOR_IF_ALL_INVARIANTS_PASS"
echo "CLEAR_STOPPING_POINT=YES"
