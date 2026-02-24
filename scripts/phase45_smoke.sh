#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true
setopt INTERACTIVE_COMMENTS 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

echo "=== Phase 45: prove deterministic decision flip (best-effort) ==="
node scripts/phase45_prove_deterministic_decision_flip.mjs
