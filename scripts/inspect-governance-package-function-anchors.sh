#!/usr/bin/env bash
set -euo pipefail

printf '\n=== GOVERNANCE PACKAGE TYPE CONTRACT ===\n'
sed -n '1,90p' db/governance-runtime.ts

printf '\n=== GOVERNANCE PACKAGE TABLE INITIALIZATION ===\n'
sed -n '190,270p' db/governance-runtime.ts

printf '\n=== GOVERNANCE PACKAGE FUNCTION LOCATION ===\n'
rg -n \
  'export function createGovernancePackage|package_version|requirePositive|INSERT INTO governance_packages' \
  db/governance-runtime.ts

printf '\n=== GOVERNANCE PACKAGE FUNCTION ===\n'
START_LINE="$(
  rg -n 'export function createGovernancePackage' db/governance-runtime.ts \
    | head -1 \
    | cut -d: -f1
)"

if [ -z "$START_LINE" ]; then
  printf 'STOP: createGovernancePackage function was not found.\n'
  exit 1
fi

END_LINE=$((START_LINE + 170))
sed -n "${START_LINE},${END_LINE}p" db/governance-runtime.ts

printf '\n=== FAILED EDIT SCRIPT ===\n'
sed -n '1,220p' scripts/implement-governance-package-identity-bridge.py

printf '\n=== VERIFY NO PARTIAL TRACKED EDITS ===\n'
git diff --check
git diff --name-only
git status --short

printf '\n=== CURRENT CHECKPOINT ===\n'
git branch --show-current
git log -1 --oneline
