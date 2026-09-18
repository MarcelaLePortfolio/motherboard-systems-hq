#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="34c7d9ea1"
DR_BOUNDARY="20260918_153528"

PRE_HEAD="$(git rev-parse HEAD)"

printf '\n=== BASELINE ===\n'
git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "MODE=READ_ONLY"
echo "DR_RECOVERY_BOUNDARY=$DR_BOUNDARY"
echo "KNOWN_FAILURE=draft_revision_id_is_required"
echo "PRODUCT_CODE_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"

printf '\n=== LOCATE CLIENT CANONICAL APPROVAL REQUEST ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  -E \
  '/api/matilda/canonical-package|matilda/canonical-package|canonical-package' \
  client/src 2>/dev/null || true

printf '\n=== LOCATE APPROVAL ACTION IMPLEMENTATION ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  -E \
  'draft_revision_id|draftRevisionId|draft_package_id|draftPackageId|Approve|approve|fetch\(' \
  client/src/approvals client/src 2>/dev/null | head -n 500 || true

printf '\n=== APPROVAL WORKSPACE ===\n'
if [ -f client/src/approvals/ApprovalsWorkspace.tsx ]; then
  nl -ba client/src/approvals/ApprovalsWorkspace.tsx | sed -n '1,560p'
fi

printf '\n=== SERVER CANONICAL ROUTE CONTRACT ===\n'
nl -ba server/routes/matilda-canonical-package-route.ts | sed -n '1,180p'

printf '\n=== LOCATE DRAFT REVISION CREATION / READ PATH ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=.git \
  -E \
  'createDraftRevisionForApprovalReview|draft_revision_id|draftRevisionId|matilda_draft_revisions' \
  server client/src db 2>/dev/null | head -n 600 || true

printf '\n=== CURRENT DRAFT / REVISION STATE ===\n'
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

try {
  const tableExists = (name) =>
    Boolean(
      db.prepare(`
        SELECT 1
        FROM sqlite_master
        WHERE type = 'table'
          AND name = ?
      `).get(name),
    );

  if (tableExists("matilda_living_draft_packages")) {
    const drafts = db.prepare(`
      SELECT
        draft_package_id,
        lineage_id,
        project_id,
        conversation_id,
        status,
        updated_at
      FROM matilda_living_draft_packages
      WHERE conversation_id = ?
         OR draft_package_id = ?
      ORDER BY updated_at DESC
    `).all(
      "matilda-conversation-hq",
      "matilda-draft-matilda-conversation-hq",
    );

    console.log(`CURRENT_LIVING_DRAFT_COUNT=${drafts.length}`);

    for (const row of drafts) {
      console.log(`CURRENT_LIVING_DRAFT=${JSON.stringify(row)}`);
    }
  }

  if (tableExists("matilda_draft_revisions")) {
    const revisions = db.prepare(`
      SELECT
        draft_revision_id,
        draft_package_id,
        lineage_id,
        project_id,
        conversation_id,
        source_draft_updated_at,
        status,
        created_at
      FROM matilda_draft_revisions
      WHERE conversation_id = ?
         OR draft_package_id = ?
      ORDER BY created_at DESC
    `).all(
      "matilda-conversation-hq",
      "matilda-draft-matilda-conversation-hq",
    );

    console.log(`CURRENT_DRAFT_REVISION_COUNT=${revisions.length}`);

    for (const row of revisions) {
      console.log(`CURRENT_DRAFT_REVISION=${JSON.stringify(row)}`);
    }

    console.log(
      `CURRENT_APPROVAL_REVISION_STATE=${revisions.length > 0 ? "PRESENT" : "MISSING"}`,
    );

    if (revisions.length > 0) {
      console.log(
        `LATEST_DRAFT_REVISION_ID=${revisions[0].draft_revision_id}`,
      );
    }
  } else {
    console.log("MATILDA_DRAFT_REVISIONS_TABLE_PRESENT=NO");
  }
} finally {
  db.close();
}
NODE

printf '\n=== CLASSIFY CLIENT HANDOFF ===\n'
node <<'NODE'
const fs = require("fs");
const path = require("path");

const files = [];

function walk(dir) {
  if (!fs.existsSync(dir)) return;

  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);

    if (entry.isDirectory()) {
      walk(full);
    } else if (/\.(ts|tsx|js|jsx)$/.test(entry.name)) {
      files.push(full);
    }
  }
}

walk("client/src");

const matches = [];

for (const file of files) {
  const text = fs.readFileSync(file, "utf8");

  if (
    text.includes("/api/matilda/canonical-package") ||
    text.includes("matilda/canonical-package")
  ) {
    matches.push({
      file,
      hasDraftRevisionSnake: text.includes("draft_revision_id"),
      hasDraftRevisionCamel: text.includes("draftRevisionId"),
      hasDraftPackageSnake: text.includes("draft_package_id"),
      hasDraftPackageCamel: text.includes("draftPackageId"),
    });
  }
}

console.log(
  `CLIENT_CANONICAL_REQUEST_FILES=${JSON.stringify(matches)}`,
);

if (matches.length === 0) {
  console.log(
    "HANDOFF_CLASS=REQUEST_ORIGIN_REQUIRES_FURTHER_TRACE",
  );
} else if (
  matches.every(
    (entry) =>
      !entry.hasDraftRevisionSnake &&
      !entry.hasDraftRevisionCamel,
  )
) {
  console.log(
    "HANDOFF_CLASS=CLIENT_REQUEST_CONFIRMED_OMITS_REQUIRED_REVISION_ID",
  );
} else {
  console.log(
    "HANDOFF_CLASS=REVISION_FIELD_EXISTS_TRACE_VALUE_PROVENANCE",
  );
}
NODE

printf '\n=== VERIFY READ ONLY ===\n'
test "$(git rev-parse HEAD)" = "$PRE_HEAD"
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  db/main.db \
  client/src/approvals \
  server/routes/matilda-canonical-package-route.ts \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-canonical-package-runtime.ts

printf '\n=== STOPPING POINT ===\n'
echo "APPROVAL_REVISION_HANDOFF_TRACE=COMPLETE"
echo "FIX_EXECUTED=NO"
echo "DATABASE_MUTATED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "APPROVAL_DECISION_EXECUTED=NO"
echo "CANONICAL_MUTATION=NO"
echo "GOVERNANCE_MUTATION=NO"
echo "AUTHORITY_CHANGE=NO"
echo "DR_RECOVERY_BOUNDARY=$DR_BOUNDARY"
echo "NEXT_ACTION=USE_TRACE_TO_DEFINE_ONE_EXACT_HANDOFF_FIX"
echo "CLEAR_STOPPING_POINT=YES"
