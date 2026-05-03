#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — OPERATOR GUIDANCE RENDER CONTRACT AUDIT"
echo "────────────────────────────────"

OUT="docs/phase487_operator_guidance_render_contract_audit.md"
mkdir -p docs

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

{
  echo "# Phase 487 Operator Guidance Render Contract Audit"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Runtime posture"
  echo
  echo '```'
  git status --short
  echo
  docker compose ps
  echo '```'
  echo
  echo "## Guidance source references"
  echo
  echo '```'
  rg -n '/api/guidance|guidance_available|no_active_guidance_stream|situationSummary|diagnostics/system-health|Operator Guidance|guidance' \
    public server app scripts/_local \
    -g '!node_modules' \
    -g '!.next' \
    -g '!dist' \
    -g '!.runtime' \
    | sed -n '1,220p' || true
  echo '```'
  echo
  echo "## Served bundle guidance references"
  echo
  echo '```'
  rg -n '/api/guidance|guidance_available|no_active_guidance_stream|situationSummary|diagnostics/system-health' \
    public/bundle.js public/dashboard.html public/index.html \
    | sed -n '1,220p' || true
  echo '```'
  echo
  echo "## Likely diagnosis"
  echo
  echo "- /api/guidance is live but currently returns guidance_available=false."
  echo "- /diagnostics/system-health is live and returns a usable situationSummary."
  echo "- If the UI does not already fall back to situationSummary, the remaining issue is a UI render contract gap, not a missing backend route."
  echo "- Safe next patch corridor: render Operator Guidance from /api/guidance when available, otherwise fall back to /diagnostics/system-health.situationSummary."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
