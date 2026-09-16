# Semantic History Exact-ID IEL Retrieval — Implementation Checkpoint

## Current System State

The Semantic History Context Optimization investigation established a structural history-loss mechanism caused by applying the production conversation-turn recency window before semantic eligibility selection while independently sourcing interpretation lifecycle metadata from a global recency-bounded IEL read.

The bounded exact-ID IEL retrieval remedy is now implemented and validated.

## Verified Implementation

Commit:

`d7d2bc86555d99f24cb426e2a03324c6a955918d`

Subject:

`Add exact-ID IEL retrieval for Matilda history`

Implemented files:

- `db/matilda-interpretation-runtime.ts`
- `db/matilda-interpretation-runtime.exact-id-reader.test.ts`
- `server/matilda-chat-workflow.ts`

## Implemented Behavior

A new additive reader:

`readInterpretationEvidenceLedgerEntriesByIds(...)`

retrieves IEL entries by the exact `interpretation_entry_id` identities already present on the bounded conversation turns.

The reader:

- requires project scope;
- requires conversation scope;
- deduplicates requested IDs;
- returns no broad fallback for missing IDs;
- excludes foreign-project and foreign-conversation entries;
- reuses the established fail-closed IEL reconstruction path for investigation lifecycle and package semantics.

The workflow now uses exact turn-aligned IEL retrieval for:

- interpretation lifecycle alignment;
- prior support provenance recovery.

The former global `listInterpretationEvidenceLedgerEntries(500)` workflow read is no longer used for those turn-aligned consumers.

## Preserved Architectural Boundaries

The implementation does not change:

- the 20-turn production conversation history window;
- semantic history authority evaluation;
- contamination evaluation;
- semantic history selection;
- Matilda authorship boundaries;
- IEL persistence;
- IEL schema;
- prior investigation lifecycle retrieval;
- prior support provenance interpretation semantics;
- the one-workflow / one-Ollama-invocation invariant.

The existing general IEL list reader remains available and unchanged in purpose.

## Validation

Bounded regression suite:

- exact-ID IEL reader regression;
- conversation context composition;
- interpretation lifecycle provider;
- prior support provenance.

Result:

`12 / 12 PASS`

TypeScript validation:

`PASS`

Semantic drift guard:

`PASS`

Local and remote branch synchronization:

`CONFIRMED`

## Failure Containment Record

Implementation hypothesis failures before success:

1. Wrong IEL table identifier.
2. Reference to a nonexistent reconstruction helper.
3. Third attempt reused the established inline reconstruction path exactly and passed.

No fourth attempt was required.

No rollback was required because the third attempt succeeded within the three-failed-hypothesis boundary.

## Current Scope Determination

This implementation resolves the IEL identity-alignment defect within the current 20-turn candidate window.

It does **not** yet resolve the previously reproduced broader Semantic History Context Optimization limitation where an eligible turn older than the current 20-turn retrieval window cannot enter semantic selection.

That broader optimization remains an active investigation boundary.

## Deferred Work

Still deferred / unresolved:

- retrieval-window optimization;
- candidate-depth versus selected-history-depth design;
- semantic history ranking;
- hybrid context composition;
- context-window optimization;
- determination of the appropriate bounded candidate depth;
- validation of recovery of eligible history beyond the current 20-turn retrieval boundary.

No additional production implementation is authorized by this checkpoint.

## Repository Checkpoint

Branch:

`feature/support-source-references-runtime`

Verified commit:

`d7d2bc86555d99f24cb426e2a03324c6a955918d`

Status:

`EXACT_ID_IEL_ALIGNMENT_IMPLEMENTED_AND_VALIDATED`

Next investigation boundary:

`SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION — CANDIDATE DEPTH / FINAL SELECTED HISTORY BOUNDARY`
