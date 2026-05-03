#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 488 — PREFLIGHT DIRTY TREE REPORT"
echo "────────────────────────────────"

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

tracked="$(git diff --name-only)"
untracked="$(git ls-files --others --exclude-standard)"

if [[ -z "$tracked" && -z "$untracked" ]]; then
  echo "✔ Working tree is clean"
  exit 0
fi

echo "STATUS: DIRTY"
echo

echo "TRACKED MODIFICATIONS:"
if [[ -n "$tracked" ]]; then
  printf '%s\n' "$tracked"
else
  echo "(none)"
fi

echo
echo "UNTRACKED FILES:"
if [[ -n "$untracked" ]]; then
  printf '%s\n' "$untracked"
else
  echo "(none)"
fi

echo
echo "RECOMMENDED SAFE NEXT STEP:"
echo "1. Review whether docs/phase487_diagnostics_surface_live_probe_output.txt should be committed or reverted"
echo "2. Review whether .runtime/ should be gitignored"
echo "3. Review whether the two phase487 scripts should be committed or removed"
echo "4. Do NOT run lockfile repair until git status is clean"
