#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/DASHBOARD_LAYOUT_TARGET_RECOVERY.txt"

TOP_DOC="$ROOT/docs/PHASE_487_STEP1_TOP_RENDER_CANDIDATE.txt"
SNAP_DOC="$ROOT/docs/PHASE_487_STEP1_MUTATION_BOUNDARY_SNAPSHOT.txt"
DISCOVERY_DOC="$ROOT/docs/DASHBOARD_LAYOUT_FILE_DISCOVERY.txt"

TARGET_FILE=""

if [[ -f "$TOP_DOC" ]]; then
  TARGET_FILE="$(awk -F': ' '/^Selected File: / {print $2; exit}' "$TOP_DOC" || true)"
fi

if [[ -z "${TARGET_FILE:-}" && -f "$SNAP_DOC" ]]; then
  TARGET_FILE="$(awk -F': ' '/^Selected File: / {print $2; exit}' "$SNAP_DOC" || true)"
fi

{
  echo "DASHBOARD LAYOUT TARGET RECOVERY"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo
  echo "TARGET_FILE=$TARGET_FILE"
  echo

  echo "=== PROOF DOC REFERENCES ==="
  for f in "$TOP_DOC" "$SNAP_DOC" "$DISCOVERY_DOC"; do
    if [[ -f "$f" ]]; then
      echo "--- $f ---"
      sed -n '1,80p' "$f"
      echo
    fi
  done

  echo "=== TARGET FILE CONTENT (FIRST 360 LINES) ==="
  if [[ -n "${TARGET_FILE:-}" && -f "$TARGET_FILE" ]]; then
    sed -n '1,360p' "$TARGET_FILE"
  else
    echo "NO TARGET FILE RESOLVED FROM PROOFS"
  fi
  echo

  echo "=== TARGET FILE GIT HISTORY ==="
  if [[ -n "${TARGET_FILE:-}" && -f "$TARGET_FILE" ]]; then
    git log --oneline -- "$TARGET_FILE" | head -n 80
  else
    echo "NO TARGET FILE FOR HISTORY"
  fi
  echo

  echo "=== TARGET FILE PATCH HISTORY (FIRST 500 LINES) ==="
  if [[ -n "${TARGET_FILE:-}" && -f "$TARGET_FILE" ]]; then
    git log -p -- "$TARGET_FILE" | sed -n '1,500p'
  else
    echo "NO TARGET FILE FOR PATCH HISTORY"
  fi
  echo

  echo "=== GLOBAL STRING SEARCH ACROSS REPO ==="
  grep -RInE 'Matilda|Delegation|Operator Workspace|Telemetry|Recent Tasks|Task Activity|Task History|Subsystem Status|Agent Pool|Active Agents|Tasks Running|Success Rate|Latency|Operator Console|Operator Tools|Activity Panels' \
    "$ROOT" \
    --include='*.tsx' --include='*.ts' --include='*.jsx' --include='*.js' --include='*.md' --include='*.txt' \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build \
    2>/dev/null | sort || true
  echo

  echo "=== NEXT ACTION ==="
  echo "1. Identify the commit in TARGET FILE history where the split layout still exists."
  echo "2. Restore ONLY that file from that commit with: git checkout <GOOD_COMMIT> -- <TARGET_FILE>"
  echo "3. Review diff."
  echo "4. Commit and push."
} | tee "$OUT"
