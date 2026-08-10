#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== REPAIR INVESTIGATION LIFECYCLE IEL MIGRATION PLACEMENT ==="

REQUIRED_ANCESTOR="589e7942"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain failed IEL persistence implementation checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/repair-investigation-lifecycle-iel-migration-placement\.sh$|^ M scripts/repair-investigation-lifecycle-iel-migration-placement\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
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
echo "=== VERIFY KNOWN FAILURE SHAPE ==="
grep -n -A35 -B10 \
  -E 'function optionalText|lifecycleColumns|investigation_lifecycle_json' \
  db/matilda-interpretation-runtime.ts | head -n 180

echo
echo "=== REPAIR MIGRATION PLACEMENT AND TEST ASSERTION ==="
python3 <<'PY'
from pathlib import Path

runtime_path = Path("db/matilda-interpretation-runtime.ts")
runtime = runtime_path.read_text()

bad_block = '''

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
'''

if bad_block not in runtime:
    raise SystemExit(
        "STOP: expected misplaced lifecycle migration block was not found."
    )

runtime = runtime.replace(bad_block, "", 1)

ensure_end_anchor = '''  sqlite.exec(`
    CREATE INDEX IF NOT EXISTS
      idx_matilda_iel_conversation_created
    ON matilda_interpretation_evidence_ledger (
      conversation_id,
      created_at
    );
  `);
}'''

if ensure_end_anchor not in runtime:
    raise SystemExit(
        "STOP: ensureInterpretationEvidenceLedgerTable closing anchor not found."
    )

correct_block = '''  sqlite.exec(`
    CREATE INDEX IF NOT EXISTS
      idx_matilda_iel_conversation_created
    ON matilda_interpretation_evidence_ledger (
      conversation_id,
      created_at
    );
  `);

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
}'''

runtime = runtime.replace(
    ensure_end_anchor,
    correct_block,
    1,
)

runtime_path.write_text(runtime)

test_path = Path(
    "scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts"
)
test = test_path.read_text()

old_assertion = '''    assert.doesNotMatch(
      source,
      /UPDATE matilda_interpretation_evidence_ledger[\\s\\S]*investigation_lifecycle_json/,
    );'''

new_assertion = '''    assert.doesNotMatch(
      source,
      /investigation_lifecycle_json\\s*=/,
    );'''

if old_assertion not in test:
    raise SystemExit(
        "STOP: expected over-broad historical-backfill assertion not found."
    )

test = test.replace(
    old_assertion,
    new_assertion,
    1,
)

test_path.write_text(test)
PY

echo
echo "=== VERIFY MIGRATION IS INSIDE TABLE INITIALIZATION ==="
grep -n -A45 -B20 \
  -E 'idx_matilda_iel_conversation_created|lifecycleColumns|function optionalText' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY OPTIONAL TEXT IS CLEAN ==="
optional_region="$(
  sed -n \
    '/function optionalText/,/export function createInterpretationEvidenceLedgerEntry/p' \
    db/matilda-interpretation-runtime.ts
)"

if printf '%s\n' "$optional_region" |
  grep -q 'lifecycleColumns'
then
  echo "STOP: lifecycle migration still exists inside optionalText."
  exit 2
fi

echo "LIFECYCLE_MIGRATION_OUTSIDE_OPTIONAL_TEXT_CONFIRMED"

echo
echo "=== VERIFY NO LIFECYCLE BACKFILL ASSIGNMENT ==="
if grep -nE \
  'investigation_lifecycle_json[[:space:]]*=' \
  db/matilda-interpretation-runtime.ts
then
  echo "STOP: lifecycle backfill assignment detected."
  exit 2
fi

echo "HISTORICAL_ROWS_REMAIN_NULL_NO_BACKFILL"

echo
echo "=== TARGETED PERSISTENCE CONTRACT TEST ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts

echo
echo "=== IEL / LINEAGE REGRESSION TESTS ==="
for test_file in \
  db/matilda-conversation-lineage.test.ts \
  server/matilda-interpretation-lifecycle-provider.test.ts \
  server/matilda-conversation-context-runtime.test.ts
do
  if [[ -f "$test_file" ]]; then
    echo "--- $test_file"
    npx tsx --test "$test_file"
  fi
done

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PROTECTED RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts
then
  echo "STOP: files outside IEL persistence scope changed."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts \
    db/matilda-conversation-runtime.ts
  exit 2
fi

echo "PROTECTED_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY AUTHORIZED REPAIR SURFACE ==="
changed="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE '^db/matilda-interpretation-runtime\.ts$|^scripts/validate-investigation-lifecycle-iel-bounded-json-persistence\.test\.ts$|^scripts/repair-investigation-lifecycle-iel-migration-placement\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside authorized repair surface changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "AUTHORIZED_REPAIR_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "INVESTIGATION_LIFECYCLE_IEL_MIGRATION_PLACEMENT_REPAIRED"
echo "TARGETED_PERSISTENCE_CONTRACT_VALIDATED"
echo "HISTORICAL_ROWS=NULL_NO_BACKFILL"
echo "WORKFLOW_CONSUMPTION_NOT_ADDED"
echo "CONTINUITY_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_IEL_PERSISTENCE_IMPLEMENTATION"

git add \
  db/matilda-interpretation-runtime.ts \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts \
  scripts/repair-investigation-lifecycle-iel-migration-placement.sh

git diff --cached --check
git commit -m "Repair Investigation Lifecycle IEL migration placement"
git push
