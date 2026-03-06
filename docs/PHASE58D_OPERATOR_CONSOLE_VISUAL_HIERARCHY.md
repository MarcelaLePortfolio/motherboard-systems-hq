# Phase 58D — Operator Console Visual Hierarchy

## Objective
Refine the dashboard into an intentional operator console with clear visual hierarchy, balanced layout, and confidence-building observability.

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
- /api/tasks
- task events stream

## Problems Observed
1. The layout still reads like a debug surface.
2. Primary signals are not visually prioritized enough.
3. Secondary information competes with core lifecycle visibility.
4. The dashboard needs a more deliberate operator-console feel.

## Goals
1. Establish a strong primary-to-secondary visual hierarchy.
2. Make health and probe lifecycle the top visual priority.
3. Give events a contained, readable supporting role.
4. Ensure spacing, alignment, and card weight feel intentional.
5. Preserve observability while reducing visual chaos.

## Implementation Guidance

### 1. Information Priority
Organize the screen in this order:

1. system health
2. probe lifecycle status
3. recent meaningful events
4. secondary panels / idle areas

### 2. Card Hierarchy
Use card sizing and placement to communicate importance.

Preferred emphasis:
- largest/most prominent: health + probe run status
- medium prominence: event stream
- lighter prominence: secondary panels and placeholders

### 3. Typography Hierarchy
Ensure the UI clearly distinguishes:
- section titles
- key statuses
- supporting metadata
- timestamps / IDs

Important state text should be immediately scannable.

### 4. Event Panel Role
The event stream should support the operator, not dominate the screen.

Improve:
- containment
- scroll behavior
- density
- row readability
- emphasis on meaningful lifecycle transitions

### 5. Layout Balance
Improve:
- horizontal balance
- vertical rhythm
- consistent padding
- section spacing
- alignment between panels

The screen should feel structured and calm on first glance.

### 6. Debug Surface Reduction
Reduce the sense that the operator is looking at leftover diagnostics.

This may include:
- clearer labels
- tighter grouping
- more intentional empty-state framing
- reduced visual prominence of noisy or low-priority signals

## Demo Success Criteria
An operator viewing the dashboard should immediately feel that:

1. the system is healthy and under control
2. the probe lifecycle is the primary live story
3. the event stream is useful and readable
4. the interface looks intentional enough for demo use

## Out of Scope
- backend changes
- new endpoints
- lifecycle inference changes
- policy changes
- feature expansion

## Completion Note
At the end of Phase 58D, the backend demo-hardening corridor remains unchanged, and the dashboard should now read as an operator-facing console rather than a debug surface.
