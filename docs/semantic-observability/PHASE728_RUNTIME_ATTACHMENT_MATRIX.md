
# Phase 728 Runtime Attachment Matrix

## Corridor

READ-ONLY SEMANTIC OBSERVABILITY

## Purpose

Map the semantic observability surface by attachment role.

This document is documentation-only and does not mutate runtime behavior, renderer authority, orchestration logic, retry behavior, SSE behavior, persistence contracts, task routing, or preview contracts.

## Runtime-Attached Surface

| File | Role | Runtime Attachment Status | Authority Level |

|---|---|---|---|

| server/worker/phase26_task_worker.mjs | Worker artifact persistence path | Runtime-attached | Execution-adjacent, but semantic attachment remains additive only |

| worker/semantic/prepareArtifactSemanticMetadata.js | Semantic metadata adapter | Runtime-attached through worker import | Observational, artifact-scoped, non-authoritative |

## Semantic Helper Surface

| File | Role | Runtime Attachment Status | Authority Level |

|---|---|---|---|

| worker/semantic/classifyArtifact.js | Deterministic semantic classifier | Called through metadata adapter | Observational only |

| worker/semantic/composeSemanticArtifact.js | Semantic payload composer | Called through metadata adapter | Observational only |

| worker/semantic/validateSemanticArtifact.js | Semantic schema validator | Called through metadata adapter | Validation-only |

| worker/semantic/inspectSemanticPipeline.js | Inspection helper | Not identified as runtime-attached in current inspection | Developer inspection only |

| worker/semantic/README.md | Semantic helper documentation | Documentation-only | Non-authoritative |

## Schema / Contract Surface

| File | Role | Runtime Attachment Status | Authority Level |

|---|---|---|---|

| contracts/artifacts/semantic-artifact-schema.v1.json | Semantic artifact schema contract | Used by validator | Validation contract only |

## Developer Observability Surface

| File | Role | Runtime Attachment Status | Authority Level |

|---|---|---|---|

| public/devtools/semantic-observability.html | Developer inspection UI | Served devtools surface | Read-only metadata visibility only |

## Test Surface

| File | Role | Runtime Attachment Status | Authority Level |

|---|---|---|---|

| worker/semantic/classifyArtifact.test.js | Classifier test coverage | Test-only | Non-runtime |

| worker/semantic/composeSemanticArtifact.test.js | Composer test coverage | Test-only | Non-runtime |

| worker/semantic/prepareArtifactSemanticMetadata.test.js | Adapter test coverage | Test-only | Non-runtime |

| worker/semantic/validateSemanticArtifact.test.js | Validator test coverage | Test-only | Non-runtime |

## Documentation Surface

| File | Role | Runtime Attachment Status | Authority Level |

|---|---|---|---|

| docs/semantic-observability/PHASE727_SEMANTIC_OBSERVABILITY_PLAN.md | Historical observability plan | Documentation-only | Non-runtime |

| docs/semantic-observability/PHASE728_SEMANTIC_CONSISTENCY_START.md | Phase 728 start record | Documentation-only | Non-runtime |

| docs/semantic-observability/PHASE728_SEMANTIC_CONSISTENCY_FINDINGS.md | Phase 728 findings | Documentation-only | Non-runtime |

| docs/semantic-observability/PHASE728_ALIAS_DRIFT_INSPECTION.md | Alias drift inspection | Documentation-only | Non-runtime |

| docs/semantic-observability/PHASE728_RUNTIME_ALIGNMENT_PLAN.md | Runtime alignment plan | Documentation-only | Non-runtime |

| docs/semantic-observability/PHASE728_ALIGNMENT_STATUS.md | Alignment checkpoint | Documentation-only | Non-runtime |

| docs/semantic-observability/PHASE728_NEXT_SAFE_CORRIDOR.md | Next safe corridor policy | Documentation-only | Non-runtime |

| docs/semantic-observability/PHASE728_CANONICAL_SURFACE_INDEX.md | Canonical surface index | Documentation-only | Non-runtime |

| docs/semantic-observability/PHASE728_STABILIZATION_CHECKPOINT.md | Stabilization checkpoint | Documentation-only | Non-runtime |

| docs/semantic-observability/PHASE728_SEAL_SUMMARY.md | Seal summary | Documentation-only | Non-runtime |

| docs/semantic-observability/PHASE728_SCHEMA_ENUM_ALIGNMENT.md | Schema enum alignment | Documentation-only | Non-runtime |

| docs/semantic-observability/PHASE728_RUNTIME_SCHEMA_MATRIX.md | Runtime/schema matrix | Documentation-only | Non-runtime |

| docs/semantic-observability/PHASE728_DOCUMENTATION_INDEX.md | Documentation index | Documentation-only | Non-runtime |

| docs/semantic-observability/SEMANTIC_FIELD_REFERENCE.md | Field reference | Documentation-only | Non-runtime |

| docs/semantic-observability/SEMANTIC_CLASSIFICATION_INVENTORY.md | Classification inventory | Documentation-only | Non-runtime |

## Canonical Runtime Flow

Current observed semantic attachment flow:

1. `server/worker/phase26_task_worker.mjs`

2. `worker/semantic/prepareArtifactSemanticMetadata.js`

3. `worker/semantic/composeSemanticArtifact.js`

4. `worker/semantic/classifyArtifact.js`

5. `worker/semantic/validateSemanticArtifact.js`

6. artifact-scoped semantic fields are attached if validation succeeds

Canonical artifact-scoped fields:

- artifact.semantic_artifact

- artifact.semantic_artifact_schema

- artifact.semantic_artifact_validated

## Explicit Non-Authority Statement

Semantic metadata does not control:

- renderer authority

- task routing

- orchestration behavior

- retry policy

- SSE behavior

- persistence schema

- preview contracts

- execution routing

## Stability Status

This matrix is documentation-only.

No runtime mutation introduced.

