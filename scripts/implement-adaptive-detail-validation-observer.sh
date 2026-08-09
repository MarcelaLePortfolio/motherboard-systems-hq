#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== IMPLEMENT ADAPTIVE DETAIL — VALIDATION OBSERVER ==="

if [[ "$(git rev-parse --short HEAD)" != "4974333a" ]]; then
  echo "STOP: HEAD no longer matches observability investigation checkpoint 4974333a."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/implement-adaptive-detail-validation-observer\.sh$' ||
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

old = '''interface MatildaSelectedContextSegment {
  relativePath: string;
  sourceStartLine: number;
  sourceEndLine: number;
}'''

new = '''export interface MatildaSelectedContextSegment {
  relativePath: string;
  sourceStartLine: number;
  sourceEndLine: number;
}'''

if old not in text:
    raise SystemExit(
        "STOP: selected-context segment interface seam no longer matches investigation."
    )

text = text.replace(old, new, 1)

old = '''  explicitEvidenceRequest?: boolean;
}'''

new = '''  explicitEvidenceRequest?: boolean;
  observeValidatedSelectedContextSegments?: (
    segments: readonly MatildaSelectedContextSegment[],
  ) => void;
}'''

if old not in text:
    raise SystemExit(
        "STOP: OllamaChatContext extension seam no longer matches investigation."
    )

text = text.replace(old, new, 1)

marker = '''    const supportDrivenEvidenceSources =
'''

observer = '''    if (context.observeValidatedSelectedContextSegments) {
      context.observeValidatedSelectedContextSegments(
        deduplicatedSelectedContextSegments,
      );
    }

'''

if marker not in text:
    raise SystemExit(
        "STOP: post-validation observer insertion seam no longer matches investigation."
    )

text = text.replace(marker, observer + marker, 1)

path.write_text(text)
print("Implemented optional post-validation selected-context observer.")
PY

cat > scripts/utils/ollamaChat.selected-context-observer.test.ts <<'TEST_EOF'
import assert from "node:assert/strict";
import test from "node:test";

import {
  ollamaChat,
  type MatildaSelectedContextSegment,
} from "./ollamaChat";

const originalFetch = globalThis.fetch;

function installResponse(
  structuredResponse: Record<string, unknown>,
): void {
  globalThis.fetch = async () =>
    new Response(
      JSON.stringify({
        response: JSON.stringify(structuredResponse),
      }),
      {
        status: 200,
        headers: {
          "content-type": "application/json",
        },
      },
    );
}

test.afterEach(() => {
  globalThis.fetch = originalFetch;
});

function baseResponse(
  selectedContextSegments: unknown[],
  supportSourceReferences: unknown[] = [],
) {
  return {
    reply: "The relevant implementation behavior is supported.",
    explanationStatus: "optional",
    selectedContextSegments,
    supportSourceReferences,
    evidence: null,
    durableInterpretation:
      "The relevant implementation behavior is supported.",
  };
}

const suppliedCandidate = {
  relativePath: "docs/adaptive-detail.md",
  parentRelativePath: "docs/adaptive-detail.md",
  parentLineNumber: 10,
  sourceStartLine: 10,
  sourceEndLine: 12,
  text: "Relevant implementation behavior.",
};

test(
  "normal production-style invocation remains valid without an observer",
  async () => {
    installResponse(
      baseResponse([
        {
          relativePath: suppliedCandidate.relativePath,
          sourceStartLine: suppliedCandidate.sourceStartLine,
          sourceEndLine: suppliedCandidate.sourceEndLine,
        },
      ]),
    );

    const result = await ollamaChat("Question.", {
      projectContextSegmentCandidates: [
        suppliedCandidate,
      ],
    });

    assert.equal(
      result.reply,
      "The relevant implementation behavior is supported.",
    );

    assert.equal(
      "selectedContextSegments" in result,
      false,
    );
  },
);

