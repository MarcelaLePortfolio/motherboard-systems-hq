#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs
SRC="docs/phase464_x_bundle_source_candidates.txt"
OUT="docs/phase464_x_bundle_candidate_hit_summary.txt"

{
  echo "PHASE 464.X — BUNDLE CANDIDATE HIT SUMMARY"
  echo "=========================================="
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo "Source: $SRC"
  echo

  echo "1) File sections present in source artifact"
  grep '^FILE:' "$SRC" || true
  echo

  echo "2) Per-file non-empty rg hit lines"
  awk '
    /^FILE: / { file=$0; next }
    /^----------------------------------------$/ { next }
    /^----- / { next }
    /^$/ { next }
    {
      if ($0 ~ /^[0-9]+:/) {
        counts[file]++
      }
    }
    END {
      for (f in counts) {
        print counts[f] " | " f
      }
    }
  ' "$SRC" | sort -nr || true
  echo

  echo "3) Files with ZERO direct hit lines"
  awk '
    /^FILE: / {
      if (seen_file && hit_count == 0) print prev_file
      prev_file=$0
      seen_file=1
      hit_count=0
      next
    }
    /^----------------------------------------$/ { next }
    /^----- / { next }
    /^$/ { next }
    {
      if ($0 ~ /^[0-9]+:/) hit_count++
    }
    END {
      if (seen_file && hit_count == 0) print prev_file
    }
  ' "$SRC" || true
  echo

  echo "4) Top 120 lines of source artifact for manual review"
  sed -n '1,120p' "$SRC"
  echo

  echo "5) Decision gate"
  echo "- If only dashboard-status.js shows dense hits, that is the next single-file mutation target."
  echo "- If operatorGuidance.sse.js shows only minimal overwrite logic, it is not the remaining producer."
  echo "- If all files show zero direct hits, expand candidate set from actual loaded bundle source map names."
} > "$OUT"

echo "Wrote $OUT"
