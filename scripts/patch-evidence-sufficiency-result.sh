#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

python3 - <<'PY'
from pathlib import Path

adapter = Path("scripts/utils/ollamaChat.ts")
text = adapter.read_text()

old = '''export interface OllamaChatResult {
  reply: string;
  explanationStatus: MatildaExplanationStatus;
  supportSourceReferences: MatildaSupportSourceReference[];
  durableInterpretation: string;
}'''

new = '''export interface OllamaChatResult {
  reply: string;
  explanationStatus: MatildaExplanationStatus;
  supportSourceReferences: MatildaSupportSourceReference[];
  evidenceSufficient: boolean;
  durableInterpretation: string;
}'''

if old not in text:
    raise SystemExit("OllamaChatResult interface anchor not found.")

text = text.replace(old, new, 1)

old = '''    return {
      ...result,
      supportSourceReferences:
        deduplicatedSupportSourceReferences,
    };'''

new = '''    return {
      ...result,
      supportSourceReferences:
        deduplicatedSupportSourceReferences,
      evidenceSufficient:
        deduplicatedSupportSourceReferences.length > 0,
    };'''

if old not in text:
    raise SystemExit("Validated result return anchor not found.")

text = text.replace(old, new, 1)

adapter.write_text(text)

test_path = Path(
    "scripts/utils/ollamaChat.support-source-references.test.ts"
)
test = test_path.read_text()

old = '''      assert.deepEqual(
        result.supportSourceReferences,
        [
          {
            type: "conversation_turn",
            sourceTurnId: "turn-123",
          },
          {
            type: "project_context_excerpt",
            relativePath:
              "server/matilda-chat-workflow.ts",
            lineNumber: 155,
          },
        ],
      );'''

new = '''      assert.deepEqual(
        result.supportSourceReferences,
        [
          {
            type: "conversation_turn",
            sourceTurnId: "turn-123",
          },
          {
            type: "project_context_excerpt",
            relativePath:
              "server/matilda-chat-workflow.ts",
            lineNumber: 155,
          },
        ],
      );

      assert.equal(
        result.evidenceSufficient,
        true,
      );'''

if old not in test:
    raise SystemExit("Positive evidence-sufficiency assertion anchor not found.")

test = test.replace(old, new, 1)

if "returns false evidence sufficiency for an empty validated support set" not in test:
    test += r'''

test(
  "ollamaChat returns false evidence sufficiency for an empty validated support set",
  async () => {
    const originalFetch = globalThis.fetch;

    globalThis.fetch = (async () => ({
      ok: true,
      status: 200,
      statusText: "OK",
      json: async () => ({
        response: JSON.stringify({
          reply: "Conclusion.",
          explanationStatus: "optional",
          supportSourceReferences: [],
          durableInterpretation:
            "Durable interpretation.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      const result = await ollamaChat("Question.");

      assert.deepEqual(
        result.supportSourceReferences,
        [],
      );

      assert.equal(
        result.evidenceSufficient,
        false,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
'''

test_path.write_text(test)

print("Deterministic Evidence Sufficiency result implemented.")
PY

npx tsx --test \
  scripts/utils/ollamaChat.test.ts \
  scripts/utils/ollamaChat.summary-composition.test.ts \
  scripts/utils/ollamaChat.explanation-status.test.ts \
  scripts/utils/ollamaChat.explanation-request.test.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.support-source-production.test.ts && \
bash scripts/guard-ollama-response-contract.sh && \
git diff --check && \
git add \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts && \
git commit -m "Derive deterministic Matilda evidence sufficiency" && \
git push
