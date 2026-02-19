#!/usr/bin/env bash
set -euo pipefail

# Guardrail: fail if new obvious write routes are added (best-effort, repo-agnostic).
# This is intentionally conservative and should be extended as Phase 42 work begins.

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# Scan common server route folders for obvious HTTP write verbs.
# Adjust paths as your repo evolves.
PATHS=(
  "server"
  "app"
  "src"
)

found=0
for p in "${PATHS[@]}"; do
  [[ -d "$p" ]] || continue
  if rg -n --hidden --no-ignore -S \
    "(\\bPOST\\b|\\bPUT\\b|\\bPATCH\\b|\\bDELETE\\b|app\\.(post|put|patch|delete)\\b|router\\.(post|put|patch|delete)\\b)" \
    "$p" >/dev/null; then
    echo "ERROR: Potential write-path keywords detected under: $p"
    echo "       Review matches and ensure Phase 42 remains read-only (unless explicitly promoted)."
    rg -n --hidden --no-ignore -S \
      "(\\bPOST\\b|\\bPUT\\b|\\bPATCH\\b|\\bDELETE\\b|app\\.(post|put|patch|delete)\\b|router\\.(post|put|patch|delete)\\b)" \
      "$p" || true
    found=1
  fi
done

if [[ "$found" -ne 0 ]]; then
  exit 2
fi

echo "OK: no obvious write-path keywords detected (best-effort guard)."
