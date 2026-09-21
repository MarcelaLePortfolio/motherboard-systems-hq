#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="786241f68"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== CONCLUSION ===\n'
echo "ATLAS_CAPTURED_MATILDA_COLLABORATION_HISTORY=YES"
echo "ATLAS_CAPTURED_FAILED_APPROVAL_CLICK=NO_EVIDENCE"
echo "APPROVAL_DEFECT_CORRIDOR_STATUS=OPEN"

printf '\n=== INSPECT LIVE APPROVAL DATA ===\n'
node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });

try {
  const tables = [
    "matilda_living_draft_packages",
    "matilda_draft_revisions",
    "matilda_canonical_packages",
  ];

  for (const name of tables) {
    const exists = db.prepare(`
      SELECT 1 FROM sqlite_master
      WHERE type='table' AND name=?
    `).get(name);

    if (!exists) {
      console.log(`${name}=TABLE_ABSENT`);
      continue;
    }

    const quoted = `"${name.replace(/"/g, '""')}"`;
    const columns = db.prepare(`PRAGMA table_info(${quoted})`).all();

    console.log(`\nTABLE=${name}`);
    console.log(`COLUMNS=${columns.map(c => c.name).join(",")}`);

    const rows = db.prepare(`
      SELECT *
      FROM ${quoted}
      ORDER BY rowid DESC
      LIMIT 10
    `).all();

    console.log(`ROW_COUNT_SHOWN=${rows.length}`);

    for (const row of rows) {
      console.log(JSON.stringify(row));
    }
  }
} finally {
  db.close();
}
NODE

printf '\n=== INSPECT SERVER APPROVAL ASSEMBLY ===\n'
grep -n -B 15 -A 30 \
  -E 'createDraftRevisionForApprovalReview|draft_revision_id' \
  db/approval-request-model-assembler.ts

printf '\n=== INSPECT APPROVAL API ROUTE ===\n'
grep -Rni \
  -E 'assembleApprovalRequestRead(Collection|Model)|approval-request|draft_revision_id' \
  routes server \
  | head -n 180 || true

printf '\n=== INSPECT CLIENT FETCH AND NORMALIZATION ===\n'
grep -n -B 15 -A 40 \
  -E 'ApprovalRequestReadModel|approval-request|draft_revision_id|fetch' \
  client/src/approvals/approvalRequestApi.ts

printf '\n=== VERIFY READ ONLY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== STOPPING POINT ===\n'
echo "LIVE_APPROVAL_REQUEST_PATH_INSPECTED=YES"
echo "APPROVAL_RETRIED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=CLASSIFY_EXACT_POINT_WHERE_DRAFT_REVISION_ID_IS_LOST"
echo "CLEAR_STOPPING_POINT=YES"
