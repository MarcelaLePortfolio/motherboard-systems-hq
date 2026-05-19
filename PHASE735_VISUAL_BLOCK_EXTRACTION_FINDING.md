
# Phase 735 Visual Block Extraction Finding

## Finding

The preview still appeared flattened because the renderer likely extracted the first `visual-artifact` block from inside the escaped `MB_SEMANTIC_ARTIFACT_V1` JSON comment instead of the real markdown artifact body.

## Change

`phase723ExtractVisualArtifactBlock()` now strips the semantic envelope before searching for `<!-- visual-artifact:start -->`.

## Expected Result

The preview should render the actual artifact HTML body instead of escaped semantic-envelope content.

## Boundary

Renderer extraction only.

No worker mutation.

No route mutation.

No database mutation.

No execution bridge activation.

No Matilda execution authority.

