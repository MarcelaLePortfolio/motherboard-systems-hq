#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
DR_BOUNDARY="20260918_153528"
CONVERSATION_ID="matilda-conversation-hq"
DRAFT_ID="matilda-draft-matilda-conversation-hq"
APPROVAL_ID="canonical_package_approval:matilda-draft-matilda-conversation-hq"

PRE_HEAD="$(git rev-parse HEAD)"

printf '\n=== INVESTIGATION BOUNDARY ===\n'
echo "MODE=READ_ONLY"
echo "DR_RECOVERY_BOUNDARY=$DR_BOUNDARY"
echo "CONVERSATION_ID=$CONVERSATION_ID"
echo "DRAFT_ID=$DRAFT_ID"
echo "APPROVAL_ID=$APPROVAL_ID"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "PRODUCT_CODE_MUTATION_AUTHORIZED=NO"
echo "APPROVAL_MUTATION_AUTHORIZED=NO"
echo "CANONICAL_MUTATION_AUTHORIZED=NO"
echo "GOVERNANCE_MUTATION_AUTHORIZED=NO"
echo "AUTHORITY_MUTATION_AUTHORIZED=NO"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"

printf '\n=== LOCATE DRAFT REVISION CONTRACT ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=.git \
  -E 'draft_revision_id|draftRevisionId|draft revision' \
  client server routes db 2>/dev/null | head -n 240 || true

printf '\n=== LOCATE CANONICAL APPROVAL HANDOFF ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=.git \
  -E 'canonical_package_approval|Canonical Package|canonical package|approval.*draft|draft.*approval' \
  client server routes db 2>/dev/null | head -n 260 || true

printf '\n=== INSPECT EXACT PERSISTED LINEAGE ===\n'
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

const conversationId = "matilda-conversation-hq";
const draftId = "matilda-draft-matilda-conversation-hq";

function tableExists(name) {
  return Boolean(
    db.prepare(`
      SELECT 1
      FROM sqlite_master
      WHERE type = 'table' AND name = ?
    `).get(name),
  );
}

function columns(name) {
  return db
    .prepare(`PRAGMA table_info("${name}")`)
    .all()
    .map((row) => row.name);
}

function printRows(label, table, where, params) {
  if (!tableExists(table)) {
    console.log(`${label}_TABLE_PRESENT=NO`);
    return [];
  }

  const rows = db
    .prepare(`SELECT * FROM "${table}" WHERE ${where}`)
    .all(...params);

  console.log(`${label}_TABLE_PRESENT=YES`);
  console.log(`${label}_ROW_COUNT=${rows.length}`);

  for (const row of rows) {
    console.log(`${label}_ROW=${JSON.stringify(row)}`);
  }

  return rows;
}

