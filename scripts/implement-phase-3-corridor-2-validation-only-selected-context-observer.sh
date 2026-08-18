#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 2 — IMPLEMENT VALIDATION-ONLY SELECTED CONTEXT OBSERVER ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 4e2e4d43 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/implement-phase-3-corridor-2-validation-only-selected-context-observer\.sh$|^ M scripts/implement-phase-3-corridor-2-validation-only-selected-context-observer\.sh$' ||
  true
)"
test -z "$unexpected"

python3 <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

context_anchor = '''  observeValidatedSelectedContextSegments?: (
    segments: readonly MatildaSelectedContextSegment[],
  ) => void;
  validationGenerationSeed?: number;
'''

context_replacement = '''  observeValidatedSelectedContextSegments?: (
    segments: readonly MatildaSelectedContextSegment[],
  ) => void;
  observeParsedSelectedContextSegments?: (
    segments: readonly MatildaSelectedContextSegment[],
  ) => void;
  validationGenerationSeed?: number;
'''

if "observeParsedSelectedContextSegments?:" in text:
    raise SystemExit("STOP: parsed selected-context observer already exists")
if context_anchor not in text:
    raise SystemExit("STOP: classified observer seam no longer matches repository")

text = text.replace(context_anchor, context_replacement, 1)

parse_anchor = '''    const result =
      parseStructuredResponse(rawResponse);

    validateMatildaInvestigationLifecycleContinuity(
'''

parse_replacement = '''    const result =
      parseStructuredResponse(rawResponse);

    if (context.observeParsedSelectedContextSegments) {
      context.observeParsedSelectedContextSegments(
        result.selectedContextSegments,
      );
    }

    validateMatildaInvestigationLifecycleContinuity(
'''

if parse_anchor not in text:
    raise SystemExit("STOP: classified post-parse seam no longer matches repository")

path.write_text(text.replace(parse_anchor, parse_replacement, 1))
PY

cat > scripts/utils/ollamaChat.parsed-selected-context-observer.test.ts << 'TEST_EOF'
import assert from "node:assert/strict";
import test from "node:test";

import {
  ollamaChat,
  type MatildaSelectedContextSegment,
} from "./ollamaChat";

const originalFetch = globalThis.fetch;

test.afterEach(() => {
  globalThis.fetch = originalFetch;
});

test(
  "parsed selected-context observer fires before invalid membership fails closed",
  async () => {
    const modelSelectedSegment = {
      relativePath: "docs/model-authored.md",
      sourceStartLine: 99,
      sourceEndLine: 101,
    };

    globalThis.fetch = async () =>
      new Response(
        JSON.stringify({
          response: JSON.stringify({
            reply: "Candidate response.",
            explanationStatus: "optional",
            selectedContextSegments: [modelSelectedSegment],
            supportSourceReferences: [],
            evidence: null,
            investigationLifecycle: null,
            durableInterpretation: "Candidate interpretation.",
          }),
        }),
        {
          status: 200,
          headers: { "content-type": "application/json" },
        },
      );

    let observed:
      readonly MatildaSelectedContextSegment[] | undefined;

    await assert.rejects(
      () =>
        ollamaChat("Question.", {
          projectContextSegmentCandidates: [
            {
              relativePath: "docs/supplied.md",
              parentRelativePath: "docs/supplied.md",
              parentLineNumber: 10,
              sourceStartLine: 10,
              sourceEndLine: 10,
              text: "Supplied candidate.",
            },
          ],
          observeParsedSelectedContextSegments: (segments) => {
            observed = [...segments];
          },
        }),
      /selected context segment that was not supplied/,
    );

    assert.deepEqual(observed, [modelSelectedSegment]);
  },
);
TEST_EOF

npx tsx --test scripts/utils/ollamaChat.parsed-selected-context-observer.test.ts
bash scripts/guard-ollama-response-contract.sh
git diff --check

echo "VALIDATION_ONLY_OBSERVER_IMPLEMENTATION=PASS"
echo "PRODUCTION_SEMANTIC_CHANGE=NONE"
echo "FAIL_CLOSED_MEMBERSHIP_VALIDATION=PRESERVED"
echo "THIRD_BEHAVIOR_VALIDATION_ATTEMPT=NOT_STARTED"
echo "DR_NOW=NO"
