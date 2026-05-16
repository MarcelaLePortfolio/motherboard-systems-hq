
# Phase 724 Delegation Visual Generation Gap

## Finding

Phase 723 renderer works correctly.

The remaining gap is worker-side generation.

Delegation currently preserves marker syntax but does not synthesize HTML visual cards automatically.

## Evidence

The Moonrise Bakery task rendered:

`[a polished HTML visual card for Moonrise Bakery]`

instead of actual generated HTML.

## Required Outcome

Operators should be able to delegate natural requests like:

`Create a visual launch card for Moonrise Bakery.`

without manually writing marker syntax.

The worker should internally:

- generate safe HTML

- wrap markers automatically

- preserve markdown fallback sections

## Scope

Inspect worker artifact-generation logic only.

Do not modify:

- renderer

- preview route

- retry contract

- SSE

- DB schema

- polling

- Agent Pool behavior

