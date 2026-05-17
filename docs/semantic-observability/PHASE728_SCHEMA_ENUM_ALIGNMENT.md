
# Phase 728 Schema Enum Alignment

## Inspection Result

The classification inventory was checked against the authoritative schema:

- contracts/artifacts/semantic-artifact-schema.v1.json

and the active classifier:

- worker/semantic/classifyArtifact.js

## Schema-supported artifact_kind values

The schema allows:

- markdown

- visual

- report

- plan

- checklist

- launch_card

- unknown

The current classifier actively emits:

- markdown

- visual

- report

- plan

- checklist

- launch_card

Schema-only reserve value:

- unknown

## Schema-supported semantic_intent values

The schema allows:

- inform

- summarize

- plan

- persuade

- visualize

- compare

- execute

- unknown

The current classifier actively emits:

- inform

- summarize

- plan

- visualize

- compare

- execute

Schema-only reserve values:

- persuade

- unknown

## Documentation Gap

The Phase 728 classification inventory now documents active classifier values, but should also identify schema-only reserve values separately.

This distinction matters because:

- active classifier values describe current runtime behavior

- schema-only reserve values describe allowed contract vocabulary

- neither grants renderer authority or execution authority

## Boundary

This is a documentation alignment finding only.

No runtime behavior should change.

