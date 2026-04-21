#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 488 — DIRTY TREE REVIEW"
echo "────────────────────────────────"

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

echo
echo "== git status --short =="
git status --short

echo
echo "== tracked diff: docs/phase487_diagnostics_surface_live_probe_output.txt =="
if [[ -f docs/phase487_diagnostics_surface_live_probe_output.txt ]]; then
  git diff -- docs/phase487_diagnostics_surface_live_probe_output.txt || true
else
  echo "(file not present)"
fi

echo
echo "== untracked script previews =="
for f in \
  scripts/phase487_cold_start_rebuild_validation.sh \
  scripts/phase487_docker_desktop_controlled_restart.sh
do
  echo
  echo "--- $f ---"
  if [[ -f "$f" ]]; then
    sed -n '1,220p' "$f"
  else
    echo "(missing)"
  fi
done

echo
echo "== .runtime sample =="
find .runtime -maxdepth 2 -type f | sort | sed -n '1,40p' || true

echo
echo "== recommendation gate =="
echo "Do not clean or commit anything yet."
echo "Use this review output to classify:"
echo "1. tracked doc => keep or revert"
echo "2. phase487 scripts => keep or remove"
echo "3. .runtime => gitignore only, not commit"
