
# Phase 728 Semantic Consistency Findings

## Finding 1: stale helper comments

The semantic helper files still describe themselves as inactive or not wired into runtime execution.

Observed files:

- worker/semantic/prepareArtifactSemanticMetadata.js

- worker/semantic/composeSemanticArtifact.js

- worker/semantic/classifyArtifact.js

Runtime evidence shows this wording is stale because the live worker imports and calls `prepareArtifactSemanticMetadata` from `server/worker/phase26_task_worker.mjs`.

## Finding 2: live attachment path

The live worker attempts to load:

require("../../worker/semantic/prepareArtifactSemanticMetadata.js")

The artifact persistence path calls:

prepareArtifactSemanticMetadata(`${taskTitle}\n\n${artifactSummary}\n\n${artifactDeliverable}`)

Returned semantic metadata is spread onto the artifact object only.

## Finding 3: artifact-scoped semantic fields

Current artifact-scoped fields are:

- artifact.semantic_artifact

- artifact.semantic_artifact_validated

- artifact.semantic_artifact_schema

No inspected evidence shows top-level semantic task fields being introduced by this path.

## Finding 4: observability consumer compatibility

The developer observability page reads artifact-scoped metadata and also includes fallback aliases:

- artifact.semantic_artifact

- artifact.semantic

- artifact.semantic_metadata

The canonical producer field is currently `artifact.semantic_artifact`.

## Finding 5: classification method

Classification currently uses deterministic keyword matching inside `worker/semantic/classifyArtifact.js`.

Current semantic fields produced by classifier:

- schema_version

- artifact_kind

- semantic_intent

- visual_artifact

- fallback_markdown

Visual artifacts may additionally receive:

- visual_composition

## Boundary conclusion

The current semantic system is runtime-attached but still observational.

Recommended next refinement:

- update stale helper comments to reflect actual live import status

- document `artifact.semantic_artifact` as the canonical observability field

- preserve alias handling in devtools for backward compatibility

- avoid changing runtime behavior during this documentation cleanup

