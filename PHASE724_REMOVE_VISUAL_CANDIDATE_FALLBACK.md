
# Phase 724 Remove Visual Candidate Fallback

## Objective

Remove the fallback append inside the visual artifact candidate renderer.

## Cause

`phase719RenderMarkdownArtifactPreview()` correctly entered visual-only mode, but `phase723RenderVisualArtifactPreviewCandidate()` still appended:

`${fallbackPreview}`

inside the visual artifact return.

## Fix

Removed fallback append from the visual artifact candidate return path.

## Expected Result

For visual artifacts:

- Visual Artifact section remains

- Completion Summary / semantic fallback disappears from primary Preview

- raw marker block disappears from primary Preview

For non-visual artifacts:

- fallback rendering remains unchanged

## Validation

Syntax check:

`node --check public/js/phase530_visible_panels_bridge.js`

