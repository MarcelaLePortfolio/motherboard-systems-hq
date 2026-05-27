# Phase 58B — Probe Lifecycle Visibility

## Objective
Make the probe lifecycle visually obvious in the dashboard using existing backend data only.

## Scope
Dashboard/UI only.

Do **not** modify:
- backend APIs
- task lifecycle logic
- policy system
- database schema

Use existing surfaces only:
- /api/health
- /api/runs
- task events stream

## Problems Observed
1. Probe run exists but is not visually emphasized.
2. Operators must mentally parse raw fields to understand progression.
3. Lifecycle state is present but not presented as an intentional story.

## Goals
1. Surface the probe run as a first-class status card.
2. Present lifecycle progression in a simple, human-readable sequence.
3. Make terminal vs non-terminal state obvious at a glance.
4. Tie recent events to the probe run without requiring raw log reading.

## Implementation Guidance

### 1. Probe Run Summary Card
Display a dedicated panel for the probe run showing:

- run id
- task id
- actor
- task status
- last event kind
- last event timestamp
- terminal state

### 2. Lifecycle Presentation
Represent lifecycle as a small ordered progression using existing state only.

Suggested stages:
- visible
- running
- policy checked
- terminal

If a stage cannot be confirmed from current data, show it as inactive rather than inferred.

### 3. Terminal Clarity
Terminal state should be visually obvious.

Examples:
- terminal reached
- still active

### 4. Timestamp Legibility
Convert timestamps into a compact operator-friendly format.

Example:
- 12:04:31 PM
- updated 8s ago

### 5. Event Association
Within the event panel, visually emphasize events associated with:
- run=policy.probe.run

This may be done with:
- grouping
- pinning
- filtering highlight
- a "recent probe events" subsection

Do not hide the broader stream if it is still needed for operator context.

## Demo Success Criteria
An operator should be able to answer within seconds:

1. Is the probe run present?
2. What state is it currently in?
3. What was the latest meaningful event?
4. Has it reached terminal state?

## Out of Scope
- new backend endpoints
- new lifecycle fields
- backend inference logic
- policy changes

## Next Phase
Phase 58C — Empty States & Cold-Start Presentation
