#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_490_TRUE_HEIGHT_COMMIT_HUNT.txt"

{
  echo "PHASE 490 — TRUE HEIGHT PARITY COMMIT HUNT"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== STEP 1: FIND COMMITS THAT CLAIM HEIGHT SUCCESS ==="
  git log --oneline --decorate --all \
    --grep='match\|matched\|parity\|same height\|perfect\|aligned' -i -n 50
  echo

  echo "=== STEP 2: FIND COMMITS TOUCHING HEIGHT LOGIC FILES ==="
  git log --oneline --decorate --all -n 80 -- \
    public/js/phase489_panel_height_sync.js \
    public/js/phase490_measured_panel_height_sync.js \
    public/index.html
  echo

  echo "=== STEP 3: SEARCH FOR RUNTIME MOUNT (THE REAL CAUSE) ==="
  grep -RIn "phase489_panel_height_sync" public || true
  echo

  echo "=== STEP 4: CHECK IF HEIGHT SCRIPT EXISTS IN CURRENT STATE ==="
  if [[ -f public/js/phase489_panel_height_sync.js ]]; then
    echo "FOUND: phase489_panel_height_sync.js exists"
    echo "--- FILE HEAD ---"
    sed -n '1,120p' public/js/phase489_panel_height_sync.js
  else
    echo "MISSING: phase489_panel_height_sync.js (THIS IS LIKELY THE ISSUE)"
  fi
  echo

  echo "=== STEP 5: CHECK IF SCRIPT IS MOUNTED IN INDEX ==="
  grep -n "phase489_panel_height_sync.js" public/index.html || echo "NOT MOUNTED"
  echo

  echo "=== STEP 6: SHOW COMMIT THAT INTRODUCED HEIGHT SYNC ==="
  git show b89d5538 -- public/js/phase489_panel_height_sync.js || true
  echo

  echo "=== DETERMINATION ==="
  echo "If phase489_panel_height_sync.js exists but is NOT mounted:"
  echo "→ That is the missing piece."
  echo
  echo "If it is mounted but still not working:"
  echo "→ It was relying on DOM structure that has since changed."
  echo
  echo "If it does NOT exist:"
  echo "→ It was removed during Phase 490 cleanup and never restored."
  echo
  echo "This is NOT a CSS problem anymore."
  echo "This is a missing runtime measurement system."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,300p' "$OUT"