try {
  const tables = db.prepare(`
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
      AND (
        lower(name) LIKE '%draft%'
        OR lower(name) LIKE '%revision%'
        OR lower(name) LIKE '%approval%'
        OR lower(name) LIKE '%canonical%'
      )
    ORDER BY name
  `).all();

  console.log(
    `RELEVANT_TABLES=${JSON.stringify(tables.map(({ name }) => name))}`,
  );

  for (const { name } of tables) {
    console.log(
      `TABLE_SCHEMA=${name}:${JSON.stringify(columns(name))}`,
    );
  }

  const draftRows = printRows(
    "LIVING_DRAFT",
    "matilda_living_draft_packages",
    "draft_package_id = ? OR conversation_id = ?",
    [draftId, conversationId],
  );

  const revisionTable =
    tables.find(({ name }) =>
      /draft.*revision|revision.*draft/i.test(name),
    )?.name ?? null;

  let revisionRows = [];

  if (revisionTable) {
    const revisionColumns = columns(revisionTable);

    let clause = null;
    let params = [];

    if (revisionColumns.includes("draft_package_id")) {
      clause = "draft_package_id = ?";
      params = [draftId];
    } else if (revisionColumns.includes("conversation_id")) {
      clause = "conversation_id = ?";
      params = [conversationId];
    }

    if (clause) {
      revisionRows = printRows(
        "DRAFT_REVISION",
        revisionTable,
        clause,
        params,
      );
    } else {
      console.log(
        `DRAFT_REVISION_TABLE=${revisionTable}`,
      );
      console.log(
        "DRAFT_REVISION_QUERY=NO_KNOWN_LINEAGE_COLUMN",
      );
    }
  } else {
    console.log("DRAFT_REVISION_TABLE=NOT_FOUND");
  }

  const revisionIdColumns = [];

  for (const { name } of tables) {
    for (const column of columns(name)) {
      if (
        column === "draft_revision_id" ||
        column === "draftRevisionId" ||
        /revision.*id/i.test(column)
      ) {
        revisionIdColumns.push({
          table: name,
          column,
        });
      }
    }
  }

  console.log(
    `REVISION_ID_COLUMNS=${JSON.stringify(revisionIdColumns)}`,
  );

  const serialized = JSON.stringify({
    draftRows,
    revisionRows,
  });

  const revisionIds = [
    ...serialized.matchAll(
      /(?:draft_revision_id|draftRevisionId|revision_id)"?\s*[:=]\s*"?([^",}\s]+)/gi,
    ),
  ].map((match) => match[1]);

  console.log(
    `PERSISTED_REVISION_ID_CANDIDATES=${JSON.stringify([...new Set(revisionIds)])}`,
  );

  if (revisionRows.length > 0) {
    console.log("REQUEST_CHANGES_REVISION_PERSISTENCE=PROVEN");
  } else {
    console.log(
      "REQUEST_CHANGES_REVISION_PERSISTENCE=NOT_YET_PROVEN",
    );
  }
} finally {
  db.close();
}
NODE

printf '\n=== TRACE CLIENT APPROVE REQUEST ===\n'
for file in $(grep -RIl \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=.git \
  -E 'draft_revision_id|draftRevisionId|canonical_package_approval' \
  client/src 2>/dev/null || true); do
  echo "--- $file ---"
  grep -n -B 12 -A 24 \
    -E 'draft_revision_id|draftRevisionId|canonical_package_approval|fetch\(' \
    "$file" | head -n 220 || true
done

printf '\n=== TRACE SERVER VALIDATION ===\n'
for file in $(grep -RIl \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=.git \
  -E 'draft_revision_id is required|draft_revision_id|draftRevisionId' \
  server routes db 2>/dev/null || true); do
  echo "--- $file ---"
  grep -n -B 14 -A 28 \
    -E 'draft_revision_id is required|draft_revision_id|draftRevisionId' \
    "$file" | head -n 240 || true
done

printf '\n=== FAILURE-BOUNDARY CLASSIFICATION ===\n'
node <<'NODE'
const fs = require("fs");
const path = require("path");

const roots = ["client/src", "server", "routes", "db"];
const files = [];

function walk(dir) {
  if (!fs.existsSync(dir)) return;

  for (const entry of fs.readdirSync(dir, {
    withFileTypes: true,
  })) {
    if (
      entry.name === "node_modules" ||
      entry.name === "dist" ||
      entry.name === ".git"
    ) continue;

    const full = path.join(dir, entry.name);

    if (entry.isDirectory()) {
      walk(full);
    } else if (
      /\.(ts|tsx|js|mjs|cjs)$/.test(entry.name)
    ) {
      files.push(full);
    }
  }
}

for (const root of roots) walk(root);

const hits = [];

for (const file of files) {
  const text = fs.readFileSync(file, "utf8");

  if (
    text.includes("draft_revision_id") ||
    text.includes("draftRevisionId")
  ) {
    hits.push({
      file,
      hasSnake: text.includes("draft_revision_id"),
      hasCamel: text.includes("draftRevisionId"),
      requiresRevision:
        /draft_revision_id.{0,80}required/is.test(text) ||
        /required.{0,80}draft_revision_id/is.test(text),
      hasFetch: text.includes("fetch("),
    });
  }
}

console.log(`REVISION_CONTRACT_FILES=${JSON.stringify(hits)}`);

const clientHits = hits.filter(({ file }) =>
  file.startsWith("client/"),
);
const serverHits = hits.filter(({ file }) =>
  /^(server|routes|db)\//.test(file),
);

console.log(`CLIENT_REVISION_CONTRACT_FILE_COUNT=${clientHits.length}`);
console.log(`SERVER_REVISION_CONTRACT_FILE_COUNT=${serverHits.length}`);

if (
  serverHits.some((hit) => hit.requiresRevision) &&
  clientHits.length === 0
) {
  console.log(
    "LIKELY_FAILURE_BOUNDARY=CLIENT_APPROVAL_REQUEST_OMITS_REQUIRED_REVISION_ID",
  );
} else if (
  serverHits.some((hit) => hit.requiresRevision) &&
  clientHits.length > 0
) {
  console.log(
    "LIKELY_FAILURE_BOUNDARY=REVISION_ID_EXISTS_ACROSS_LAYERS_TRACE_EXACT_VALUE_HANDOFF",
  );
} else {
  console.log(
    "LIKELY_FAILURE_BOUNDARY=REQUIRES_EVIDENCE_FROM_OUTPUT_ABOVE",
  );
}
NODE

printf '\n=== VERIFY INVESTIGATION READ ONLY ===\n'
test "$(git rev-parse HEAD)" = "$PRE_HEAD"
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  db/main.db \
  client/src/approvals \
  server \
  routes \
  db

printf '\n=== STOPPING POINT ===\n'
echo "DRAFT_REVISION_ID_INVESTIGATION=COMPLETE"
echo "FIX_EXECUTED=NO"
echo "DATABASE_MUTATED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "APPROVAL_DECISION_EXECUTED=NO"
echo "CANONICAL_MUTATION=NO"
echo "GOVERNANCE_MUTATION=NO"
echo "AUTHORITY_CHANGE=NO"
echo "DR_RECOVERY_BOUNDARY=$DR_BOUNDARY"
echo "NEXT_ACTION=USE_OUTPUT_TO_IDENTIFY_EXACT_REVISION_ID_HANDOFF_FAILURE"
echo "CLEAR_STOPPING_POINT=YES"
