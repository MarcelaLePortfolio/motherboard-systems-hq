#!/usr/bin/env bash
set -euo pipefail

printf '\n========== INSPECT MATILDA RESPONSE CONTRACT ==========\n'

printf '\n=== Locate Ollama implementation ===\n'
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  'async function ollamaChat\|export.*ollamaChat\|const ollamaChat' \
  .

printf '\n====================================================\n'

printf '\n=== Workflow artifact assignment ===\n'
grep -nA70 -B20 \
  -E 'const conversationalReply = await ollamaChat|matilda_observation: conversationalReply|assistant_reply: conversationalReply' \
  server/matilda-chat-workflow.ts

printf '\n====================================================\n'

printf '\n=== Active Ollama call sites ===\n'
grep -RIn \
  --exclude='*.test.ts' \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  'ollamaChat(' \
  server routes scripts . || true

printf '\n====================================================\n'

printf '\n=== Living Draft consumption ===\n'
grep -nA40 -B10 \
  -E 'entry\.matilda_observation|current_interpretation' \
  db/matilda-draft-synthesis-runtime.ts

printf '\n====================================================\n'

printf '\nDecision boundary:\n'
printf '  • Preserve one model invocation.\n'
printf '  • Preserve the user-facing reply.\n'
printf '  • Determine whether one model response can produce\n'
printf '    both a conversational artifact and a durable interpretation.\n'
printf '  • No implementation changes in this corridor.\n'

printf '\n=== Repository status ===\n'
git status --short
