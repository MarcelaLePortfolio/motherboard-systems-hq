#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

OUT="docs/recovery_full_audit/38_live_shell_candidate_urls_and_markers.txt"

{
  echo "PHASE 457 - LIVE SHELL CANDIDATE URLS AND MARKERS"
  echo "================================================="
  echo
  echo "DETERMINISTIC STATUS"
  echo "The shell candidates are now bootable on isolated ports after removing inherited base 8080 bindings."
  echo
  for pair in \
    "33f5c0e2|8101" \
    "c63a60e7|8102" \
    "ecac1fb1|8103" \
    "27b7ddf3|8104" \
    "244cdde5|8105"
  do
    SHA="${pair%%|*}"
    PORT="${pair##*|}"

    echo "===== ${SHA} ====="
    echo "URL=http://localhost:${PORT}"
    echo

    echo "[http headers]"
    curl -I --max-time 10 "http://localhost:${PORT}" || true
    echo

    echo "[title]"
    curl -L --max-time 10 "http://localhost:${PORT}" 2>/dev/null | grep -o '<title>[^<]*</title>' | head -n 1 || true
    echo

    echo "[markers]"
    curl -L --max-time 10 "http://localhost:${PORT}" 2>/dev/null | \
      grep -Eo 'Operator Console|Guidance|Workspace|Atlas|Task Delegation|Agent Pool|Matilda Chat Console|Recent Tasks|Task Activity Over Time|Probe lifecycle|Critical Ops Alerts|System Reflections' | \
      sort -u || true
    echo
  done

  echo "NEXT SAFE ACTION"
  echo "Visually compare 8101-8105 and identify the first shell that matches the remembered layout."
  echo
  echo "KNOWN CANDIDATE MEANINGS"
  echo "8101 -> 33f5c0e2 -> Phase 60: restore live uptime polish script"
  echo "8102 -> c63a60e7 -> Phase 60: restore dashboard runtime scripts for agent pool rendering"
  echo "8103 -> ecac1fb1 -> Phase 59: compose operator console layout from stable baseline"
  echo "8104 -> 27b7ddf3 -> demo: trim dashboard layout to lifecycle/task panels"
  echo "8105 -> 244cdde5 -> diag: remove phase59 demo-focus stylesheet from static dashboard pages"
} > "$OUT"

open "http://localhost:8101" || true
open "http://localhost:8102" || true
open "http://localhost:8103" || true
open "http://localhost:8104" || true
open "http://localhost:8105" || true

sed -n '1,260p' "$OUT"
