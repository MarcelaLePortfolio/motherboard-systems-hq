# Decisions List Compact Title Rule

## Verified Source

The Decisions list heading is rendered by `DecisionListItem` in:

`client/src/approvals/ApprovalsWorkspace.tsx`

Current heading source:

1. `request.evidence.expected_outcome`
2. fallback: `request.evidence.interpreted_objective`

There is no separate persisted decision-title field.

## Design Goal

Keep the Decisions list scannable by ensuring the visible heading remains short while preserving all authoritative and semantic content unchanged.

## Ownership Boundary

This is presentation-only.

Do not modify:

- `expected_outcome`
- `interpreted_objective`
- Package Semantics
- approval-request persistence
- canonical-package persistence
- Matilda generation
- approval authority
- server read models

The full `expected_outcome` must continue to appear in the detail briefing.

## Compact Display Rule

Introduce one local presentation helper in `ApprovalsWorkspace.tsx`:

`deriveDecisionListTitle(value: string): string`

The helper operates only on the already-selected heading text.

Rules:

1. trim surrounding whitespace;
2. collapse internal whitespace to single spaces;
3. if the normalized text is at most 64 characters, return it unchanged;
4. if longer than 64 characters:
   - inspect only the first 64 characters;
   - prefer the final whole-word boundary within that range;
   - return the bounded whole-word prefix followed by `…`;
5. if no usable word boundary exists, use the first 64 characters followed by `…`;
6. never rewrite wording, summarize semantically, infer intent, or call Matilda;
7. never modify the underlying request object.

This is deterministic display shortening, not semantic title generation.

## Rendering Boundary

Only the `<strong>` heading inside `DecisionListItem` uses the compact display helper.

The summary beneath it remains:

`request.evidence.interpreted_objective`

The detail panel remains fully unchanged.

## CSS Boundary

Keep the existing list-card hierarchy.

Additionally enforce visual containment on the heading:

- maximum two displayed lines;
- overflow hidden;
- ellipsis/clamp behavior;
- no fixed card height;
- summary remains independently bounded by existing or separately verified presentation rules.

The deterministic text helper prevents excessively long accessible/display text while the CSS clamp protects layout across widths.

## Required Tests

Add focused tests for the helper:

1. short title remains byte-for-byte unchanged after ordinary whitespace normalization;
2. surrounding and repeated whitespace normalize;
3. text longer than 64 characters is shortened;
4. shortening prefers a whole-word boundary;
5. shortened text ends in one ellipsis character;
6. underlying full expected outcome remains available and unchanged;
7. no semantic summarization or generated replacement exists.

Add or update presentation-contract coverage verifying:

- DecisionListItem applies the compact helper to its heading;
- detail briefing continues to render full `request.evidence.expected_outcome`;
- interpreted-objective summary remains unchanged.

## Explicit Non-Scope

- no backend change;
- no database change;
- no API change;
- no Package Semantics change;
- no Matilda prompt or generation change;
- no new title field;
- no model-authored title;
- no approval-authority change;
- no semantic mutation.

## Implementation Gate

Implementation is not yet authorized.

Next action: review and explicitly authorize this presentation-only rule if accepted.
