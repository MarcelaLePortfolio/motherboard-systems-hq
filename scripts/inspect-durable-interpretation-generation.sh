#!/usr/bin/env bash
set -euo pipefail

printf '\n========== INSPECT DURABLE INTERPRETATION GENERATION ==========\n'

printf '\n=== Protected baseline ===\n'
printf 'HEAD: %s\n' "$(git rev-parse --short HEAD)"
printf 'DR:   20260804_123951\n'

printf '\n====================================================\n'

printf '\n=== Current Ollama response contract ===\n'
grep -nA20 -B5 \
  -E 'interface OllamaChatResult|reply:|durableInterpretation|return \{' \
  scripts/utils/ollamaChat.ts

printf '\n====================================================\n'

printf '\n=== Current prompt construction ===\n'
grep -nA80 -B20 \
  -E 'prompt:|body: JSON.stringify|fetch\(' \
  scripts/utils/ollamaChat.ts

printf '\n====================================================\n'

printf '\n=== Current workflow assignments ===\n'
grep -nA35 -B10 \
  -E 'ollamaResult\.reply|ollamaResult\.durableInterpretation|assistant_reply|matilda_observation' \
  server/matilda-chat-workflow.ts

printf '\n====================================================\n'

printf '\n=== Current route consumers ===\n'
grep -RIn \
  --exclude='*.test.ts' \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  'ollamaChat(' \
  routes server .

printf '\n====================================================\n'

printf '\nDesign questions for the next corridor:\n'
printf '  1. Should Ollama return structured JSON?\n'
printf '  2. Should parsing fail closed or gracefully degrade?\n'
printf '  3. How is reply validated independently from durableInterpretation?\n'
printf '  4. Can one invocation continue serving every existing consumer?\n'

printf '\n====================================================\n'

printf '\n=== Repository status ===\n'
git status --short
