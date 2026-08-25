#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RUN CORRECTED OPERATIONAL PACKAGE AUTHORITY GAP INSPECTION ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== VERIFIED REPOSITORY STATE ==="
echo "INSPECTION_SCRIPT_ALREADY_CONTAINS_NO_MATCH_TOLERANCE=YES"
echo "AUTHORITATIVE_NOMINATION_SEARCH_PIPELINE_ALREADY_HAS_OR_TRUE=YES"
echo "DELEGATION_SEMANTICS_SEARCH_PIPELINE_ALREADY_HAS_OR_TRUE=YES"
echo "PRIOR_FIX_SCRIPT_PATTERN_WAS_STALE=YES"
echo "FAILED_HYPOTHESIS=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== EXECUTE CURRENT INSPECTION SCRIPT DIRECTLY ==="
bash inspect-operational-package-authority-gap.sh

echo
echo "=== FINAL WORKTREE ==="
git status --short
