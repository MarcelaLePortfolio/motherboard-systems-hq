#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true
setopt INTERACTIVE_COMMENTS 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

echo "=== Phase 45: Grant Determinism Smoke (node-based, no HTTP) ==="

# Use the Phase 45 proof harness as the source of truth. This avoids relying on any HTTP route
# that may or may not exist (POST /api/tasks is 404, and /api/policy/evaluate is not exposed).
#
# We prove determinism by running the proof twice under identical fixture inputs and comparing
# a normalized JSON signature of the result.

export PHASE45_ACTION_ID="${PHASE45_ACTION_ID:-repo.write.phase45_proof}"

# Deterministic fixture grant (same intent as scripts/phase45_smoke.sh).
# Only set if caller hasn't provided their own fixture already.
if [[ -z "${MB_GRANTS_JSON:-}" ]]; then
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
fi

PROVER="scripts/phase45_prove_deterministic_decision_flip.mjs"
[[ -f "$PROVER" ]] || { echo "FAIL: missing prover: $PROVER"; exit 2; }

normalize_json() {
  # Try to extract a JSON object from the last line and stable-sort it.
  # If the prover prints multiple lines, we only normalize the final JSON summary line.
  if command -v jq >/dev/null 2>&1; then
    tail -n 1 | jq -S -c .
  else
    tail -n 1
  fi
}

run_once() {
  # Run prover, capture normalized signature.
  node "$PROVER" | normalize_json
}

SIG1="$(run_once)"
SIG2="$(run_once)"

echo "sig1=$SIG1"
echo "sig2=$SIG2"

if [[ "$SIG1" != "$SIG2" ]]; then
  echo "FAIL: nondeterministic prover output under identical inputs"
  exit 1
fi

echo "OK: deterministic decision flip proof is stable."
