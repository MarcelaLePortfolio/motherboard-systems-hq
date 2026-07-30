# Claude Task — Mission Control Presentation v1

## Objective

Implement the approved Mission Control presentation specification and reproduce the approved mockup’s card composition, information hierarchy, compact scale, and executive usefulness.

The mockup is the visual target. `MISSION_CONTROL_PRESENTATION_SPECIFICATION_V1.md` is the authoritative semantic and architectural contract.

## Execution Mode

This is a bounded frontend implementation assignment.

Claude may implement the specified UI but must not reinterpret the backend architecture, governance model, Mission Read contract, operational authority model, or package semantics.

## Primary Outcomes

1. Replace the current low-value Current Mission card with the higher-value Executive Brief described in the specification.
2. Replace the current primary Governance Lifecycle visualization with Mission Progress.
3. Preserve the authoritative chronological timeline for a separate Governance History or Event Feed.
4. Restore the useful cards present in the approved mockup.
5. Match the mockup’s compact desktop density and visual hierarchy.
6. Preserve all existing authoritative Mission Read integration and runtime states.

## Required Card Architecture

The target composition includes:

1. Executive Brief.
2. Mission Status.
3. Mission Progress.
4. Latest Event.
5. Next Step.
6. Active Agent or Current Owner.
7. Mission Pipeline.
8. Package Details.
9. System Overview when authoritative data exists.
10. Governance History or Authoritative Event Feed.

## Critical Semantic Distinctions

### Executive Brief versus identification card

The Executive Brief must communicate:

- the mission objective,
- current operational stage,
- health,
- progress context,
- and useful executive meaning.

A package identifier, version, and generic sentence are insufficient.

### Mission Progress versus Governance History

Mission Progress is an operational progress model showing where the mission is in the organization’s workflow.

Governance History is a chronological authoritative evidence record.

Do not use raw timeline events as a substitute for Mission Progress.

### Mission Pipeline versus Mission Progress

Mission Progress communicates lifecycle completion.

Mission Pipeline communicates organizational movement, handoffs, and active responsibility.

These concepts may be visually related but must not be accidentally collapsed.

## Canonical Mission Progress Stages

Use the following presentation stages unless the supplied frontend model demonstrates that a label must be adjusted to preserve stabilized architectural meaning:

1. Intent.
2. Governance.
3. Envelope.
4. Assignment.
5. Execution.
6. Review.
7. Complete.

No stage may be marked complete without authoritative supporting state.

## Authorized Files

Claude may modify only the frontend files included in this bundle.

The expected primary files are:

- `client/src/shell/MissionDashboardWorkspace.tsx`
- `client/src/shell/mission-dashboard.css`
- `client/src/shell/mission-dashboard-presentation.css`

Claude may modify an included Mission Control presentation component or type file only when required to complete this assignment.

## Explicitly Out of Scope

Do not modify:

- backend routes,
- database files,
- Mission Read repositories,
- Mission Read assemblers,
- governance runtime,
- canonical package runtime,
- delegation runtime,
- envelope runtime,
- project registry,
- conversation runtime,
- provider architecture,
- API contracts,
- routing architecture,
- unrelated workspaces,
- disaster recovery tooling,
- semantic drift tooling.

Do not introduce direct database access from the client.

Do not introduce hard-coded operational claims.

Do not invent:

- ownership,
- health,
- progress,
- completion,
- estimated completion,
- blocking state,
- active agents,
- system-health metrics.

When authoritative data is absent, render an honest unavailable, unassigned, pending, or not-yet-recorded state.

## Existing Behavior That Must Be Preserved

- Mission Read remains authoritative.
- Existing loading state remains functional.
- Existing error state remains functional.
- Existing not-found state remains functional.
- Existing refresh behavior remains functional.
- Existing mission identity remains available as secondary metadata.
- Existing timeline evidence remains available for Governance History.
- Existing responsive behavior must not regress.
- The horizontal Mission Progress presentation must remain horizontal at standard desktop widths.
- Compact/mobile layouts may use a vertical fallback.

## Visual Requirements

The approved mockup uses compact desktop proportions.

Correct the current oversized presentation by reducing:

- page padding,
- card padding,
- hero height,
- title scale,
- status-card height,
- lifecycle-card height,
- vertical gaps,
- touch-interface-like proportions.

The result should resemble a professional executive workstation, not a tablet kiosk, marketing landing page, or generic admin template.

## Implementation Order

### Slice 1 — Structural composition

Recompose the dashboard to match the mockup’s card arrangement and compact density.

### Slice 2 — Executive Brief

Replace the existing Current Mission presentation with the specified Executive Brief using authoritative fields already available to the frontend.

### Slice 3 — Mission Progress

Create a presentation-only operational-stage mapper from existing authoritative Mission Read state.

Preserve raw timeline events separately.

### Slice 4 — Executive action cards

Refine:

- Latest Event,
- Next Step,
- Active Agent or Current Owner.

### Slice 5 — Supporting cards

Add or refine:

- Mission Pipeline,
- Package Details,
- Governance History.

System Overview may be visibly deferred when no authoritative projection exists.

### Slice 6 — Visual reconciliation

Compare the live result directly against the approved mockup for:

- composition,
- scale,
- card presence,
- content hierarchy,
- typography,
- spacing,
- density.

## Validation Requirements

Run the repository’s existing client production build.

Run the repository’s semantic drift guard.

Run `git diff --check`.

Confirm that only authorized frontend files changed.

Provide:

1. A concise implementation summary.
2. A list of modified files.
3. Validation results.
4. Any unavailable fields that remain explicitly deferred.
5. Any architectural ambiguity that prevented a faithful implementation.

## Stop Conditions

Stop without implementing when:

- required authoritative state cannot be identified,
- implementation would require backend changes,
- implementation would require API changes,
- the supplied files are insufficient,
- the requested visual behavior conflicts with the presentation specification,
- a semantic distinction cannot be preserved safely.

Do not compensate for missing information with speculative code.
