#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== FIX ADAPTIVE DETAIL LIVE RUNNER — ANCESTRY GUARD ==="

if [[ "$(git rev-parse --short HEAD)" != "e744d3e4" ]]; then
  echo "STOP: HEAD no longer matches runner-repin checkpoint e744d3e4."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/fix-adaptive-detail-live-runner-ancestry-guard\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat > scripts/run-adaptive-detail-mixed-content-live-validation.sh <<'RUNNER_EOF'
#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== RUN ADAPTIVE DETAIL — MIXED CONTENT LIVE VALIDATION ==="

required_implementation_commit="0a3251f5"

if ! git merge-base --is-ancestor \
  "$required_implementation_commit" \
  HEAD
then
  echo "STOP: HEAD does not contain required Adaptive Detail prompt clarification $required_implementation_commit."
  exit 2
fi

echo "REQUIRED_IMPLEMENTATION_ANCESTOR_PRESENT=$required_implementation_commit"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "STOP: working tree is not clean."
  git status --short
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
RUNNER_EOF

chmod +x scripts/run-adaptive-detail-mixed-content-live-validation.sh

echo
echo "=== VERIFY RUNNER CHANGE ==="
git diff --check
git diff -- scripts/run-adaptive-detail-mixed-content-live-validation.sh

git add \
  scripts/run-adaptive-detail-mixed-content-live-validation.sh \
  scripts/fix-adaptive-detail-live-runner-ancestry-guard.sh

git commit -m "Fix Adaptive Detail live validation ancestry guard"
git push

echo
echo "=== EXECUTE LIVE VALIDATION ==="
./scripts/run-adaptive-detail-mixed-content-live-validation.sh
