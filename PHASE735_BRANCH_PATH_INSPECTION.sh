
#!/bin/bash

set -euo pipefail

OUTPUT="PHASE735_BRANCH_PATH_INSPECTION.txt"

{

  echo "# Phase 735 Branch Path Inspection"

  echo ""

  echo "## phase719RenderMarkdownArtifactPreview"

  echo ""

  grep -n "function phase719RenderMarkdownArtifactPreview" -A220 public/js/phase530_visible_panels_bridge.js || true

  echo ""

  echo "## phase723RenderVisualArtifactPreviewCandidate"

  echo ""

  grep -n "phase723RenderVisualArtifactPreviewCandidate" -A120 -B40 public/js/phase530_visible_panels_bridge.js || true

  echo ""

  echo "## data-phase733-single-artifact-render"

  echo ""

  grep -n "data-phase733-single-artifact-render" -A80 -B40 public/js/phase530_visible_panels_bridge.js || true

  echo ""

  echo "## All render-preview callers"

  echo ""

  grep -n "RenderMarkdownArtifactPreview" -A20 -B20 public/js/phase530_visible_panels_bridge.js || true

} > "$OUTPUT"

cat "$OUTPUT"

