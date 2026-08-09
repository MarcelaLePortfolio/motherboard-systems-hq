#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLARIFY ADAPTIVE DETAIL — PARENT SUPPORT IDENTITY PROMPT ==="

if [[ "$(git rev-parse --short HEAD)" != "49dfdd93" ]]; then
  echo "STOP: HEAD no longer matches parent-support identity determination checkpoint 49dfdd93."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/run-adaptive-detail-mixed-content-live-validation\.sh$|^\?\? scripts/clarify-adaptive-detail-parent-support-identity-prompt\.sh$' ||
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

needle = (
    '            "For project-context support, use type project_context_excerpt '
    'with the exact relativePath and lineNumber supplied in bounded project context evidence.",'
)

clarification = (
    needle
    + '\n'
    + '            "For project_context_excerpt support, use only a Source identity explicitly shown under Bounded project context evidence.",'
    + '\n'
    + '            "Never use a Segment source line range, sourceStartLine, sourceEndLine, or child segment line number as a project_context_excerpt support identity.",'
)

if needle not in text:
    raise SystemExit(
        "STOP: expected project-context support prompt instruction not found."
    )

if "Never use a Segment source line range" in text:
    raise SystemExit(
        "STOP: parent-support identity clarification already appears to exist."
    )

path.write_text(text.replace(needle, clarification, 1))
print("Clarified parent Source identity versus child Segment source identity.")
PY

cat > scripts/utils/ollamaChat.parent-support-identity-prompt.test.ts <<'TEST_EOF'
import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const source = fs.readFileSync(
  new URL("./ollamaChat.ts", import.meta.url),
  "utf8",
);

test(
  "project-context support is explicitly restricted to parent Source identities",
  () => {
    assert.match(
      source,
      /For project_context_excerpt support, use only a Source identity explicitly shown under Bounded project context evidence\./,
    );

    assert.match(
      source,
      /Never use a Segment source line range, sourceStartLine, sourceEndLine, or child segment line number as a project_context_excerpt support identity\./,
    );
  },
);

test(
  "existing parent support and child semantic identity instructions remain distinct",
  () => {
    assert.match(
      source,
      /For project-context support, use type project_context_excerpt with the exact relativePath and lineNumber supplied in bounded project context evidence\./,
    );

    assert.match(
      source,
      /Segment source:/,
    );

    assert.match(
      source,
      /selectedContextSegments/,
    );
  },
);
TEST_EOF

echo
echo "=== TARGETED PARENT SUPPORT IDENTITY TEST ==="
npx tsx --test \
  scripts/utils/ollamaChat.parent-support-identity-prompt.test.ts

echo
echo "=== FULL OLLAMA REGRESSION SUITE ==="
npx tsx --test scripts/utils/ollamaChat*.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/utils/ollamaChat\.ts$|^scripts/utils/ollamaChat\.parent-support-identity-prompt\.test\.ts$|^scripts/clarify-adaptive-detail-parent-support-identity-prompt\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: implementation modified files outside the authorized surface:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "AUTHORIZED_CHANGE_SURFACE_ONLY"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_PARENT_SUPPORT_IDENTITY_PROMPT_CLARIFIED"
echo "SUPPORT_VALIDATION_UNCHANGED=true"
echo "SELECTED_CONTEXT_SEGMENTS_IDENTITY_UNCHANGED=true"
echo "EVIDENCE_COMPOSITION_UNCHANGED=true"
echo "MODEL_INVOCATION_COUNT_UNCHANGED=true"
echo "NEXT_UNIT=RERUN_ADAPTIVE_DETAIL_MIXED_CONTENT_BEHAVIOR_LIVE"
