#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== EXECUTE INVESTIGATION LIFECYCLE IEL BOUNDED JSON PERSISTENCE ==="

REQUIRED_ANCESTOR="1d1f04ce"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: required implementation-unit checkpoint is not an ancestor of HEAD."
  exit 2
}

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/execute-investigation-lifecycle-iel-bounded-json-persistence\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected pre-existing working-tree changes:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY CLASSIFIED CONTRACT ==="
grep -nE \
  'IEL_REPRESENTATION=IEL_BOUNDED_LIFECYCLE_JSON|SCHEMA_EXTENSION=investigation_lifecycle_json_TEXT_NULL|HISTORICAL_ROWS=NULL_NO_BACKFILL' \
  scripts/classify-investigation-lifecycle-iel-representation.sh

echo
echo "=== VERIFY IEL RUNTIME ANCHORS ==="
grep -nE \
  'supersession_status|CREATE TABLE IF NOT EXISTS matilda_interpretation_evidence_ledger|INSERT INTO matilda_interpretation_evidence_ledger' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== PATCH IEL RUNTIME ==="
python3 <<'PY'
from pathlib import Path

path = Path("db/matilda-interpretation-runtime.ts")
text = path.read_text()

# Input contract.
anchor = "  supersession_status?: string | null;"
addition = """  supersession_status?: string | null;
  investigation_lifecycle_json?: string | null;"""

if "investigation_lifecycle_json?: string | null;" not in text:
    if anchor not in text:
        raise SystemExit("STOP: IEL input contract anchor not found.")
    text = text.replace(anchor, addition, 1)

# CREATE TABLE.
anchor = "      supersession_status TEXT NOT NULL DEFAULT 'current'"
addition = """      investigation_lifecycle_json TEXT,
      supersession_status TEXT NOT NULL DEFAULT 'current'"""

if "investigation_lifecycle_json TEXT" not in text:
    if anchor not in text:
        raise SystemExit("STOP: IEL schema anchor not found.")
    text = text.replace(anchor, addition, 1)

# Additive migration. Locate the end of schema initialization before the
# canonical create-entry function rather than assuming a specific old column.
if 'column.name === "investigation_lifecycle_json"' not in text:
    create_fn = text.find("export function createInterpretationEvidenceLedgerEntry")
    if create_fn == -1:
        raise SystemExit("STOP: createInterpretationEvidenceLedgerEntry not found.")

    prefix = text[:create_fn]
    last_closing = prefix.rfind("}\n")
    if last_closing == -1:
        raise SystemExit("STOP: IEL initialization boundary not found.")

    migration = """
  const lifecycleColumns = sqlite
    .prepare(
      "PRAGMA table_info(matilda_interpretation_evidence_ledger)",
    )
    .all() as Array<{ name: string }>;

  if (
    !lifecycleColumns.some(
      (column) => column.name === "investigation_lifecycle_json",
    )
  ) {
    sqlite.exec(`
      ALTER TABLE matilda_interpretation_evidence_ledger
      ADD COLUMN investigation_lifecycle_json TEXT;
    `);
  }
"""

    text = (
        text[:last_closing]
        + migration
        + text[last_closing:]
    )

# INSERT column.
insert_pos = text.find(
    "INSERT INTO matilda_interpretation_evidence_ledger"
)
if insert_pos == -1:
    raise SystemExit("STOP: canonical IEL INSERT not found.")

insert_end = text.find("VALUES", insert_pos)
if insert_end == -1:
    raise SystemExit("STOP: IEL VALUES boundary not found.")

insert_columns = text[insert_pos:insert_end]

if "investigation_lifecycle_json" not in insert_columns:
    anchor = "      supersession_status"
    pos = text.find(anchor, insert_pos, insert_end)
    if pos == -1:
        raise SystemExit("STOP: IEL INSERT supersession column anchor not found.")

    text = (
        text[:pos]
        + "      investigation_lifecycle_json,\n"
        + text[pos:]
    )

# VALUES placeholder.
insert_pos = text.find(
    "INSERT INTO matilda_interpretation_evidence_ledger"
)
values_pos = text.find("VALUES", insert_pos)
statement_end = text.find("`", values_pos)

if values_pos == -1 or statement_end == -1:
    raise SystemExit("STOP: IEL INSERT VALUES statement not found.")

values_region = text[values_pos:statement_end]

if "@investigation_lifecycle_json" not in values_region:
    anchor = "      @supersession_status"
    pos = text.find(anchor, values_pos, statement_end)
    if pos == -1:
        raise SystemExit("STOP: IEL VALUES supersession anchor not found.")

    text = (
        text[:pos]
        + "      @investigation_lifecycle_json,\n"
        + text[pos:]
    )

# Prepared statement payload.
insert_pos = text.find(
    "INSERT INTO matilda_interpretation_evidence_ledger"
)
payload_pos = text.find("supersession_status:", insert_pos)

if payload_pos == -1:
    raise SystemExit("STOP: IEL statement payload anchor not found.")

payload_region = text[insert_pos:payload_pos + 1000]

