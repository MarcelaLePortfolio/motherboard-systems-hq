#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== RECONCILE IEL PERSISTENCE TEST FOR TYPED LIFECYCLE ADAPTER ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

test "$(git rev-parse --short HEAD)" = "88c4c8cd" || {
  echo "STOP: expected implementation attempt to remain uncommitted on 88c4c8cd."
  exit 2
}

echo
echo "=== VERIFY EXPECTED FAILED IMPLEMENTATION SURFACE ==="
for path in \
  db/matilda-interpretation-runtime.ts \
  server/matilda-chat-workflow.ts \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts \
  scripts/implement-investigation-lifecycle-typed-iel-adapter-and-workflow-transport.sh
do
  test -e "$path" || {
    echo "STOP: expected implementation artifact missing: $path"
    exit 2
  }
done

unexpected="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE '^db/matilda-interpretation-runtime\.ts$|^server/matilda-chat-workflow\.ts$|^scripts/validate-investigation-lifecycle-typed-iel-workflow-transport\.test\.ts$|^scripts/implement-investigation-lifecycle-typed-iel-adapter-and-workflow-transport\.sh$|^scripts/reconcile-investigation-lifecycle-iel-persistence-test-for-typed-adapter\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "EXPECTED_FAILED_IMPLEMENTATION_SURFACE_CONFIRMED"

echo
echo "=== VERIFY FAILURE IS STALE TEST EXPECTATION ==="
grep -nF 'investigation_lifecycle_json\?: string \| null;' \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts || true

grep -nF 'input\.investigation_lifecycle_json ?? null' \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts || true

grep -q 'investigation_lifecycle_json' \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts || {
    echo "STOP: expected legacy persistence-test assertions were not found."
    exit 2
  }

echo "STALE_PERSISTENCE_TEST_EXPECTATION_CONFIRMED"

echo
echo "=== REPLACE PERSISTENCE CONTRACT TEST WITH CURRENT OWNERSHIP CONTRACT ==="
cat > scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts <<'EOF_TS'
import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

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
  "IEL input accepts nullable bounded typed lifecycle artifact",
  () => {
    assert.match(
      source,
      /investigation_lifecycle\?:\s*MatildaInvestigationLifecycleArtifact \| null;/,
    );

    assert.doesNotMatch(
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
      /ALTER TABLE matilda_interpretation_evidence_ledger[\s\S]*ADD COLUMN investigation_lifecycle_json TEXT;/,
    );

    assert.doesNotMatch(
      source,
      /UPDATE matilda_interpretation_evidence_ledger[\s\S]*investigation_lifecycle_json\s*=/,
    );
  },
);

test(
  "IEL deterministically serializes nullable lifecycle artifact",
  () => {
    assert.match(
      source,
      /investigation_lifecycle_json:\s*[\s\S]*input\.investigation_lifecycle === null[\s\S]*input\.investigation_lifecycle === undefined[\s\S]*\? null[\s\S]*JSON\.stringify\([\s\S]*input\.investigation_lifecycle/,
    );
  },
);

test(
  "lifecycle persistence remains owned by IEL runtime",
  () => {
    assert.match(
      source,
      /@investigation_lifecycle_json/,
    );

    assert.match(
      source,
      /JSON\.stringify\([\s\S]*input\.investigation_lifecycle/,
    );
  },
);
EOF_TS

echo
echo "=== RUN RECONCILED IEL PERSISTENCE CONTRACT ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts

echo
echo "=== RUN TYPED TRANSPORT CONTRACT ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

echo
echo "=== VERIFY TEST-ONLY RECONCILIATION DID NOT ALTER PRODUCTION AGAIN ==="
changed="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE '^db/matilda-interpretation-runtime\.ts$|^server/matilda-chat-workflow\.ts$|^scripts/validate-investigation-lifecycle-iel-bounded-json-persistence\.test\.ts$|^scripts/validate-investigation-lifecycle-typed-iel-workflow-transport\.test\.ts$|^scripts/implement-investigation-lifecycle-typed-iel-adapter-and-workflow-transport\.sh$|^scripts/reconcile-investigation-lifecycle-iel-persistence-test-for-typed-adapter\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside authorized implementation and test-reconciliation surface changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "AUTHORIZED_RECONCILIATION_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "STALE_IEL_PERSISTENCE_TEST_RECONCILED"
echo "PRODUCTION_IMPLEMENTATION_UNCHANGED_SINCE_FAILED_VALIDATION"
echo "NEXT_ACTION=RERUN_TYPED_IEL_ADAPTER_IMPLEMENTATION_VALIDATION"

git add \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts \
  scripts/reconcile-investigation-lifecycle-iel-persistence-test-for-typed-adapter.sh

git diff --cached --check
git commit -m "Reconcile Investigation Lifecycle IEL persistence contract test"
git push
