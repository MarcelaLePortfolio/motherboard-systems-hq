#!/usr/bin/env bash
set -euo pipefail

echo "== ConfidenceLevel imports in cognition/situation =="
rg -n 'import .*ConfidenceLevel' cognition/situation

echo
echo "== Running situation tests =="
node --import tsx --test \
  cognition/situation/__tests__/classifySituation.test.ts \
  cognition/situation/__tests__/frameSituation.test.ts \
  cognition/situation/__tests__/sortSituationFrames.test.ts
