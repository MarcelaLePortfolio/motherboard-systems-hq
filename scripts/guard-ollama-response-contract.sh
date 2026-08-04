#!/usr/bin/env bash
set -euo pipefail

printf '\n========== GUARD OLLAMA RESPONSE CONTRACT ==========\n'

ADAPTER="scripts/utils/ollamaChat.ts"
WORKFLOW="server/matilda-chat-workflow.ts"
ROUTE="routes/matilda.ts"

for file in "$ADAPTER" "$WORKFLOW" "$ROUTE"; do
  if [ ! -f "$file" ]; then
    printf '\nFAIL: required file is missing: %s\n' "$file"
    exit 1
  fi
done

require_marker() {
  local file="$1"
  local marker="$2"

  if ! grep -Fq "$marker" "$file"; then
    printf '\nFAIL: missing required contract marker in %s:\n%s\n' \
      "$file" "$marker"
    exit 1
  fi
}

require_marker "$ADAPTER" "export interface OllamaChatResult"
require_marker "$ADAPTER" "reply: string;"
require_marker "$ADAPTER" "durableInterpretation: string;"
require_marker "$ADAPTER" "Promise<OllamaChatResult>"
require_marker "$ADAPTER" "durableInterpretation: reply"

require_marker "$WORKFLOW" "ollamaResult.reply"
require_marker "$WORKFLOW" "ollamaResult.durableInterpretation"
require_marker "$WORKFLOW" "matilda_observation:"
require_marker "$WORKFLOW" "durableInterpretation"
require_marker "$WORKFLOW" "assistant_reply:"
require_marker "$WORKFLOW" "conversationalReply"

require_marker "$ROUTE" "return result.reply;"

GENERATE_REFERENCE_COUNT="$(
  grep -Fc '/api/generate' "$ADAPTER"
)"

if [ "$GENERATE_REFERENCE_COUNT" -ne 1 ]; then
  printf '\nFAIL: expected exactly one Ollama generation endpoint reference; found %s.\n' \
    "$GENERATE_REFERENCE_COUNT"
  exit 1
fi

printf '\nPASS: structured Ollama response contract remains intact.\n'
printf '  ✓ one typed response object\n'
printf '  ✓ one model invocation seam\n'
printf '  ✓ user-facing reply remains separate by contract\n'
printf '  ✓ durable interpretation remains separately addressable\n'
