
# Phase 733 Aesthetic Composition Mapper Plan

## Purpose

Introduce a preview-only semantic-to-visual composition mapper.

## Problem

Artifact aesthetic instructions are currently rendered as text instead of controlling visual composition.

## Target

Map explicit visual language into preview styling.

## Inputs

Detected words and phrases such as:

- warm cream

- pale blush

- soft ivory

- deep plum

- muted mauve

- sage green

- honey gold

- lavender

- rounded

- cozy

- polished

- lightly magical

## Output

A preview theme object controlling:

- shell background

- card background

- primary text color

- secondary text color

- accent color

- border color

- badge styling

- shadow softness

- typography tone

## Scope

Frontend renderer only.

## Safety Boundary

No execution bridge activation.

No route changes.

No database changes.

No persistence contract changes.

No artifact lifecycle authority changes.

No Matilda execution authority.

## Immediate Implementation Strategy

Add a small helper near the existing preview renderer:

phase733InferAestheticTheme(markdown)

The helper should:

1. inspect normalized markdown text

2. detect soft/cozy/garden aesthetic language

3. return a theme object

4. let phase719RenderArtifactVisualCard apply those styles

## Success Criteria

A delegated Artifact Garden preview visibly differs from the generic dark preview shell.

