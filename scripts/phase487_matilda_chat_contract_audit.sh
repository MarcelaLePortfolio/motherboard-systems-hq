#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — MATILDA CHAT CONTRACT AUDIT"
echo "────────────────────────────────"

OUT="docs/phase487_matilda_chat_contract_audit.md"
mkdir -p docs

{
  echo "# Phase 487 Matilda Chat Contract Audit"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Live route checks"
  echo
  echo "- GET /api/chat -> $(curl -o /dev/null -s -w '%{http_code}' --max-time 5 http://localhost:8080/api/chat || true)"
  echo "- OPTIONS /api/chat -> $(curl -o /dev/null -s -w '%{http_code}' --max-time 5 -X OPTIONS http://localhost:8080/api/chat || true)"
  echo
  echo "## Source ownership scan"
  echo
  echo '```'
  rg -n '/api/chat|app\.(get|post|use)\("/api/chat"|fetch\("/api/chat"|placeholder /api/chat stub|matilda-chat' \
    server.mjs server public app scripts/_local \
    -g '!node_modules' \
    -g '!.next' \
    -g '!dist' \
    -g '!.runtime' || true
  echo '```'
  echo
  echo "## Current determination"
  echo
  echo "- The served UI references /api/chat."
  echo "- Live runtime currently returns 404 for /api/chat."
  echo "- This indicates a real UI/backend contract gap for Matilda chat."
  echo "- /api/delegate-task is POST-owned in server.mjs, so delegation is not the primary missing route."
  echo "- Next safe corridor should be source-level restoration of the /api/chat route only, without touching governance/approval/execution paths."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"
