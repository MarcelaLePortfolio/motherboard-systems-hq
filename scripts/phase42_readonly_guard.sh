#!/usr/bin/env bash
set -euo pipefail

# Phase 42 Read-Only Guard (DIFF-BASED, CODE-ONLY)
#
# The repo already contains legacy write paths. Phase 42 must ensure it does not
# INTRODUCE new write paths unless explicitly promoted.
#
# This guard fails ONLY if the diff from BASE_REF introduces obvious write-route
# keywords in CODE-ish files (best-effort heuristic).
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

echo "=== Phase 42 read-only guard (diff-based, code-only) ==="
echo "BASE_REF=$BASE_REF"
echo "HEAD=$(git rev-parse --short HEAD)"

CHANGED_ALL="$(git diff --name-only "$BASE_REF"..HEAD || true)"
if [[ -z "${CHANGED_ALL//$'\n'/}" ]]; then
  echo "OK: no changes vs BASE_REF"
  exit 0
fi

# Skip docs + this guard itself (it contains the regex keywords intentionally).
CODE_CHANGED="$(echo "$CHANGED_ALL" | rg -v '(^|/)(README|CHANGELOG)\.md$' | rg -v '\.md$' | rg -v '^scripts/phase42_readonly_guard\.sh$' || true)"

echo
echo "Changed files (all):"
echo "$CHANGED_ALL" | sed 's/^/ - /'

if [[ -z "${CODE_CHANGED//$'\n'/}" ]]; then
  echo
  echo "OK: no code-ish files changed (only docs and/or the guard script)."
  exit 0
fi

echo
echo "Changed files (code-ish scanned):"
echo "$CODE_CHANGED" | sed 's/^/ - /'

echo
echo "Scanning DIFF for new write-route keywords (code-ish files only)..."

# Build args for git diff pathspecs safely (newline-delimited list).
# shellcheck disable=SC2206
PATHS=( $CODE_CHANGED )

if git diff "$BASE_REF"..HEAD -- "${PATHS[@]}" \
  | rg -n "(\\bPOST\\b|\\bPUT\\b|\\bPATCH\\b|\\bDELETE\\b|app\\.(post|put|patch|delete)\\b|router\\.(post|put|patch|delete)\\b|\\.post\\(|\\.put\\(|\\.patch\\(|\\.delete\\()" >/dev/null
then
  echo "ERROR: Potential write-route keywords detected in Phase 42 CODE diff." >&2
  echo "       If this is intentional, stop and promote via an explicit promotion phase." >&2
  echo
  git diff "$BASE_REF"..HEAD -- "${PATHS[@]}" \
    | rg -n "(\\bPOST\\b|\\bPUT\\b|\\bPATCH\\b|\\bDELETE\\b|app\\.(post|put|patch|delete)\\b|router\\.(post|put|patch|delete)\\b|\\.post\\(|\\.put\\(|\\.patch\\(|\\.delete\\()" || true
  exit 2
fi

echo "OK: no write-route keywords introduced in code diff (best-effort)."
