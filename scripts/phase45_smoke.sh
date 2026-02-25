#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true
setopt INTERACTIVE_COMMENTS 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

# Choose an action_id that the default policy denies by default, but our grant will allow.
export PHASE45_ACTION_ID="${PHASE45_ACTION_ID:-repo.write.phase45_proof}"

# Deterministic dev grant used ONLY for the Phase 45 proof harness.
export MB_GRANTS_JSON='{
  "grants": [
    {
      "id": "grant.phase45.proof",
      "allow_actions": ["repo.write."],
      "expires_at": "2099-01-01T00:00:00Z",
      "single_use": false,
      "notes": "Phase45 deterministic flip proof grant."
    }
  ]
}'

echo "=== Phase 45: prove deterministic decision flip (deterministic fixture + grant) ==="
node scripts/phase45_prove_deterministic_decision_flip.mjs
