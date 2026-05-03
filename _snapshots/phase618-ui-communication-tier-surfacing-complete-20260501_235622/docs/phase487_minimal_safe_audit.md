# Phase 487 — Minimal Safe Audit

## Classification
SAFE — Read-only, bounded output

## Purpose
Inspect ONLY what we need, without triggering large output.

## Commands

echo "=== systemHealthSituationSummary (first 80 lines) ==="
sed -n '1,80p' routes/diagnostics/systemHealthSituationSummary.ts

echo
echo "=== systemHealth route usage (top 20 matches) ==="
grep -RIn "systemHealth" . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  | head -20 || true

## Status
READY — Safe and bounded
