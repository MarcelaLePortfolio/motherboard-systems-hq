#!/usr/bin/env bash
set -euo pipefail

echo "== repo root =="
pwd
echo

echo "== before cleanup =="
git status --short
echo

rm -f "./...."

if git ls-files --error-unmatch "scripts/_local/phase64_4_rebuild_after_restore.sh" >/dev/null 2>&1; then
  echo "tracked helper retained: scripts/_local/phase64_4_rebuild_after_restore.sh"
else
  rm -f "scripts/_local/phase64_4_rebuild_after_restore.sh"
  echo "removed untracked helper: scripts/_local/phase64_4_rebuild_after_restore.sh"
fi

echo
echo "== after cleanup =="
git status --short
