#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 3 — IMPLEMENT REASONING STATUS SURFACING ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 86f1189e HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/implement-phase-3-corridor-3-reasoning-status-surfacing\.sh$|^ M scripts/implement-phase-3-corridor-3-reasoning-status-surfacing\.sh$' ||
  true
)"
test -z "$unexpected"

python3 <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

anchor = '''            "For reply:",
            "Respond directly to the user in natural language.",
            "Lead with a concise natural-language summary that communicates the conclusion, recommendation, or current assessment.",
'''

replacement = '''            "For reply:",
            "Respond directly to the user in natural language.",
            "Use explanationStatus to govern the amount of supporting reasoning in reply without exposing explanationStatus itself as a user-visible label.",
            "When explanationStatus is optional, keep reply concise and include only the supporting reasoning needed for the immediate interaction.",
            "When explanationStatus is recommended, keep the concise answer first, then include enough supporting reasoning to preserve any material architectural boundary, implementation boundary, uncertainty, tradeoff, or evidence interpretation that could change the user's next engineering decision.",
            "Do not add a visible Reasoning Status, Optional, or Recommended label merely because explanationStatus is present.",
            "Lead with a concise natural-language summary that communicates the conclusion, recommendation, or current assessment.",
'''

if replacement in text:
    raise SystemExit("STOP: Corridor 3 surfacing contract already implemented")

if anchor not in text:
    raise SystemExit("STOP: expected reply-composition prompt anchor not found")

path.write_text(text.replace(anchor, replacement, 1))
PY

cat > scripts/utils/ollamaChat.reasoning-status-surfacing.test.ts << 'TEST_EOF'
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const source = readFileSync(
  new URL("./ollamaChat.ts", import.meta.url),
  "utf8",
);

test(
  "reasoning status governs reply detail without becoming a visible label",
  () => {
    assert.match(
      source,
      /Use explanationStatus to govern the amount of supporting reasoning in reply without exposing explanationStatus itself as a user-visible label\./,
    );

    assert.match(
      source,
      /When explanationStatus is optional, keep reply concise and include only the supporting reasoning needed for the immediate interaction\./,
    );

    assert.match(
      source,
      /When explanationStatus is recommended, keep the concise answer first, then include enough supporting reasoning to preserve any material architectural boundary, implementation boundary, uncertainty, tradeoff, or evidence interpretation that could change the user's next engineering decision\./,
    );

    assert.match(
      source,
      /Do not add a visible Reasoning Status, Optional, or Recommended label merely because explanationStatus is present\./,
    );
  },
);
TEST_EOF

npx tsx --test scripts/utils/ollamaChat.reasoning-status-surfacing.test.ts
bash scripts/guard-ollama-response-contract.sh
git diff --check

echo "CORRIDOR_3_SURFACING_IMPLEMENTATION=PASS"
echo "IMPLEMENTATION_SURFACE=OLLAMA_CHAT_REPLY_COMPOSITION_PROMPT_ONLY"
echo "VISIBLE_REASONING_STATUS_LABEL=NO"
echo "UI_CHANGE=NONE"
echo "WORKFLOW_CHANGE=NONE"
echo "SCHEMA_CHANGE=NONE"
echo "MODEL_INVOCATION_COUNT_CHANGE=NONE"
echo "FAIL_CLOSED_VALIDATION_CHANGE=NONE"
echo "CORRIDOR_2_RELIABILITY_LIMIT=PRESERVED"
echo "MODEL_BEHAVIORAL_RELIABILITY_CLAIM=NONE"
echo "DR_NOW=NO"
