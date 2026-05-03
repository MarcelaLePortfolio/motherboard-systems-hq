#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_patch_ui_confidence_formatter_${STAMP}.txt"

TARGETS=(
  "dashboard/src"
  "app"
  "ui"
)

patched=()

for dir in "${TARGETS[@]}"; do
  [ -d "${dir}" ] || continue

  while IFS= read -r file; do
    [ -f "${file}" ] || continue

    original="$(cat "${file}")"
    updated="${original}"

    # Patch JSX/TSX render cases like:
    # Confidence: {something === "insufficient" ? "insufficient" : ...}
    updated="$(printf "%s" "${updated}" \
      | sed -E 's/([Cc]onfidence:[^"\n]*)(insufficient)/\1limited/g')"

    # Patch direct string render
    updated="$(printf "%s" "${updated}" \
      | sed -E 's/Confidence:[[:space:]]*insufficient/Confidence: limited/g')"

    # Patch enum display fallbacks
    updated="$(printf "%s" "${updated}" \
      | sed -E 's/(===|==)[[:space:]]*["'\'']insufficient["'\'']/\1 "limited"/g')"

    if [ "${updated}" != "${original}" ]; then
      printf "%s" "${updated}" > "${file}"
      patched+=("${file}")
    fi

  done < <(find "${dir}" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \))
done

if [ ${#patched[@]} -eq 0 ]; then
  echo "No UI formatter patches applied (safe no-op)."
else
  echo "patched_files=${patched[*]}"
fi

{
  echo "PHASE 487 — UI CONFIDENCE FORMATTER PATCH"
  echo "timestamp=${STAMP}"
  echo "patched_files=${patched[*]:-none}"
  echo

  echo "=== VERIFICATION ==="
  rg -n -C 2 "Confidence: insufficient" dashboard/src app ui 2>/dev/null || true
  echo

  echo "=== EXPECTATION ==="
  echo "UI must no longer render 'Confidence: insufficient'"
  echo "All display-layer fallbacks should now resolve to 'limited'"
  echo
} > "${OUT}"

echo "${OUT}"
