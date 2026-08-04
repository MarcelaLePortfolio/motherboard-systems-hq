#!/usr/bin/env bash
set -euo pipefail

printf '\n========== INSPECT ACTIVE OLLAMA CONTRACT ==========\n'

printf '\n=== Active Ollama adapter ===\n'
nl -ba scripts/utils/ollamaChat.ts | sed -n '1,220p'

printf '\n====================================================\n'

printf '\n=== Active workflow consumer ===\n'
nl -ba server/matilda-chat-workflow.ts | sed -n '95,210p'

printf '\n====================================================\n'

printf '\n=== Active route consumer ===\n'
nl -ba routes/matilda.ts | sed -n '1,120p'

printf '\n====================================================\n'

printf '\n=== Direct imports of ollamaChat ===\n'
grep -RIn \
  --exclude='*.test.ts' \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=_PRE_RESTORE_BROKEN_STATE \
  --exclude-dir=routes_backup \
  --exclude-dir=scripts_backup \
  --exclude-dir=scripts_backup_2 \
  --exclude-dir=snapshots \
  'from.*ollamaChat' \
  .

printf '\n====================================================\n'

printf '\nImplementation corridor candidate:\n'
printf '  • Change ollamaChat() to return a typed object.\n'
printf '  • Preserve one model invocation.\n'
printf '  • Preserve current reply behavior.\n'
printf '  • Initially map durable_interpretation = reply.\n'
printf '  • Update only active production consumers.\n'

printf '\n=== Repository status ===\n'
git status --short
