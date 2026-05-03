#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/recovery_full_audit/33_actual_layout_divergence_scan.txt"
mkdir -p docs/recovery_full_audit

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

scan_file_history() {
  local file="$1"
  local label="$2"

  echo "===== ${label}: ${file} ====="

  git log --oneline --decorate -- "$file" | while read -r sha rest; do
    [ -n "${sha:-}" ] || continue

    target="$TMP_DIR/${sha}_$(basename "$file" | tr '/' '_')"
    if ! git show "${sha}:${file}" > "$target" 2>/dev/null; then
      continue
    fi

    hash="$(shasum -a 256 "$target" | awk '{print $1}')"
    size="$(wc -c < "$target" | tr -d ' ')"

    markers="$(
      grep -Eo 'Operator Console|Matilda Chat Console|Task Delegation|Recent Tasks|Task Activity Over Time|Agent Pool|Guidance|Atlas Subsystem Status|Probe lifecycle|System Reflections|Critical Ops Alerts|Operator Workspace|Observational Workspace' "$target" \
      | sort -u | tr '\n' ',' | sed 's/,$//'
    )"

    printf '%s | %s | bytes=%s | markers=%s | %s\n' \
      "$sha" "$hash" "$size" "${markers:-none}" "$rest"
  done

  echo
}

{
  echo "PHASE 457 - ACTUAL LAYOUT DIVERGENCE SCAN"
  echo "========================================="
  echo
  echo "PURPOSE"
  echo "Find the real dashboard shell divergence point, not just later JS wiring divergence."
  echo
  echo "KNOWN PROOF"
  echo "- phase65_layout and phase65_wiring serve identical live HTML + identical live bundle.js"
  echo "- operator_guidance serves a different live bundle.js but the same live HTML shell"
  echo "- therefore the remembered layout is likely at another checkpoint where dashboard shell files changed"
  echo

  scan_file_history "public/index.html" "INDEX HISTORY"
  scan_file_history "public/dashboard.html" "DASHBOARD HISTORY"

  echo "===== COMMITS THAT TOUCHED DASHBOARD SHELL FILES ====="
  git log --oneline --decorate -- \
    public/index.html \
    public/dashboard.html \
    public/css \
    public/js/dashboard-bundle-entry.js
  echo

  echo "===== HIGH-SIGNAL CANDIDATES (shell-oriented keywords) ====="
  git log --oneline --decorate --all -- \
    public/index.html \
    public/dashboard.html \
    public/css \
    public/js/dashboard-bundle-entry.js \
  | grep -Ei 'phase 58|phase 59|phase 60|phase 61|phase 62|phase 63|phase 64|phase 65|phase 88|phase 90|phase 96|workspace|layout|operator console|guidance|restore|dashboard html|shell|atlas|tabs' || true
  echo

  echo "DETERMINISTIC NEXT STEP"
  echo "Pick the first commit where the HASH or MARKERS for public/index.html or public/dashboard.html actually diverge toward the remembered shell."
  echo "That commit is the real visual recovery candidate."
} > "$OUT"

sed -n '1,320p' "$OUT"
