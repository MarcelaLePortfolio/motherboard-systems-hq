#!/usr/bin/env bash
set -euo pipefail

echo "Committing remaining script and applying demo UI clarity label..."

git add PHASE702_STEP2H_CONFIRM_NO_CHAT_AND_CLEAN.sh
git commit -m "Phase 702: add cleanup confirmation script"
git push

# Add a visible UI-only label at top of demo runtime page
TARGET="app/demo-runtime/page.tsx"

if ! grep -q "DEMO_RUNTIME_NOTICE" "$TARGET"; then
  awk 'NR==1{print "// DEMO_RUNTIME_NOTICE: This surface is a governed demo runner, not a live execution or chat system."}1' "$TARGET" > tmp && mv tmp "$TARGET"
fi

git add "$TARGET"
git commit -m "Phase 702: label demo runtime UI as non-chat, demo-only surface"
git push

git status --short
