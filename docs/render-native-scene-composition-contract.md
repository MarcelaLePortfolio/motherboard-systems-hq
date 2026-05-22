
# Render-Native Scene Composition Contract

Status: ACTIVE SANDBOX PLANNING

Corridor: DETERMINISTIC SCENE COMPOSITION + SANDBOX VISUAL FIDELITY

## Purpose

Define how semantic intent becomes deterministic visual scene structure before any live Preview integration.

## Core Principle

The system must not ask the live renderer to guess meaning.

Semantic intent must first be compiled into an explicit scene structure with:

- known node types

- known layout tokens

- known style tokens

- known hierarchy

- known content fields

- known validation flags

## Current Verified Pipeline

semantic intent

→ compiled payload

→ rendered HTML

→ payload inspection report

→ sandbox chain report

## Current Verified Payload Schema

- schema_version

- artifact_type

- scene

- layout

- layout_tokens

- style_tokens

- nodes

- text

- validation

## Current Verified Node Types

- container

- text

## Current Verified Render Root

- sandbox-render-root

## Current Verified Node IDs

- root-node

- title-node

- body-node

## Current Verified Layout Tokens

- stack

- card

## Current Verified Style Tokens

- background

- text

- accent

- spacing

## Next Scene Composition Objective

Add deterministic scene composition before visual expansion.

The composer should decide:

1. What artifact pattern is being requested

2. Which scene template should represent it

3. Which node hierarchy should be emitted

4. Which layout tokens should apply

5. Which style tokens should apply

6. Which validation rules must pass before rendering

## Initial Scene Patterns

### 1. Status Card

Used for:

- checkpoint summaries

- pass/fail reports

- system status

- validation results

Required nodes:

- root container

- title text

- body text

- status text

### 2. Evidence Card

Used for:

- renderer proof

- payload inspection

- schema confirmation

- artifact verification

Required nodes:

- root container

- title text

- body text

- evidence list

### 3. Execution Readiness Card

Used for:

- preflight summaries

- mutation gating

- sandbox readiness

- integration planning

Required nodes:

- root container

- title text

- body text

- readiness state

- blocking conditions

## Sandbox Fidelity Objective

Improve visual clarity without touching live Preview.

Allowed improvements:

- better spacing tokens

- richer card structure

- clearer hierarchy

- status labels

- evidence sections

- deterministic CSS output

- readable standalone sandbox HTML

Disallowed improvements:

- live Preview mutation

- renderer interception

- browser runtime patching

- hidden production wiring

- speculative integration

- schema drift without inspection evidence

## Integration Boundary

Live Preview integration remains blocked until:

1. scene composition passes in sandbox

2. payload validation passes

3. rendered HTML is inspected

4. node hierarchy is documented

5. payload contract is updated

6. external DR backup exists

7. explicit integration approval is given

## Current Recommendation

Proceed next with a sandbox-only scene composer that transforms the existing semantic intent seed into a richer scene pattern without changing the live Preview renderer.

