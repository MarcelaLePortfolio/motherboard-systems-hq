
# PHASE 719 — ARTIFACT RENDERER FINDING

## CURRENT HEAD

`4419ea51`

## FINDING

The active frontend artifact renderer is not rendering arbitrary artifact HTML or rich artifact body content.

It is extracting only these markdown sections:

- title

- task

- status

- outcome

- explanation

Then it maps them into a fixed visual card layout:

- title area

- task subtitle

- status chip

- Outcome panel

- Build Path panel

## ROOT CAUSE

The preview appears generic because the worker-generated markdown artifact itself contains generic execution-summary fields.

The renderer is working as designed for the current markdown artifact structure.

## IMPORTANT DISTINCTION

This is not a modal sizing problem.

This is not an iframe rendering failure.

This is not missing HTML.

This is a content contract limitation.

## SAFE NEXT CORRIDOR

Do not continue frontend sizing patches.

Next safe direction is artifact content contract design:

- define what a richer artifact body should contain

- decide whether markdown sections should include richer fields

- decide whether renderer should support a body/details section

- preserve current markdown fallback behavior

- avoid worker mutation until contract is explicit

