# Phase 99.3 — Implementation Target Lock

## Objective
Prepare safe additive extension to SituationSummary contract.

## Confirmed insertion location
src/cognition/situationSummaryComposer.ts

## Confirmed structure target

Add OPTIONAL field only:

operationalConfidence?: {
  level: "HIGH" | "MEDIUM" | "LOW" | "UNKNOWN";
  source?: "governance" | "cognition" | "signals";
}

## Rules
Do NOT:
- modify summaryLines
- modify renderSituationSummary
- modify snapshot rendering
- modify CLI output
- modify smoke expectations

Do:
- add optional field only
- default undefined
- ensure zero behavioral change

## Phase boundary
This is a STRUCTURE PREPARATION STEP only.

Integration occurs later.

## Next action (next session)
Locate exact insertion line inside:

SituationSummary type definition.

Then prepare minimal additive patch.

STOP after structure insertion.

