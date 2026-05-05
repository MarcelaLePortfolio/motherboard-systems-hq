#!/usr/bin/env bash
set -euo pipefail

REPORT="docs/phase702-matilda-chat-verification.md"

{
  echo "# Phase 702 Matilda Chat Verification"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Finding"
  echo
  echo "The inspected surface \`app/demo-runtime/page.tsx\` is not a Matilda chat interface."
  echo "It is a governed runtime demo UI using an operator-request textarea and POSTing to \`/api/demo-runtime\`."
  echo
  echo "## Phase 702 Constraint"
  echo
  echo "Do not label this surface as Matilda chat."
  echo "Do not mutate backend/runtime behavior."
  echo "Only patch UI wording if the current labels imply real execution beyond demo behavior."
  echo
  echo "## Remaining Inspection Needed"
  echo
  echo "- Inspect the rest of \`app/demo-runtime/page.tsx\`."
  echo "- Inspect \`app/api/demo-runtime/route.ts\`."
  echo "- Continue searching for an actual Matilda chat UI or \`/api/chat\` route before applying any Matilda-specific UI label."
  echo
  echo "## app/demo-runtime/page.tsx remainder"
  echo
  echo '```tsx'
  sed -n '261,520p' app/demo-runtime/page.tsx || true
  echo '```'
  echo
  echo "## app/api/demo-runtime/route.ts"
  echo
  echo '```ts'
  sed -n '1,220p' app/api/demo-runtime/route.ts || true
  echo '```'
} > "$REPORT"

git add PHASE702_STEP2E_RECORD_CHAT_SURFACE_FINDING.sh "$REPORT"
git commit -m "Phase 702: record Matilda chat surface verification"
git push

git status --short
