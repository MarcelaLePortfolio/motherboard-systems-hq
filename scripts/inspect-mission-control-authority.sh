#!/usr/bin/env bash
set -euo pipefail

printf '\n=== MISSION CONTROL PRESENTATION ===\n'
sed -n '1,260p' client/src/shell/MissionDashboardWorkspace.tsx

printf '\n=== CLIENT CONTRACTS ===\n'
grep -RInE \
'Mission|mission|packageId|package_id|envelope|lifecycle|status|nextStep|blocker|approval|executive|agent|department' \
client/src \
--exclude='*.css' \
--exclude-dir='dist' || true

printf '\n=== BACKEND CONTRACTS ===\n'
grep -RInE \
'Mission|mission|package_id|envelope|lifecycle|status|next_step|blocker|approval|executive|agent|department' \
routes server db \
--exclude-dir='node_modules' || true

printf '\n=== REVIEW QUESTIONS ===\n'
printf '%s\n' \
'For every value currently displayed:' \
'- Is it authoritative backend truth?' \
'- Is it inspection metadata?' \
'- Is it inferred by the UI?' \
'- If inferred, should it disappear until the backend provides it?'
