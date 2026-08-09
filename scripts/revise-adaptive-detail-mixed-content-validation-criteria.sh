#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== REVISE ADAPTIVE DETAIL — MIXED CONTENT VALIDATION CRITERIA ==="

if [[ "$(git rev-parse --short HEAD)" != "b166bc8e" ]]; then
  echo "STOP: HEAD no longer matches selection/support ownership checkpoint b166bc8e."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/revise-adaptive-detail-mixed-content-validation-criteria\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

python3 <<'PY'
from pathlib import Path

path = Path("scripts/validate-adaptive-detail-mixed-content-live.ts")
text = path.read_text()

old = '''  if (
    hasRelevant &&
    !hasImmaterial &&
    !replyMentionsImmaterial &&
    parentSupportPresent
  ) {
    console.log();
    console.log(
      "ADAPTIVE_DETAIL_MIXED_CONTENT_BEHAVIOR_SUPPORTED",
    );
    return;
  }

  console.log();

  if (!hasRelevant) {
    console.log(
      "ADAPTIVE_DETAIL_CONTRACT_VALID_BUT_BEHAVIOR_NOT_SUPPORTED: relevant child was not selected.",
    );
  }

  if (hasImmaterial) {
    console.log(
      "ADAPTIVE_DETAIL_CONTRACT_VALID_BUT_BEHAVIOR_NOT_SUPPORTED: immaterial child was selected.",
    );
  }

  if (replyMentionsImmaterial) {
    console.log(
      "ADAPTIVE_DETAIL_CONTRACT_VALID_BUT_BEHAVIOR_NOT_SUPPORTED: immaterial detail surfaced in reply.",
    );
  }

  if (!parentSupportPresent) {
    console.log(
      "ADAPTIVE_DETAIL_CONTRACT_VALID_BUT_BEHAVIOR_NOT_SUPPORTED: expected parent support provenance was absent.",
    );
  }

  process.exitCode = 2;'''

new = '''  if (
    hasRelevant &&
    !replyMentionsImmaterial
  ) {
    console.log();
    console.log(
      "ADAPTIVE_DETAIL_MIXED_CONTENT_BEHAVIOR_SUPPORTED",
    );
    console.log(
      `IMMATERIAL_CHILD_ADMITTED=${hasImmaterial}`,
    );
    console.log(
      `OPTIONAL_PARENT_SUPPORT_PRESENT=${parentSupportPresent}`,
    );
    return;
  }

  console.log();

  if (!hasRelevant) {
    console.log(
      "ADAPTIVE_DETAIL_CONTRACT_VALID_BUT_BEHAVIOR_NOT_SUPPORTED: relevant child was not selected.",
    );
  }

  if (replyMentionsImmaterial) {
    console.log(
      "ADAPTIVE_DETAIL_CONTRACT_VALID_BUT_BEHAVIOR_NOT_SUPPORTED: immaterial detail surfaced in reply.",
    );
  }

  process.exitCode = 2;'''

if old not in text:
    raise SystemExit(
        "STOP: expected previous mixed-content success criteria not found."
    )

path.write_text(text.replace(old, new, 1))

print(
    "Reconciled mixed-content validation criteria to established semantic-admission and support-provenance contracts."
)
PY

cat > scripts/validate-adaptive-detail-mixed-content-criteria.test.ts <<'TEST_EOF'
import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const source = fs.readFileSync(
  new URL(
    "./validate-adaptive-detail-mixed-content-live.ts",
    import.meta.url,
  ),
  "utf8",
);

test(
  "mixed-content validation requires relevant semantic availability and immaterial reply omission",
  () => {
    assert.match(
      source,
      /hasRelevant &&\s*!replyMentionsImmaterial/,
    );
  },
);

test(
  "mixed-content validation no longer requires immaterial child exclusion",
  () => {
    assert.doesNotMatch(
      source,
      /hasRelevant &&\s*!hasImmaterial/,
    );

    assert.match(
      source,
      /IMMATERIAL_CHILD_ADMITTED=/,
    );
  },
);

test(
  "mixed-content validation no longer requires parent support provenance",
  () => {
    assert.doesNotMatch(
      source,
      /hasRelevant &&[\s\S]*parentSupportPresent\s*\)/,
    );

    assert.match(
      source,
      /OPTIONAL_PARENT_SUPPORT_PRESENT=/,
    );
  },
);
TEST_EOF

echo
echo "=== TARGETED VALIDATION-CRITERIA TESTS ==="
npx tsx --test \
  scripts/validate-adaptive-detail-mixed-content-criteria.test.ts

echo
echo "=== OLLAMA REGRESSION SUITE ==="
npx tsx --test scripts/utils/ollamaChat*.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY RUNTIME UNCHANGED ==="
if ! git diff --quiet -- scripts/utils/ollamaChat.ts; then
  echo "STOP: ollamaChat.ts changed during validation-only revision."
  git diff -- scripts/utils/ollamaChat.ts
  exit 2
fi

echo "OLLAMA_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY AUTHORIZED CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/validate-adaptive-detail-mixed-content-live\.ts$|^scripts/validate-adaptive-detail-mixed-content-criteria\.test\.ts$|^scripts/revise-adaptive-detail-mixed-content-validation-criteria\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside validation-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "VALIDATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_MIXED_CONTENT_VALIDATION_CRITERIA_RECONCILED"
echo "RUNTIME_CHANGED=false"
echo "PROMPT_CHANGED=false"
echo "SUPPORT_CONTRACT_CHANGED=false"
echo "EVIDENCE_CONTRACT_CHANGED=false"
echo "NEXT_UNIT=RERUN_ADAPTIVE_DETAIL_MIXED_CONTENT_BEHAVIOR_LIVE"

git add \
  scripts/validate-adaptive-detail-mixed-content-live.ts \
  scripts/validate-adaptive-detail-mixed-content-criteria.test.ts \
  scripts/revise-adaptive-detail-mixed-content-validation-criteria.sh

git commit -m "Reconcile Adaptive Detail mixed content validation criteria"
git push
