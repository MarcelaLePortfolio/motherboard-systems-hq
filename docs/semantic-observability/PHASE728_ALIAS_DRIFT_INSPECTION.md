
# Phase 728 Alias Drift Inspection

## Inspection command

Checked runtime-facing surfaces for semantic alias usage:

- public

- ui

- worker

- server

## Result

No active producer was found for:

- artifact.semantic

- artifact.semantic_metadata

The only observed `semantic_metadata` reference is inside:

- public/devtools/semantic-observability.html

That reference is defensive fallback logic only.

## Canonical field status

Current canonical semantic payload field:

- artifact.semantic_artifact

Current canonical validation field:

- artifact.semantic_artifact_validated

Current canonical schema field:

- artifact.semantic_artifact_schema

## Conclusion

The runtime semantic field surface is already canonicalized in practice.

The devtools alias handling may remain for backward-compatible inspection safety, but future documentation should identify `artifact.semantic_artifact` as the only active canonical producer field.

