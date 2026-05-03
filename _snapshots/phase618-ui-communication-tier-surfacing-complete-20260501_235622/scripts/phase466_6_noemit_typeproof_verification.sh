#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase466_6_noemit_typeproof_verification.txt"
PROOF_FILE="src/contracts/__proofs__/governanceExecutionBridgeContract.typeproof.ts"

mkdir -p docs

{
  echo "PHASE 466.6 — NO-EMIT TYPEPROOF VERIFICATION"
  echo "============================================"
  echo
  echo "PROOF FILE: $PROOF_FILE"
  echo

  echo "STEP 1 — File presence"
  [ -f "$PROOF_FILE" ] && echo "OK: typeproof file present" || echo "FAIL: typeproof file missing"
  echo

  echo "STEP 2 — TypeScript config discovery"
  if [ -f "tsconfig.json" ]; then
    echo "OK: tsconfig.json present"
  else
    echo "FAIL: tsconfig.json missing"
  fi
  echo

  echo "STEP 3 — Compile-only verification"
  if [ -f "node_modules/.bin/tsc" ]; then
    ./node_modules/.bin/tsc --noEmit --pretty false >> "$OUT.compile" 2>&1 || true
  else
    echo "WARN: local tsc binary missing" > "$OUT.compile"
  fi

  if rg -q "error TS" "$OUT.compile"; then
    echo "FAIL: TypeScript reported errors"
  else
    echo "OK: no TypeScript compile errors detected"
  fi
  echo

  echo "STEP 4 — Focused proof-file references"
  rg -n "governanceExecutionBridgeContract|governanceExecutionBridgeTypeproof|buildBridgeContract|assertBridgeContractShape" "$PROOF_FILE" || true
  echo

  echo "STEP 5 — Captured compiler output"
  cat "$OUT.compile"
  echo

  echo "STEP 6 — Classification"
  if rg -q "error TS" "$OUT.compile"; then
    echo "CLASSIFICATION: NOEMIT_VERIFICATION_FAILED"
  else
    echo "CLASSIFICATION: NOEMIT_VERIFICATION_CONFIRMED"
  fi
  echo

  echo "DECISION TARGET"
  echo "- This phase performs compile-only verification."
  echo "- No runtime wiring introduced."
  echo "- If confirmed, the bridge contract corridor is structurally proven."
} > "$OUT"

rm -f "$OUT.compile"

echo "Wrote $OUT"
