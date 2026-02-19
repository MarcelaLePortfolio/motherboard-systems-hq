#!/usr/bin/env bash
set -euo pipefail

# Phase 42 Read-Only Guard (DIFF-BASED)
#
# Why diff-based?
# The repo already contains legacy write paths. Phase 42 must ensure it does not
# INTRODUCE new write paths unless explicitly promoted.
#
# This guard fails ONLY if the diff from BASE_REF introduces obvious write-route
# keywords (best-effort heuristic).
#
# Usage:
#   BASE_REF=v41.0-decision-correctness-gate-green ./scripts/phase42_readonly_guard.sh
#   ./scripts/phase42_readonly_guard.sh   # uses default BASE_REF below

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

BASE_REF="${BASE_REF:-v41.0-decision-correctness-gate-green}"

if ! git rev-parse -q --verify "$BASE_REF^{commit}" >/dev/null; then
  echo "ERROR: BASE_REF not found as a commit/tag: $BASE_REF" >&2
  exit 2
fi

echo "=== Phase 42 read-only guard (diff-based) ==="
echo "BASE_REF=$BASE_REF"
echo "HEAD=$(git rev-parse --short HEAD)"

# Only inspect files changed in this phase.
CHANGED="$(git diff --name-only "$BASE_REF"..HEAD || true)"
if [[ -z "${CHANGED//$'\n'/}" ]]; then
  echo "OK: no changes vs BASE_REF"
  exit 0
fi

# Filter to likely code/config areas (ignore pure docs unless they contain route code).
# Still safe: we run the grep over the diff itself, not whole files.
echo
echo "Changed files:"
echo "$CHANGED" | sed 's/^/ - /'

echo
echo "Scanning DIFF for new write-route keywords..."
if git diff "$BASE_REF"..HEAD \
  | rg -n "(\\bPOST\\b|\\bPUT\\b|\\bPATCH\\b|\\bDELETE\\b|app\\.(post|put|patch|delete)\\b|router\\.(post|put|patch|delete)\\b|\\.post\\(|\\.put\\(|\\.patch\\(|\\.delete\\()" >/dev/null
then
  echo "ERROR: Potential write-route keywords detected in Phase 42 DIFF." >&2
  echo "       If this is intentional, stop and promote via an explicit promotion phase." >&2
  echo
  git diff "$BASE_REF"..HEAD \
    | rg -n "(\\bPOST\\b|\\bPUT\\b|\\bPATCH\\b|\\bDELETE\\b|app\\.(post|put|patch|delete)\\b|router\\.(post|put|patch|delete)\\b|\\.post\\(|\\.put\\(|\\.patch\\(|\\.delete\\()" || true
  exit 2
fi

echo "OK: no write-route keywords introduced in diff (best-effort)."
