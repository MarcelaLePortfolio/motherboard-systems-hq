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
require_marker "$ADAPTER" "format: OLLAMA_CHAT_OUTPUT_SCHEMA"
require_marker "$ADAPTER" "parseStructuredResponse(rawResponse)"
require_marker "$ADAPTER" "Ollama returned malformed structured response JSON."
require_marker "$ADAPTER" "Ollama returned an empty durable interpretation."

# Summary Composition contract
require_marker "$ADAPTER" "Lead with a concise natural-language summary that communicates the conclusion, recommendation, or current assessment."
require_marker "$ADAPTER" "Write the opening summary as a complete paragraph rather than shorthand or bullet points whenever practical."
require_marker "$ADAPTER" "After the opening summary, include only the supporting detail needed for the current interaction."
require_marker "$ADAPTER" "Preserve material uncertainty, scope boundaries, and evidence distinctions when they affect the conclusion."
require_marker "$ADAPTER" "Avoid restating already-established context unless it materially affects the current response."

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
printf '  ✓ structured reply and durable interpretation generation\n'
printf '  ✓ Summary Composition prompt contract\n'
printf '  ✓ user-facing reply remains separately consumed\n'
printf '  ✓ malformed or incomplete structured output fails closed\n'