if "investigation_lifecycle_json:" not in payload_region:
    line_start = text.rfind("\n", insert_pos, payload_pos) + 1
    text = (
        text[:line_start]
        + "    investigation_lifecycle_json:\n"
        + "      input.investigation_lifecycle_json ?? null,\n"
        + text[line_start:]
    )

path.write_text(text)
PY

echo
echo "=== CREATE BOUNDED JSON CONTRACT TEST ==="
cat > scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts <<'EOF_TS'
import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";

const source = fs.readFileSync(
  "db/matilda-interpretation-runtime.ts",
  "utf8",
);

test(
  "IEL schema carries additive nullable Investigation Lifecycle JSON",
  () => {
    assert.match(
      source,
      /investigation_lifecycle_json TEXT/,
    );
  },
);

test(
  "IEL input accepts nullable bounded lifecycle JSON",
  () => {
    assert.match(
      source,
      /investigation_lifecycle_json\?: string \| null;/,
    );
  },
);

test(
  "IEL migration adds lifecycle JSON without backfill",
  () => {
    assert.match(
      source,
      /column\.name === "investigation_lifecycle_json"/,
    );

    assert.match(
      source,
      /ALTER TABLE matilda_interpretation_evidence_ledger[\s\S]*ADD COLUMN investigation_lifecycle_json TEXT/,
    );

    assert.doesNotMatch(
      source,
      /UPDATE matilda_interpretation_evidence_ledger[\s\S]*investigation_lifecycle_json/,
    );
  },
);

test(
  "IEL INSERT persists nullable lifecycle JSON",
  () => {
    assert.match(
      source,
      /INSERT INTO matilda_interpretation_evidence_ledger[\s\S]*investigation_lifecycle_json[\s\S]*@investigation_lifecycle_json/,
    );

    assert.match(
      source,
      /investigation_lifecycle_json:\s*[\r\n ]*input\.investigation_lifecycle_json \?\? null/,
    );
  },
);

test(
  "lifecycle persistence remains owned by IEL runtime",
  () => {
    const workflow = fs.readFileSync(
      "server/matilda-chat-workflow.ts",
      "utf8",
    );

    assert.doesNotMatch(
      workflow,
      /investigation_lifecycle_json/,
    );
  },
);
EOF_TS

echo
echo "=== TARGETED CONTRACT TEST ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts

echo
echo "=== EXISTING IEL TEST DISCOVERY ==="
existing_tests="$(
  find db server scripts -type f \
    \( -name '*interpretation*runtime*.test.ts' -o \
       -name '*interpretation*ledger*.test.ts' -o \
       -name '*interpretation*lifecycle*.test.ts' \) \
    ! -name 'validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts' \
    -print |
  sort
)"

if [[ -n "$existing_tests" ]]; then
  while IFS= read -r test_file; do
    [[ -z "$test_file" ]] && continue
    echo "--- $test_file"
    npx tsx --test "$test_file"
  done <<< "$existing_tests"
else
  echo "NO_EXISTING_IEL_REGRESSION_TESTS_DISCOVERED"
fi

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY GENERATION AND WORKFLOW RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: generation or workflow runtime changed."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts
  exit 2
fi

echo "GENERATION_AND_WORKFLOW_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY NO HISTORICAL BACKFILL ==="
if git diff -- db/matilda-interpretation-runtime.ts |
  grep -E '^\+.*UPDATE .*matilda_interpretation_evidence_ledger' |
  grep -q 'investigation_lifecycle_json'
then
  echo "STOP: lifecycle backfill was introduced."
  exit 2
fi

echo "HISTORICAL_ROWS_REMAIN_NULL_NO_BACKFILL"

echo
echo "=== VERIFY CHANGE SURFACE ==="
changed="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE '^db/matilda-interpretation-runtime\.ts$|^scripts/validate-investigation-lifecycle-iel-bounded-json-persistence\.test\.ts$|^scripts/execute-investigation-lifecycle-iel-bounded-json-persistence\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside authorized persistence implementation surface changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "AUTHORIZED_PERSISTENCE_IMPLEMENTATION_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "INVESTIGATION_LIFECYCLE_IEL_BOUNDED_JSON_PERSISTENCE_IMPLEMENTED"
echo "PERSISTENCE_OWNER=IEL"
echo "IEL_REPRESENTATION=IEL_BOUNDED_LIFECYCLE_JSON"
echo "SCHEMA_EXTENSION=investigation_lifecycle_json_TEXT_NULL"
echo "HISTORICAL_ROWS=NULL_NO_BACKFILL"
echo "WORKFLOW_CONSUMPTION_NOT_ADDED"
echo "CONTINUITY_VALIDATION=DEFERRED"
echo "GENERATION_POLICY_UNCHANGED"
echo "ONE_OLLAMA_INVOCATION_PRESERVED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_IEL_PERSISTENCE_IMPLEMENTATION"

git add \
  db/matilda-interpretation-runtime.ts \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts \
  scripts/execute-investigation-lifecycle-iel-bounded-json-persistence.sh

git diff --cached --check
git commit -m "Implement Investigation Lifecycle IEL persistence"
git push
