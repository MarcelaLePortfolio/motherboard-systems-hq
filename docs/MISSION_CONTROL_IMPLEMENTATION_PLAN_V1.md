# Mission Control Implementation Plan v1

## Status

Authorized planning artifact.

This document translates the approved Mission Control Presentation Specification v1 into a bounded frontend implementation sequence.

It does not authorize backend, database, runtime, governance, delegation, envelope, project-context, conversation, or disaster-recovery changes.

## Governing Authority

The following sources govern this implementation in descending order:

1. Stabilized architectural invariants already established in the repository.
2. `docs/MISSION_CONTROL_PRESENTATION_SPECIFICATION_V1.md`.
3. The approved Mission Control mockup included in the bounded Claude handoff bundle.
4. Existing authoritative Mission Read frontend integration.
5. Existing frontend layout and presentation files.

Where these sources appear to conflict, implementation must stop and the conflict must be reported.

No speculative resolution is authorized.

## Implementation Objective

Transform the current Mission Control workspace from a low-information presentation into an executive operational briefing that:

- communicates the mission objective,
- communicates current operational state,
- communicates progress through the governed lifecycle,
- communicates current ownership and next action,
- preserves authoritative event evidence,
- preserves all existing Mission Read states,
- uses compact desktop proportions,
- remains semantically honest when authoritative data is unavailable.

## Operating Constraints

### Collaboration and execution boundary

Architecture, semantic interpretation, source-of-truth decisions, and scope changes remain collaboration work.

Claude is authorized only for the bounded frontend implementation described by the handoff task and this plan.

Claude must not redefine:

- mission semantics,
- governance semantics,
- lifecycle meaning,
- package meaning,
- delegation meaning,
- envelope meaning,
- execution authority,
- review authority,
- completion authority,
- project identity,
- conversation identity,
- backend source-of-truth rules.

### Evidence-first rule

Every rendered operational claim must be supported by authoritative state already available through the Mission Read frontend contract.

The interface must not infer or invent:

- successful completion,
- active ownership,
- health,
- blocking state,
- system health,
- estimated completion,
- package movement,
- assignment,
- execution,
- review,
- final outcome.

### Scope-first rule

Before changing code, Claude must identify the exact included files and confirm that the requested implementation can be completed within those files.

If completion requires a file not included in the bundle, Claude must stop and report the missing dependency.

### Failure containment rule

Do not layer speculative fixes.

A failed implementation hypothesis may be attempted no more than three consecutive times.

After three failed attempts under the same hypothesis, return to the last stable state and use a materially different approach.

If a failure does not clearly indicate the next action, stop rather than adding speculative changes.

## Authorized Frontend Scope

Primary authorized files:

- `client/src/shell/MissionDashboardWorkspace.tsx`
- `client/src/shell/mission-dashboard.css`
- `client/src/shell/mission-dashboard-presentation.css`
- `client/src/mission-control/missionReadApi.ts`
- `client/src/mission-control/missionPresentationMapper.ts`

Modification of `missionReadApi.ts` is permitted only when required for frontend typing or consumption of fields already returned by the existing API.

No API endpoint, response contract, backend route, repository, assembler, or database change is authorized.

## Explicitly Out of Scope

Do not modify:

- `routes/api-mission-read.ts`
- Mission Read backend repositories
- Mission Read assemblers
- database files
- schema files
- migrations
- governance runtime
- package runtime
- delegation runtime
- envelope runtime
- assignment runtime
- execution runtime
- review runtime
- project registry
- project context
- conversation runtime
- provider architecture
- route architecture
- unrelated workspaces
- disaster recovery tooling
- semantic drift tooling
- repository-wide styling systems unless already included in the bounded bundle

## Required Presentation Architecture

### Executive Brief

Replace the existing Current Mission identification card with an executive briefing that communicates mission objective, current stage, health, and concise context while relegating package identity and version to secondary metadata.

### Mission Status

Provide a compact operational summary using only authoritative state.

### Mission Progress

Implement the seven-stage operational lifecycle projection while keeping it distinct from Governance History.

### Latest Event

Surface the most recent authoritative event in concise executive language.

### Next Step

Display only safely derived next actions or an explicit "Not yet determined" state.

### Active Agent / Current Owner

Display authoritative ownership only.

### Mission Pipeline

Represent organizational movement only when supported by authoritative data.

### Package Details

Display compact package metadata without overwhelming the page.

### System Overview

Show authoritative aggregate telemetry when available, otherwise explicitly defer it.

### Governance History

Preserve the authoritative chronological evidence record without transforming it into operational meaning.

## Visual Scale

Reduce:

- page padding,
- card padding,
- hero height,
- oversized headings,
- excessive vertical spacing,
- tablet-like proportions.

Target a dense executive workstation rather than a marketing layout.

## Implementation Sequence

1. Baseline and scope verification.
2. Presentation model audit.
3. Structural recomposition.
4. Executive Brief.
5. Mission Status.
6. Mission Progress.
7. Executive action cards.
8. Supporting cards.
9. Visual reconciliation.
10. Validation.

## Validation

Claude must:

- run the client production build,
- run the semantic drift guard,
- run `git diff --check`,
- verify only authorized files changed,
- verify loading, error, empty, populated, and not-found states,
- verify desktop responsiveness,
- verify Mission Progress remains distinct from Governance History.

## Definition of Done

Mission Control Presentation v1 is complete only when:

- Executive Brief replaces Current Mission.
- Mission Status communicates authoritative operational state.
- Mission Progress is operational rather than historical.
- Governance History remains a chronological evidence surface.
- Executive action cards are useful and semantically honest.
- Supporting cards match the approved presentation where authoritative data exists.
- Missing information is explicitly represented rather than invented.
- Desktop density matches the approved mockup.
- Existing Mission Read runtime states remain intact.
- Client build passes.
- Semantic drift guard passes.
- `git diff --check` passes.
- Only authorized frontend files changed.
- No backend architecture changed.
- No governance semantics changed.
- No operational authority was invented.
