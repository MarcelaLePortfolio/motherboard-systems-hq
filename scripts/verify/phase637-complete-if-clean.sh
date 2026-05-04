#!/bin/bash
set -e

echo "PHASE 637 — CONDITIONAL COMPLETION"

echo "Run audit first:"
echo "bash scripts/verify/run-phase637-audit.sh"

echo ""
echo "If ALL checks pass with no warnings, then run:"
echo "git tag -a phase637-complete -m \"Phase 637 complete: active runtime wiring verified\""
echo "git push origin phase637-complete"

echo ""
echo "If ANY warnings appear:"
echo "- DO NOT tag"
echo "- Patch active server.js directly"
echo "- Re-run audit"

echo ""
echo "END"
