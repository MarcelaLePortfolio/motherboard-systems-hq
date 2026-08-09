#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE ADAPTIVE DETAIL — SELECTION / SUPPORT ALIGNMENT ==="

if [[ "$(git rev-parse --short HEAD)" != "6f0b77a7" ]]; then
  echo "STOP: HEAD no longer matches mixed-content live-result checkpoint 6f0b77a7."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-adaptive-detail-selection-support-alignment\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== SELECTED CONTEXT CONTRACT SEAMS ==="
grep -n -C 6 \
  -E 'selectedContextSegments|materially affects|semantic project-context admission|semantic admission' \
  scripts/utils/ollamaChat.ts || true

echo
echo "=== SUPPORT SOURCE CONTRACT SEAMS ==="
grep -n -C 6 \
  -E 'supportSourceReferences|support provenance|project_context_excerpt|explicitly support' \
  scripts/utils/ollamaChat.ts || true

echo
echo "=== EVIDENCE SUFFICIENCY SEAMS ==="
grep -n -C 6 \
  -E 'evidenceSufficient|validatedSupport|validated.*support|Evidence' \
  scripts/utils/ollamaChat.ts || true

echo
echo "=== SELECTED / SUPPORT CONSISTENCY VALIDATION ==="
grep -n -C 10 \
  -E 'selectedParent|selected.*parent|parent.*selected|support.*selected|selected.*support' \
  scripts/utils/ollamaChat.ts || true

echo
echo "=== REPOSITORY REFERENCES — SELECTED CONTEXT ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='investigate-adaptive-detail-selection-support-alignment.sh' \
  -E 'selectedContextSegments|semantic admission|materially affects the immediate reply' \
  scripts server docs 2>/dev/null || true

echo
echo "=== REPOSITORY REFERENCES — SUPPORT PROVENANCE ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='investigate-adaptive-detail-selection-support-alignment.sh' \
  -E 'supportSourceReferences|support provenance|evidenceSufficient' \
  scripts server docs 2>/dev/null || true

echo
echo "=== LIVE VALIDATION CONTRACT ==="
sed -n '1,240p' scripts/validate-adaptive-detail-mixed-content-live.ts

echo
echo "=== PREVIOUS RECONCILIATION DETERMINATION ==="
sed -n '1,280p' \
  scripts/document-adaptive-detail-selection-support-reconciliation.sh

echo
echo "=== MIXED CONTENT LIVE RESULT DETERMINATION ==="
sed -n '1,430p' \
  scripts/document-adaptive-detail-mixed-content-live-failure.sh

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_SELECTION_SUPPORT_ALIGNMENT_EVIDENCE_COLLECTED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_SELECTION_AND_SUPPORT_OWNERSHIP_FROM_REPOSITORY_EVIDENCE"

git add scripts/investigate-adaptive-detail-selection-support-alignment.sh
git commit -m "Investigate Adaptive Detail selection support alignment"
git push
