#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== RUN ADAPTIVE DETAIL — MIXED CONTENT LIVE VALIDATION ==="

if [[ "$(git rev-parse --short HEAD)" != "0a3251f5" ]]; then
  echo "STOP: HEAD no longer matches validation-observer checkpoint 0a3251f5."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/validate-adaptive-detail-mixed-content-live\.ts$|^\?\? scripts/run-adaptive-detail-mixed-content-live-validation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== OLLAMA AVAILABILITY ==="
curl --fail --silent \
  http://localhost:11434/api/tags \
  >/dev/null

echo "OLLAMA_AVAILABLE"

echo
echo "=== LIVE VALIDATION ==="
npx tsx \
  scripts/validate-adaptive-detail-mixed-content-live.ts

echo
echo "=== REGRESSION SUITE ==="
npx tsx --test scripts/utils/ollamaChat*.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION WORKFLOW REMAINS OBSERVER-FREE ==="
if grep -n \
  'observeValidatedSelectedContextSegments' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow unexpectedly references validation observer."
  exit 2
fi

echo "PRODUCTION_WORKFLOW_OBSERVER_ABSENT"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_MIXED_CONTENT_LIVE_VALIDATION_PASSED"
