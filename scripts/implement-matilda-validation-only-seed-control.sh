#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== IMPLEMENT MATILDA — VALIDATION-ONLY SEED CONTROL ==="

EXPECTED_HEAD="7262ab18"

if [[ "$(git rev-parse --short HEAD)" != "$EXPECTED_HEAD" ]]; then
  echo "STOP: HEAD no longer matches validation-only generation-control checkpoint $EXPECTED_HEAD."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/implement-matilda-validation-only-seed-control\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== CAPTURE PRODUCTION WORKFLOW BASELINE ==="
workflow_before="$(mktemp)"
cp server/matilda-chat-workflow.ts "$workflow_before"

echo
echo "=== PATCH OPTIONAL VALIDATION SEED SEAM ==="
python3 <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

context_marker = "export interface OllamaChatContext {"
if context_marker not in text:
    raise SystemExit("STOP: OllamaChatContext declaration not found.")

field_marker = "  observeParsedSupportSourceReferences?:"
if field_marker not in text:
    raise SystemExit("STOP: established optional observer seam not found.")

if "validationGenerationSeed?:" not in text:
    text = text.replace(
        field_marker,
        "  validationGenerationSeed?: number;\n"
        + field_marker,
        1,
    )

payload_marker = """          model: OLLAMA_CHAT_MODEL,
          stream: false,
          format: OLLAMA_CHAT_OUTPUT_SCHEMA,
          prompt:"""

if payload_marker not in text:
    raise SystemExit("STOP: established Ollama request payload seam not found.")

replacement = """          model: OLLAMA_CHAT_MODEL,
          stream: false,
          format: OLLAMA_CHAT_OUTPUT_SCHEMA,
          ...(context.validationGenerationSeed === undefined
            ? {}
            : {
                options: {
                  seed: context.validationGenerationSeed,
                },
              }),
          prompt:"""

if "seed: context.validationGenerationSeed" not in text:
    text = text.replace(payload_marker, replacement, 1)

path.write_text(text)
PY

cat > scripts/utils/ollamaChat.validation-seed.test.ts <<'TEST_EOF'
import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

const validResponse = JSON.stringify({
  reply: "Answer.",
  durableInterpretation: "Interpretation.",
  selectedContextSegments: [],
  supportSourceReferences: [],
  explanationStatus: null,
});

test(
  "normal invocation omits validation-only generation options",
  async () => {
    const originalFetch = globalThis.fetch;
    let invocationCount = 0;
    let capturedBody: Record<string, unknown> | null = null;

    globalThis.fetch = (async (
      _input: string | URL | Request,
      init?: RequestInit,
    ) => {
      invocationCount += 1;
      capturedBody = JSON.parse(String(init?.body));

      return new Response(
        JSON.stringify({ response: validResponse }),
        {
          status: 200,
          headers: {
            "Content-Type": "application/json",
          },
        },
      );
    }) as typeof fetch;

    try {
      await ollamaChat("Question.");

      assert.equal(invocationCount, 1);
      assert.ok(capturedBody);
      assert.equal(
        Object.prototype.hasOwnProperty.call(
          capturedBody,
          "options",
        ),
        false,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "validation seed reaches the existing single Ollama invocation",
  async () => {
    const originalFetch = globalThis.fetch;
    let invocationCount = 0;
    let capturedBody: Record<string, unknown> | null = null;

    globalThis.fetch = (async (
      _input: string | URL | Request,
      init?: RequestInit,
    ) => {
      invocationCount += 1;
      capturedBody = JSON.parse(String(init?.body));

      return new Response(
        JSON.stringify({ response: validResponse }),
        {
          status: 200,
          headers: {
            "Content-Type": "application/json",
          },
        },
      );
    }) as typeof fetch;

    try {
      await ollamaChat("Question.", {
        validationGenerationSeed: 424242,
      });

      assert.equal(invocationCount, 1);
      assert.ok(capturedBody);
      assert.deepEqual(
        capturedBody.options,
        {
          seed: 424242,
        },
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
TEST_EOF

echo
echo "=== VALIDATION-SEED CONTRACT TESTS ==="
npx tsx --test scripts/utils/ollamaChat.validation-seed.test.ts

echo
echo "=== OLLAMA REGRESSION SUITE ==="
npx tsx --test \
  scripts/utils/ollamaChat.test.ts \
  scripts/utils/ollamaChat.summary-composition.test.ts \
  scripts/utils/ollamaChat.reasoning-composition.test.ts \
  scripts/utils/ollamaChat.boundary-composition.test.ts \
  scripts/utils/ollamaChat.explanation-status.test.ts \
  scripts/utils/ollamaChat.selected-context-observer.test.ts \
  scripts/utils/ollamaChat.support-validation-observer.test.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts \
  scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts \
  scripts/utils/ollamaChat.structured-evidence-object.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION WORKFLOW UNCHANGED ==="
if ! cmp -s "$workflow_before" server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow changed."
  diff -u "$workflow_before" server/matilda-chat-workflow.ts || true
  exit 2
fi
echo "PRODUCTION_WORKFLOW_UNCHANGED"

if grep -q 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow supplies validation-only generation seed."
  exit 2
fi
echo "PRODUCTION_WORKFLOW_SEED_ABSENT"

echo
echo "=== VERIFY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/utils/ollamaChat\.ts$|^scripts/utils/ollamaChat\.validation-seed\.test\.ts$|^scripts/implement-matilda-validation-only-seed-control\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside authorized seed-control scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "VALIDATION_SEED_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== VERIFY CONTROL REMAINS SEED-ONLY ==="
diff_text="$(git diff -- scripts/utils/ollamaChat.ts)"

if printf '%s\n' "$diff_text" | grep -E '^\+.*\b(temperature|top_p|top_k)\b'; then
  echo "STOP: unauthorized sampling parameter introduced."
  exit 2
fi

echo "SEED_ONLY_CONTROL_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "MATILDA_VALIDATION_ONLY_SEED_CONTROL_IMPLEMENTED"
echo "PRODUCTION_GENERATION_POLICY_UNCHANGED"
echo "PRODUCTION_DEFAULT_SEED=false"
echo "RETRIES_ADDED=false"
echo "MODEL_INVOCATIONS_ADDED=false"
echo "SUPPORT_CONTRACT_CHANGED=false"
echo "SELECTED_CONTEXT_CONTRACT_CHANGED=false"
echo "EVIDENCE_CONTRACT_CHANGED=false"
echo "NEXT_UNIT=VALIDATE_ADAPTIVE_DETAIL_SEEDED_REPRODUCIBILITY"

git add \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat.validation-seed.test.ts \
  scripts/implement-matilda-validation-only-seed-control.sh

git commit -m "Add validation-only Matilda generation seed"
git push
