#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADD ADAPTIVE DETAIL — SUPPORT VALIDATION OBSERVER ==="

if [[ "$(git rev-parse --short HEAD)" != "9753e6f3" ]]; then
  echo "STOP: HEAD no longer matches validation-observer checkpoint 9753e6f3."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/validate-adaptive-detail-mixed-content-live\.ts$|^\?\? scripts/run-adaptive-detail-mixed-content-live-validation\.sh$|^\?\? scripts/add-adaptive-detail-support-validation-observer\.sh$' ||
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

old = '''  observeValidatedSelectedContextSegments?: (
    segments: readonly MatildaSelectedContextSegment[],
  ) => void;
}'''

new = '''  observeValidatedSelectedContextSegments?: (
    segments: readonly MatildaSelectedContextSegment[],
  ) => void;
  observeParsedSupportSourceReferences?: (
    references: readonly MatildaSupportSourceReference[],
  ) => void;
}'''

if old not in text:
    raise SystemExit(
        "STOP: validation observer context seam no longer matches."
    )

text = text.replace(old, new, 1)

marker = '''    const deduplicatedSupportSourceReferences =
      result.supportSourceReferences.filter(
'''

observer = '''    if (context.observeParsedSupportSourceReferences) {
      context.observeParsedSupportSourceReferences(
        result.supportSourceReferences,
      );
    }

'''

if marker not in text:
    raise SystemExit(
        "STOP: support-reference validation seam no longer matches."
    )

text = text.replace(marker, observer + marker, 1)

path.write_text(text)
print(
    "Added optional validation-only parsed support-reference observer."
)
PY

python3 <<'PY'
from pathlib import Path

path = Path(
    "scripts/validate-adaptive-detail-mixed-content-live.ts"
)
text = path.read_text()

old = '''  let observed:
    readonly MatildaSelectedContextSegment[] | undefined;

  const result = await ollamaChat('''

new = '''  let observed:
    readonly MatildaSelectedContextSegment[] | undefined;

  let observedSupportReferences:
    readonly import("./utils/ollamaChat").MatildaSupportSourceReference[] |
    undefined;

  const result = await ollamaChat('''

if old not in text:
    raise SystemExit(
        "STOP: live validation observer declaration seam not found."
    )

text = text.replace(old, new, 1)

old = '''      observeValidatedSelectedContextSegments:
        (segments) => {
          observed = [...segments];
        },
    },
  );'''

new = '''      observeValidatedSelectedContextSegments:
        (segments) => {
          observed = [...segments];
        },
      observeParsedSupportSourceReferences:
        (references) => {
          observedSupportReferences = [...references];
          console.log(
            "PARSED SUPPORT SOURCE REFERENCES BEFORE VALIDATION",
          );
          console.log(
            JSON.stringify(
              observedSupportReferences,
              null,
              2,
            ),
          );
          console.log();
        },
    },
  );'''

if old not in text:
    raise SystemExit(
        "STOP: live validation context seam not found."
    )

path.write_text(text.replace(old, new, 1))

print(
    "Connected live validation to parsed support-reference observer."
)
PY

cat > scripts/utils/ollamaChat.support-validation-observer.test.ts <<'TEST_EOF'
import assert from "node:assert/strict";
import test from "node:test";

import {
  ollamaChat,
  type MatildaSupportSourceReference,
} from "./ollamaChat";

const originalFetch = globalThis.fetch;

test.afterEach(() => {
  globalThis.fetch = originalFetch;
});

test(
  "support observer exposes parsed model-authored references before supplied-source validation",
  async () => {
    globalThis.fetch = async () =>
      new Response(
        JSON.stringify({
          response: JSON.stringify({
            reply: "Answer.",
            explanationStatus: "optional",
            selectedContextSegments: [],
            supportSourceReferences: [
              {
                type: "project_context_excerpt",
                relativePath: "docs/wrong.md",
                lineNumber: 999,
              },
            ],
            evidence: null,
            durableInterpretation:
              "The user requested an answer.",
          }),
        }),
        {
          status: 200,
          headers: {
            "content-type": "application/json",
          },
        },
      );

    let observed:
      readonly MatildaSupportSourceReference[] |
      undefined;

    await assert.rejects(
      () =>
        ollamaChat("Question.", {
          observeParsedSupportSourceReferences:
            (references) => {
              observed = [...references];
            },
        }),
      /project-context support reference that was not supplied/i,
    );

    assert.deepEqual(
      observed,
      [
        {
          type: "project_context_excerpt",
          relativePath: "docs/wrong.md",
          lineNumber: 999,
        },
      ],
    );
  },
);

test(
  "normal invocation remains unchanged without support observer",
  async () => {
    globalThis.fetch = async () =>
      new Response(
        JSON.stringify({
          response: JSON.stringify({
            reply: "Answer.",
            explanationStatus: "optional",
            selectedContextSegments: [],
            supportSourceReferences: [],
            evidence: null,
            durableInterpretation:
              "The user requested an answer.",
          }),
        }),
        {
          status: 200,
          headers: {
            "content-type": "application/json",
          },
        },
      );

    const result =
      await ollamaChat("Question.");

    assert.equal(result.reply, "Answer.");
  },
);
TEST_EOF

echo
echo "=== SUPPORT OBSERVER TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.support-validation-observer.test.ts

echo
echo "=== FULL OLLAMA REGRESSION TESTS ==="
npx tsx --test scripts/utils/ollamaChat*.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== LIVE DIAGNOSTIC RUN ==="
set +e
npx tsx \
  scripts/validate-adaptive-detail-mixed-content-live.ts
live_rc=$?
set -e

echo "LIVE_DIAGNOSTIC_EXIT_CODE=$live_rc"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_SUPPORT_PROVENANCE_DIAGNOSTIC_CAPTURED"

git add \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat.support-validation-observer.test.ts \
  scripts/validate-adaptive-detail-mixed-content-live.ts \
  scripts/add-adaptive-detail-support-validation-observer.sh && \
git commit -m "Add Adaptive Detail support validation observer" && \
git push
