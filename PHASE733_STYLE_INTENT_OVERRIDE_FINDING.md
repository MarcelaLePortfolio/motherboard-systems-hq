
# Phase 733 Style Intent Override Finding

## Finding

The preview still rendered generically because embedded visual artifact HTML takes priority over the semantic visual card path.

## Root Cause

The generated artifact includes a hard-coded `visual-artifact` block. When that block exists, the preview stack returns the embedded visual artifact before the request-scoped style intent theme can control presentation.

## Change

When `semanticEnvelope.style_intent` is explicitly present, the preview renderer now prefers the semantic visual card path so the bounded style-intent mapper can apply.

## Scope

Frontend preview renderer only.

## Safety Boundary

No execution bridge activation.

No route changes.

No database changes.

No persistence contract changes.

No artifact lifecycle authority change.

No Matilda execution authority.

## Expected Result

New artifacts with structured `style_intent` should no longer be visually dominated by the generic embedded dark/gold visual artifact block.

