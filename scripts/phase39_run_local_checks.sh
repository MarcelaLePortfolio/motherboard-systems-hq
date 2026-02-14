#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true
setopt INTERACTIVE_COMMENTS 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

./scripts/phase32_null_max_attempts_claim_smoke.sh
./scripts/phase39_action_tier_claim_smoke.sh
