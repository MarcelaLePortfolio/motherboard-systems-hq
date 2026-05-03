#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase457_verify_controlled_proof.txt"

{
  echo "PHASE 457 — VERIFY CONTROLLED PROOF EXECUTION"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== JS PROOF FILE CHECK ==="
  grep -n "PHASE457_PROOF_EXECUTED" public/js/phase457_controlled_proof.js || true
  echo

  echo "=== DASHBOARD HTML HOOK CHECK ==="
  curl -fsS http://localhost:8080/dashboard.html | grep -n "operator-guidance" || true
  echo

  echo "=== EXPECTED UI STATE ==="
  echo "Open: http://localhost:8080/dashboard.html"
  echo
  echo "You should see EXACTLY:"
  echo "SYSTEM_HEALTH • INFO • HIGH"
  echo "Controlled execution path verified."
  echo "Deterministic guidance pipeline executed successfully."
  echo
  echo "Meta:"
  echo "Source: phase457-proof • Confidence: high • Mode: deterministic-proof"
  echo

  echo "=== DETERMINISM CHECK ==="
  echo "1. Refresh page multiple times"
  echo "2. Output MUST remain identical"
  echo "3. No flicker, no repeated updates"
  echo

  echo "=== FAILURE SIGNALS ==="
  echo "• Multiple renders"
  echo "• Text changing between refreshes"
  echo "• Streaming / flickering"
  echo "• Console errors"
  echo

} | tee "$OUT"
