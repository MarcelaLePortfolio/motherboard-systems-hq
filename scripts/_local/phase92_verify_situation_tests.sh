#!/usr/bin/env bash
set -euo pipefail

echo "== situation imports =="
rg -n 'ConfidenceLevel|phase92_fix_guidance_imports|phase92_repair_confidencelevel_imports|phase92_repair_situation_imports|phase92_repair_confidencelevel_source' cognition/situation || true

echo
echo "== resolved ConfidenceLevel source candidates =="
rg -l --hidden \
  --glob '!node_modules' \
  --glob '!dist' \
  --glob '!build' \
  --glob '!coverage' \
  --glob '!scripts/**' \
  --glob '*.ts' \
  --glob '*.tsx' \
  '(^|[[:space:]])(export[[:space:]]+)?(enum|type)[[:space:]]+ConfidenceLevel\b|export[[:space:]]*\{[^}]*ConfidenceLevel[^}]*\}' \
  . \
| grep -v '/cognition/situation/' || true

echo
echo "== running situation tests =="
node --import tsx --test \
  cognition/situation/__tests__/classifySituation.test.ts \
  cognition/situation/__tests__/frameSituation.test.ts \
  cognition/situation/__tests__/sortSituationFrames.test.ts
