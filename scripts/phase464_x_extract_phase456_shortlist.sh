#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs
SRC="docs/phase464_x_phase456_baseline_emitter_candidates.txt"
OUT="docs/phase464_x_phase456_shortlist.txt"

{
  echo "PHASE 464.X — PHASE456 SHORTLIST"
  echo "================================"
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo "Source: $SRC"
  echo

  echo "1) Top exact file hits (deduped)"
  grep '^FILE:' "$SRC" | sort -u | head -n 40 || true
  echo

  echo "2) File hit density"
  awk '
    /^FILE: / { file=$0; next }
    /^----- / { next }
    /^$/ { next }
    {
      if ($0 ~ /^[0-9]+:/) counts[file]++
    }
    END {
      for (f in counts) print counts[f] " | " f
    }
  ' "$SRC" | sort -nr | head -n 30 || true
  echo

  echo "3) Likely real browser targets only"
  grep '^FILE:' "$SRC" \
    | sed 's/^FILE: //' \
    | grep -Ev '^docs/|^scripts/|node_modules|\.git' \
    | grep -Ei 'public/|bundle|dashboard|guidance|operator|status|health|atlas|matilda|phase456|baseline' \
    | sort -u \
    | head -n 20 || true
  echo

  echo "4) High-signal literal matches"
  rg -n 'SYSTEM_HEALTH|No active tasks|Awaiting operator input|phase456|baseline emitter|Operator Guidance|operator guidance' "$SRC" | head -n 120 || true
  echo

  echo "5) Decision gate"
  echo "- Choose the highest-density non-doc, non-script browser file."
  echo "- Then extract only that file's exact matched snippets next."
} > "$OUT"

echo "Wrote $OUT"
