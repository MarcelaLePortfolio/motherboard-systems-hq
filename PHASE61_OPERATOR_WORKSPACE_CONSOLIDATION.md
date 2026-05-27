# Phase 61 — Operator Workspace Consolidation

## Objective
Convert the left-side operator area from two stacked cards into a unified tabbed Operator Workspace while preserving the existing right-side Observational Workspace, full-width Atlas / subsystem band, and deterministic runtime behavior.

## Scope
UI-only consolidation pass.

Allowed:
- structural HTML / JSX regrouping
- existing tab-shell reuse
- styling needed to achieve balanced dual-workspace symmetry
- height alignment through parallel workspace shells

Not allowed:
- backend changes
- lifecycle changes
- database changes
- SSE changes
- policy changes
- runtime logic changes
- stream mount changes

## Authoritative Current State
- Right side is already consolidated as Observational Workspace
- Observational tabs:
  - Recent Tasks
  - Task Activity
  - Task Events
- Task Events SSE remains mounted correctly inside the Task Events tab
- Left side still contains:
  - Matilda Chat Console
  - Task Delegation
- Atlas / subsystem band remains full width
- Current state is a checkpoint, not final completion

## Target End State
### Left
Operator Workspace
- Chat
- Delegation

### Right
Observational Workspace
- Recent Tasks
- Task Activity / Task History
- Task Events

### Below
- Atlas / Subsystem Status remains full width

## Acceptance Criteria
1. Left side renders as a single workspace shell with tabs for Chat and Delegation
2. Right-side Observational Workspace remains functionally unchanged
3. Task Events tab still mounts live SSE content correctly
4. Atlas / subsystem band remains full width
5. No runtime or data-flow behavior changes
6. Workspace-to-workspace symmetry produces final height alignment
7. Deterministic dashboard behavior preserved

## Recommended Implementation Sequence
1. Identify the dashboard JSX container that currently renders:
   - Matilda Chat Console
   - Task Delegation
   - Observational Workspace
2. Identify the existing proven tab pattern on the right side
3. Extract or mirror that shell pattern for the left side
4. Move existing left-side content panes under:
   - Chat
   - Delegation
5. Preserve existing component mounting order and behavior
6. Verify layout balance without ad hoc stretching

## Guardrails
- Prefer structural regrouping over restyling hacks
- Do not introduce overlay behavior
- Do not duplicate live mounts
- Do not move Atlas into either workspace shell
- Do not tag a final milestone until left-side consolidation is complete
