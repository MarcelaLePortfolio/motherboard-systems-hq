#!/usr/bin/env bash
set -euo pipefail

REPORT="docs/phase702-true-matilda-chat-search.md"

{
  echo "# Phase 702 True Matilda Chat Search"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Search: route files"
  echo
  echo '```'
  find app -path '*api*' -type f | sort
  echo '```'
  echo
  echo "## Search: chat-specific references"
  echo
  echo '```'
  grep -RInE "/api/chat|api/chat|fetch\\(['\\\"]/.+chat|Matilda|matilda|chat endpoint|Chat" app components pages src server 2>/dev/null || true
  echo '```'
  echo
  echo "## Git Status"
  echo
  echo '```'
  git status --short
  echo '```'
} > "$REPORT"

git add PHASE702_STEP2F_FIND_TRUE_MATILDA_CHAT.sh "$REPORT"
git commit -m "Phase 702: search for true Matilda chat surface"
git push

git status --short
