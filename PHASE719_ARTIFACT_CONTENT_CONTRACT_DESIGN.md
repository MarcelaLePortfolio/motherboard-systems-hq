
# PHASE 719 — ARTIFACT CONTENT CONTRACT DESIGN

## PURPOSE

Define the next safe contract direction before any worker artifact-generation mutation occurs.

## CURRENT CONFIRMED STATE

The artifact visibility pipeline works:

- worker creates markdown artifact

- artifact persists

- preview route returns artifact content

- frontend extracts markdown sections

- iframe/srcdoc renders visual card

- modal opens cleanly

- console is clean enough for inspection

## CURRENT LIMITATION

The artifact preview is generic because the artifact body is generic.

Current renderer extracts only:

- title

- task

- status

- outcome

- explanation

Current visual card renders only:

- title

- task subtitle

- status chip

- Outcome

- Build Path

## CONTRACT PROBLEM

There is no explicit rich artifact content contract.

The system currently treats artifact output as a worker execution summary, not as a product-quality generated artifact.

## REQUIRED CONTRACT BEFORE WORKER MUTATION

A richer artifact should define sections such as:

- `# Artifact Title`

- `## Task`

- `## Status`

- `## Summary`

- `## Deliverable`

- `## Details`

- `## Recommendations`

- `## Next Steps`

- `## Execution Trace`

## SAFE CONTRACT PRINCIPLES

1. Preserve markdown as the persisted artifact format for now.

2. Keep current renderer fallback behavior.

3. Do not introduce native HTML artifact generation yet.

4. Do not mutate DB schema.

5. Do not alter retry/requeue behavior.

6. Do not couple advisory chat to execution.

7. Worker changes must be narrow and section-format-focused only.

## NEXT SAFE IMPLEMENTATION DIRECTION

First implementation should be a worker markdown enrichment patch, not a frontend modal patch.

The worker should produce richer markdown sections while preserving existing summary fields.

The renderer can then be expanded separately to display:

- Summary

- Deliverable

- Details

- Recommendations

- Next Steps

## FROZEN / UNSAFE

Do not resume:

- modal sizing-only patches

- iframe sizing-only patches

- worker HTML generation

- artifact persistence schema redesign

- native HTML contract implementation

