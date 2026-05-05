#!/usr/bin/env bash
set -euo pipefail

TARGET="app"

echo "Patching UI to label Matilda chat as stub (read-only UI change)..."

grep -RIl "Matilda" "$TARGET" | while read -r file; do
  if ! grep -q "STUBBED_CHAT_LABEL" "$file"; then
    sed -i '' '1s/^/\/\/ STUBBED_CHAT_LABEL: Matilda chat is currently stubbed (no real execution pipeline)\n/' "$file" || true
  fi
done

git add -A
git commit -m "Phase 702: label Matilda chat as stub in UI (no backend changes)"
git push

git status --short
