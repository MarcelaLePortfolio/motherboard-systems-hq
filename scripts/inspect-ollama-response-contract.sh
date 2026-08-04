#!/usr/bin/env bash
set -euo pipefail

printf '\n========== INSPECT OLLAMA RESPONSE CONTRACT ==========\n'

printf '\n=== ollamaChat() signature ===\n'
grep -nA40 -B10 \
  'export async function ollamaChat' \
  scripts/utils/ollamaChat.ts

printf '\n====================================================\n'

printf '\n=== Return statements ===\n'
grep -nA10 -B5 \
  'return ' \
  scripts/utils/ollamaChat.ts

printf '\n====================================================\n'

printf '\n=== Current consumers ===\n'
grep -RIn \
  --exclude='*.test.ts' \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  'await ollamaChat(' \
  server routes .

printf '\n====================================================\n'

printf '\n=== Decision questions ===\n'
printf '1. Does ollamaChat() return only a string today?\n'
printf '2. Are all callers expecting a string?\n'
printf '3. Could a typed object preserve backwards compatibility?\n'
printf '4. Would one model invocation still satisfy every consumer?\n'

printf '\n=== Repository status ===\n'
git status --short
