
# Phase 722 Readability Polish Plan

## Corridor Classification

Phase 722 is a frontend-only semantic readability refinement corridor.

The objective is:

Improve operator readability while preserving all validated contracts.

## Authoritative Baseline

Resume from:

`501072e0 Phase 721: seal browser-validated semantic operator summary`

This commit is now the stable rollback anchor.

## Preserved Contracts

The following systems are frozen and must remain untouched:

- worker artifact generation

- semantic envelope structure

- artifact preview route

- task route shape

- DB schema

- SSE streams

- retry architecture

- markdown fallback rendering

- iframe/srcdoc retirement state

## Allowed Scope

UI-only readability refinement:

- reduce duplicate semantic/fallback phrasing

- improve section spacing

- improve visual grouping

- improve label clarity

- improve semantic summary readability

- reorder semantic blocks above markdown fallback

- reduce operator cognitive load

## Forbidden Scope

Do not modify:

- worker execution

- backend routes

- SSE contracts

- retry behavior

- task polling

- DB models

- semantic envelope schema

- markdown fallback generation

- artifact persistence

## Recommended Strategy

Apply the smallest possible UI-only patch.

Priority order:

1. Preserve current successful rendering.

2. Reduce duplicated semantic/fallback wording.

3. Improve visual hierarchy.

4. Preserve legacy artifact rendering.

5. Preserve malformed-envelope fallback behavior.

## Expected Safe Improvements

Potential safe refinements:

- rename "Semantic Operator Summary" to shorter label

- visually collapse duplicate Summary/Deliverable text

- visually separate semantic insights from markdown fallback

- reduce repeated "Prepared artifact for..." phrasing

- add subtle divider between semantic metadata and markdown sections

## Validation Requirements

After every patch:

- dashboard healthy

- semantic chip still visible

- semantic summary still visible

- markdown sections still visible

- legacy artifacts still render

- raw envelope never visible

- task list route healthy

- no console/runtime regression

## Rollback Discipline

If preview rendering regresses:

Immediate revert target:

`501072e0`

Do not stack speculative fixes beyond three failed attempts.

Do not mutate backend/worker systems while debugging visual regressions.

