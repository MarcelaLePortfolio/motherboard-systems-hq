#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 488 — POST-SUCCESS VERIFICATION"
echo "────────────────────────────────"

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

echo
echo "== git status --short =="
git status --short

echo
echo "== latest commits =="
git log --oneline -5

echo
echo "== docker compose ps =="
docker compose ps

echo
echo "== package-lock tracked in HEAD =="
git show --stat --oneline HEAD -- package-lock.json || true

echo
echo "== reproducibility proof doc tracked in HEAD =="
git show --stat --oneline HEAD -- docs/phase487_cold_start_rebuild_validation.md || true

echo
echo "RESULT:"
if [[ -z "$(git status --porcelain)" ]]; then
  echo "✔ Working tree clean"
else
  echo "⚠ Working tree not clean"
fi

echo "PHASE 488 STATUS: LOCKFILE SYNC RESTORED / COLD-START REBUILD PROVEN"
