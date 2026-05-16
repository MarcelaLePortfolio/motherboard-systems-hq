
#!/usr/bin/env bash

set -euo pipefail

echo "Phase 726 Runtime Probe"

echo "Mode: read-only source inspection"

echo ""

echo "== Git State =="

git status --short

git log --oneline -5

echo ""

echo "== Artifact Preview Route Markers =="

grep -nE "artifact-preview|artifact_file_missing|artifact_path_rejected|artifact_preview_failed|completed\.payload|row\.artifact|row\.artifacts" server/routes/api-tasks-postgres.mjs || true

echo ""

echo "== Renderer Visual Preview Markers =="

grep -nE "phase719RenderMarkdownArtifactPreview|phase723ExtractVisualArtifactBlock|phase723RenderVisualArtifactPreviewCandidate|phase724-visual-only-preview|artifact-preview|body\.innerHTML" public/js/phase530_visible_panels_bridge.js || true

echo ""

echo "== Worker Artifact / Response Markers =="

grep -RInE "persistTaskArtifact|artifact|artifacts|outcome_preview|explanation_preview|completed|payload|visual_artifact|strategy_applied" server/worker server/artifacts.mjs server/routes server/api 2>/dev/null | head -220 || true

echo ""

echo "== Existing Phase 726 Semantic Helper Validation =="

npm run phase726:semantic:test

