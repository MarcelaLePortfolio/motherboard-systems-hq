#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="896fc5215"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n===== CLOSURE ARTIFACT =====\n'
test -f handoffs/ATLAS_REACT_PRESENTATION_CORRIDOR_CLOSURE_20260916.md
grep -n 'ATLAS_REACT_PRESENTATION_CORRIDOR=CLOSED' \
  handoffs/ATLAS_REACT_PRESENTATION_CORRIDOR_CLOSURE_20260916.md

printf '\n===== IMPLEMENTATION LINEAGE =====\n'
git log --oneline --decorate -7

printf '\n===== BRANCH CONVERGENCE =====\n'
printf 'HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'UPSTREAM=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

printf '\n===== FINAL CORRIDOR STATE =====\n'
echo "ATLAS_REACT_PRESENTATION_CORRIDOR=CLOSED"
echo "NEXT_ATLAS_CORRIDOR=UNCLASSIFIED"
echo "NEXT_ATLAS_CORRIDOR_AUTHORIZED=NO"
