#!/usr/bin/env bash
set -euo pipefail

printf '\n========== GUARD MATILDA STUB RESOLUTION ==========\n'

if [ -e matilda-chat-stub.js ]; then
  printf '\nFAIL: matilda-chat-stub.js exists and may shadow matilda-chat-stub.ts.\n'
  exit 1
fi

if grep -q \
  "createInterpretationEvidenceLedgerEntry" \
  matilda-chat-stub.ts
then
  printf '\nFAIL: matilda-chat-stub.ts must not own IEL persistence.\n'
  exit 1
fi

if ! grep -q \
  "createInterpretationEvidenceLedgerEntry" \
  server/matilda-chat-workflow.ts
then
  printf '\nFAIL: Workflow no longer owns IEL persistence.\n'
  exit 1
fi

if ! grep -q '^/matilda-chat-stub\.js$' .gitignore; then
  printf '\nFAIL: .gitignore no longer protects against stale compiled stub shadowing.\n'
  exit 1
fi

printf '\nPASS: Module resolution and IEL ownership remain correct.\n'
