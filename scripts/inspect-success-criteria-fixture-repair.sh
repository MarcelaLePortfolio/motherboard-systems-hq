#!/usr/bin/env bash
set -euo pipefail

echo "===== CONTRACT TEST — ALL VALIDATOR INPUTS ====="
grep -n -B 8 -A 22 \
  -E 'validateMatildaPackageSemanticsArtifact\(' \
  scripts/utils/ollamaChat.package-semantics-contract.test.ts

echo
echo "===== OBSERVER TEST — MODEL RESPONSE FIXTURES ====="
grep -n -B 12 -A 35 \
  -E 'packageSemantics|expectedOutcome|proposedWork' \
  scripts/utils/ollamaChat.package-semantics-observer.test.ts

echo
echo "===== FIDELITY TEST — TYPED SEMANTICS FIXTURES ====="
grep -n -B 10 -A 30 \
  -E 'expectedOutcome|packageSemantics|userPackageSemantics' \
  scripts/utils/ollamaChat.package-semantics-fidelity.test.ts

echo
echo "===== CURRENT RUNTIME CONTRACT ====="
sed -n '175,215p' scripts/utils/ollamaChat.ts
sed -n '370,435p' scripts/utils/ollamaChat.ts

echo
echo "===== TYPECHECK ====="
npx tsc --noEmit

echo
echo "===== BASELINE / PRESERVED DRIFT ====="
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'
git status --short --untracked-files=no
