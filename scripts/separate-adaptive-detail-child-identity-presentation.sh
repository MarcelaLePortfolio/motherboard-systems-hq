#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== SEPARATE ADAPTIVE DETAIL — CHILD IDENTITY PRESENTATION ==="

if [[ "$(git rev-parse --short HEAD)" != "fc8483cb" ]]; then
  echo "STOP: HEAD no longer matches presentation-collision determination checkpoint fc8483cb."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/separate-adaptive-detail-child-identity-presentation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

python3 <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

old = '''                `Segment source: ${item.relativePath}:${item.sourceStartLine}-${item.sourceEndLine}`,
                "Authority status: candidate_evidence_not_authority",
                item.text,'''

new = '''                "Segment candidate:",
                `relativePath = ${item.relativePath}`,
                `sourceStartLine = ${item.sourceStartLine}`,
                `sourceEndLine = ${item.sourceEndLine}`,
                "Authority status: candidate_evidence_not_authority",
                item.text,'''

if old not in text:
    raise SystemExit(
        "STOP: expected child candidate serialization seam not found."
    )

path.write_text(text.replace(old, new, 1))

print("Separated child semantic identity presentation from parent Source notation.")
PY

cat > scripts/utils/ollamaChat.child-identity-presentation.test.ts <<'TEST_EOF'
import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const source = fs.readFileSync(
  new URL("./ollamaChat.ts", import.meta.url),
  "utf8",
);

test(
  "child candidate identity uses explicit named fields instead of source-style notation",
  () => {
    assert.match(
      source,
      /"Segment candidate:"/,
    );

    assert.match(
      source,
      /`relativePath = \$\{item\.relativePath\}`/,
    );

    assert.match(
      source,
      /`sourceStartLine = \$\{item\.sourceStartLine\}`/,
    );

    assert.match(
      source,
      /`sourceEndLine = \$\{item\.sourceEndLine\}`/,
    );

    assert.doesNotMatch(
      source,
      /`Segment source: \$\{item\.relativePath\}:\$\{item\.sourceStartLine\}-\$\{item\.sourceEndLine\}`/,
    );
  },
);

test(
  "parent support Source presentation remains unchanged",
  () => {
    assert.match(
      source,
      /`Source: \$\{item\.relativePath\}:\$\{item\.lineNumber\}`/,
    );
  },
);

test(
  "selectedContextSegments structured identity contract remains unchanged",
  () => {
    assert.match(
      source,
      /relativePath/,
    );

    assert.match(
      source,
      /sourceStartLine/,
    );

    assert.match(
      source,
      /sourceEndLine/,
    );
  },
);
TEST_EOF

echo
echo "=== TARGETED CHILD IDENTITY PRESENTATION TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.child-identity-presentation.test.ts

echo
echo "=== FULL OLLAMA REGRESSION SUITE ==="
npx tsx --test scripts/utils/ollamaChat*.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY AUTHORIZED CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/utils/ollamaChat\.ts$|^scripts/utils/ollamaChat\.child-identity-presentation\.test\.ts$|^scripts/separate-adaptive-detail-child-identity-presentation\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: implementation modified files outside authorized surface:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "AUTHORIZED_CHANGE_SURFACE_ONLY"

echo
echo "=== VERIFY PRESENTATION CONTRACT ==="
if grep -n \
  'Segment source:' \
  scripts/utils/ollamaChat.ts
then
  echo "STOP: colon-style child Segment source presentation remains."
  exit 2
fi

grep -n \
  -E 'Segment candidate:|relativePath =|sourceStartLine =|sourceEndLine =' \
  scripts/utils/ollamaChat.ts

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_CHILD_IDENTITY_PRESENTATION_SEPARATED"
echo "SUPPORT_VALIDATION_UNCHANGED=true"
echo "SELECTED_CONTEXT_SEGMENTS_RUNTIME_IDENTITY_UNCHANGED=true"
echo "EVIDENCE_COMPOSITION_UNCHANGED=true"
echo "MODEL_INVOCATION_COUNT_UNCHANGED=true"
echo "NEXT_UNIT=RERUN_ADAPTIVE_DETAIL_MIXED_CONTENT_BEHAVIOR_LIVE"

git add \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat.child-identity-presentation.test.ts \
  scripts/separate-adaptive-detail-child-identity-presentation.sh

git commit -m "Separate Adaptive Detail child identity presentation"
git push
