#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "PHASE 79 — CHANGE IMPACT PREVIEW"
echo "--------------------------------"

echo "IMPACT CHECK — CHANGED FILES"
git status --short || true

echo ""
echo "IMPACT CHECK — DIFF SUMMARY"
git diff --stat || true

echo ""
echo "IMPACT CHECK — PROTECTED AREAS"
git diff --name-only | grep -E "(dashboard|reducers|telemetry|contracts)" || echo "no_protected_files_changed"

echo ""
echo "IMPACT CHECK — CHECKPOINT DELTA"
LAST_CHECKPOINT=$(ls -1t docs/checkpoints | head -n 1 || true)
echo "last_checkpoint=$LAST_CHECKPOINT"

echo ""
echo "CHANGE IMPACT RESULT: REVIEW BEFORE COMMIT"
