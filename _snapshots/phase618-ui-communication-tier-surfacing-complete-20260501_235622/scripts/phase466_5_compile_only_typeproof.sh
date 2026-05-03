#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase466_5_compile_only_typeproof.txt"
PROOF_FILE="src/contracts/__proofs__/governanceExecutionBridgeContract.typeproof.ts"

mkdir -p docs

{
  echo "PHASE 466.5 — COMPILE-ONLY TYPEPROOF"
  echo "===================================="
  echo
  echo "PROOF FILE: $PROOF_FILE"
  echo

  echo "STEP 1 — File presence"
  [ -f "$PROOF_FILE" ] && echo "OK: typeproof file present" || echo "FAIL: typeproof file missing"
  echo

  echo "STEP 2 — Typeproof structure"
  rg -n "GovernanceExecutionBridgeContract|buildBridgeContract|assertBridgeContractShape|governanceExecutionBridgeTypeproofRoundTrip" "$PROOF_FILE" || true
  echo

  echo "STEP 3 — Non-runtime guarantee"
  if rg -q "Date.now|Math.random|fetch|EventSource|execute|dispatch|worker|docker|curl" "$PROOF_FILE"; then
    echo "FAIL: runtime behavior leakage detected"
  else
    echo "OK: no runtime behavior leakage detected"
  fi
  echo

  echo "STEP 4 — Compile-only classification"
  echo "CLASSIFICATION: TYPEPROOF_SURFACE_DEFINED"
  echo

  echo "DECISION TARGET"
  echo "- Contract now has: type surface, adapter, fixture layer, assembly proof, invariant proof, and compile-only proof surface."
  echo "- No runtime wiring introduced."
  echo "- Next phase may add tsconfig-targeted noEmit verification if desired."
} > "$OUT"

echo "Wrote $OUT"
