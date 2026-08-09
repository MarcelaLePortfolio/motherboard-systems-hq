#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

EXPECTED_HEAD="c74fbdc2"

if [[ "$(git rev-parse --short HEAD)" != "$EXPECTED_HEAD" ]]; then
  echo "STOP: HEAD no longer matches stale-history classification checkpoint $EXPECTED_HEAD."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^ M scripts/validate-source-excerpt-first-live\.ts$|^\?\? scripts/classify-phase-1-response-composition-state\.sh$|^\?\? scripts/determine-next-response-composition-corridor\.sh$|^\?\? scripts/reconcile-source-excerpt-live-validator-with-selected-context-contract\.sh$|^\?\? scripts/validate-source-excerpt-first-live-contract\.test\.ts$|^\?\? scripts/investigate-source-excerpt-live-support-source-competition\.sh$|^\?\? scripts/remove-stale-conversation-support-from-source-excerpt-live-fixture\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

python3 - <<'PY'
from pathlib import Path

path = Path("scripts/validate-source-excerpt-first-live.ts")
text = path.read_text()

old = '''      history: [
        {
          sourceTurnId:
            "turn-source-excerpt-live-validation",
          userMessage:
            "We need repository evidence for the workflow invocation seam.",
          assistantReply:
            "The repository excerpt should establish that directly.",
        },
      ],
'''

if old not in text:
    raise SystemExit(
        "STOP: expected stale conversation-history block was not found."
    )

path.write_text(text.replace(old, "", 1))
PY

cat > scripts/validate-source-excerpt-first-live-contract.test.ts <<'TS_EOF'
import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const source = fs.readFileSync(
  "scripts/validate-source-excerpt-first-live.ts",
  "utf8",
);

test(
  "Source-Excerpt live validator supplies current child-candidate contract",
  () => {
    assert.match(
      source,
      /projectContextSegmentCandidates:\s*\[/,
    );

    assert.match(
      source,
      /parentRelativePath:\s*relativePath/,
    );

    assert.match(
      source,
      /parentLineNumber/,
    );

    assert.match(
      source,
      /sourceStartLine:\s*parentLineNumber/,
    );

    assert.match(
      source,
      /sourceEndLine:\s*parentLineNumber/,
    );

    assert.match(
      source,
      /text:\s*suppliedExcerpt/,
    );
  },
);

test(
  "Source-Excerpt live validator preserves parent Source identity",
  () => {
    assert.match(
      source,
      /"server\/matilda-chat-workflow\.ts"/,
    );

    assert.match(
      source,
      /const parentLineNumber = 155/,
    );
  },
);

test(
  "Source-Excerpt live validator isolates repository evidence without competing conversation support",
  () => {
    assert.doesNotMatch(
      source,
      /\bhistory\s*:/,
    );

    assert.doesNotMatch(
      source,
      /turn-source-excerpt-live-validation/,
    );

    assert.match(
      source,
      /projectContextExcerpts:\s*\[/,
    );
  },
);
TS_EOF

echo "=== VALIDATOR CONTRACT TEST ==="
npx tsx --test \
  scripts/validate-source-excerpt-first-live-contract.test.ts

echo
echo "=== VERIFY STALE HISTORY REMOVED ==="
if grep -nE \
  'history:|turn-source-excerpt-live-validation' \
  scripts/validate-source-excerpt-first-live.ts
then
  echo "STOP: stale conversation support remains in Source-Excerpt live fixture."
  exit 2
fi

echo "STALE_CONVERSATION_SUPPORT_REMOVED"

echo
echo "=== VERIFY CHILD CANDIDATE PRESERVED ==="
grep -n -A8 -B4 \
  'projectContextSegmentCandidates' \
  scripts/validate-source-excerpt-first-live.ts

echo
echo "=== EVIDENCE COMPOSITION CLOSURE CHECK ==="
set +e
./scripts/run-evidence-composition-closure-check.sh
closure_rc=$?
set -e

echo "EVIDENCE_COMPOSITION_CLOSURE_EXIT_CODE=$closure_rc"

if [[ "$closure_rc" -ne 0 ]]; then
  echo "STOP: Evidence Composition closure is still not established."
  exit "$closure_rc"
fi

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed during validation-only fixture reconciliation."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/validate-source-excerpt-first-live\.ts$|^scripts/validate-source-excerpt-first-live-contract\.test\.ts$|^scripts/remove-stale-conversation-support-from-source-excerpt-live-fixture\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside the authorized validation-only change surface changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "VALIDATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "STALE_SOURCE_EXCERPT_CONVERSATION_SUPPORT_REMOVED"
echo "EVIDENCE_COMPOSITION_CLOSURE_VALIDATED"
echo "PRODUCTION_RUNTIME_UNCHANGED"
echo "PHASE_1_COMPLETION=PENDING_RECLASSIFICATION"
echo "PHASE_2_START=BLOCKED_UNTIL_RECLASSIFICATION"
echo "NEXT_ACTION=RECLASSIFY_PHASE_1_RESPONSE_COMPOSITION_STATE"

git add \
  scripts/validate-source-excerpt-first-live.ts \
  scripts/validate-source-excerpt-first-live-contract.test.ts \
  scripts/remove-stale-conversation-support-from-source-excerpt-live-fixture.sh

git commit -m "Remove stale conversation support from Source-Excerpt live fixture"
git push