test(
  "observer receives only validated deterministically deduplicated selections",
  async () => {
    const identity = {
      relativePath: suppliedCandidate.relativePath,
      sourceStartLine: suppliedCandidate.sourceStartLine,
      sourceEndLine: suppliedCandidate.sourceEndLine,
    };

    installResponse(
      baseResponse([
        identity,
        identity,
      ]),
    );

    let observed:
      readonly MatildaSelectedContextSegment[] | undefined;

    await ollamaChat("Question.", {
      projectContextSegmentCandidates: [
        suppliedCandidate,
      ],
      observeValidatedSelectedContextSegments:
        (segments) => {
          observed = segments;
        },
    });

    assert.deepEqual(
      observed,
      [identity],
    );
  },
);

test(
  "invented selection fails before observer invocation",
  async () => {
    installResponse(
      baseResponse([
        {
          relativePath: "docs/invented.md",
          sourceStartLine: 99,
          sourceEndLine: 101,
        },
      ]),
    );

    let observerCalled = false;

    await assert.rejects(
      () =>
        ollamaChat("Question.", {
          projectContextSegmentCandidates: [
            suppliedCandidate,
          ],
          observeValidatedSelectedContextSegments:
            () => {
              observerCalled = true;
            },
        }),
      /selected context segment that was not supplied/,
    );

    assert.equal(observerCalled, false);
  },
);

test(
  "parent support inconsistency fails before observer invocation",
  async () => {
    installResponse(
      baseResponse(
        [],
        [
          {
            type: "project_context_excerpt",
            relativePath: "docs/adaptive-detail.md",
            lineNumber: 10,
          },
        ],
      ),
    );

    let observerCalled = false;

    await assert.rejects(
      () =>
        ollamaChat("Question.", {
          projectContextExcerpts: [
            {
              relativePath: "docs/adaptive-detail.md",
              lineNumber: 10,
              excerpt:
                "Relevant implementation behavior.",
              provenance:
                "git_tracked_project_file",
              authorityStatus:
                "candidate_evidence_not_authority",
            },
          ],
          projectContextSegmentCandidates: [
            suppliedCandidate,
          ],
          observeValidatedSelectedContextSegments:
            () => {
              observerCalled = true;
            },
        }),
      /project-context support without selecting a supplied child segment/,
    );

    assert.equal(observerCalled, false);
  },
);
TEST_EOF

echo
echo "=== OBSERVER CONTRACT TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.selected-context-observer.test.ts

echo
echo "=== FULL OLLAMA REGRESSION TESTS ==="
npx tsx --test scripts/utils/ollamaChat*.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY NORMAL WORKFLOW DOES NOT USE OBSERVER ==="
if grep -n \
  'observeValidatedSelectedContextSegments' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow unexpectedly references validation observer."
  exit 2
fi

echo "PRODUCTION_WORKFLOW_OBSERVER_ABSENT"

echo
echo "=== VERIFY RESULT CONTRACT NOT WIDENED ==="
result_contract="$(
  sed -n \
    '/export interface OllamaChatResult {/,/^}/p' \
    scripts/utils/ollamaChat.ts
)"

printf '%s\n' "$result_contract"

if printf '%s\n' "$result_contract" |
   grep -q 'selectedContextSegments'
then
  echo "STOP: OllamaChatResult was widened."
  exit 2
fi

echo "OLLAMA_CHAT_RESULT_UNCHANGED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_VALIDATION_OBSERVER_SEAM_READY"
echo "OBSERVER_OPTIONAL=true"
echo "OBSERVER_POST_VALIDATION=true"
echo "OBSERVER_PERSISTENCE=false"
echo "OLLAMA_CHAT_RESULT_WIDENED=false"
echo "MODEL_INVOCATION_COUNT_UNCHANGED=true"
echo "NEXT_UNIT=VALIDATE_ADAPTIVE_DETAIL_MIXED_CONTENT_BEHAVIOR_LIVE"
