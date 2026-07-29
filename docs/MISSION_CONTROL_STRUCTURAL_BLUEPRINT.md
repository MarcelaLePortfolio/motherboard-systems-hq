# Mission Control Structural Blueprint

## Purpose

This document freezes the structural composition of Mission Control before any additional React or CSS work occurs.

The approved mockup is authoritative for:

- card geometry,
- layout proportions,
- grouping,
- executive reading order,
- information hierarchy.

Mission Read and future runtime systems remain authoritative only for the data displayed within those regions.

---

# Executive Reading Order

Mission Control should answer these questions in this order:

1. What mission is active?
2. Where is it now?
3. What changed most recently?
4. What happens next?
5. Who owns it?
6. Is anything unhealthy?
7. What operational detail is available?

This reading order is an architectural invariant.

---

# Structural Layout

## Header

Spans full width.

Contains:

- Mission Control title
- subtitle
- refresh action
- future New Mission action

---

## Row One

### Current Mission

Largest card.

Occupies approximately 75% of the row.

Contains:

- mission identity
- mission objective
- version
- horizontal lifecycle progression

The lifecycle is part of this card.

It must never become a separate vertical panel.

### Mission Status

Occupies remaining width.

Contains:

- current stage
- health
- owner
- estimate (placeholder until authoritative)

---

## Row Two

### Latest Event

Compact supporting card.

Contains:

- latest lifecycle event
- timestamp

### Next Step

Dominant supporting card.

Contains:

- authoritative awaiting state
- honest placeholder when unavailable

---

## Row Three

### Mission Pipeline

Large horizontal operational card.

Purpose:

Show current operational position.

Not historical sequence.

Pipeline answers:

"Where are we?"

History answers:

"What happened?"

### Active Agent

Narrow supporting card.

Displays:

- authoritative owner
- or Not Assigned

Never inferred.

---

## Row Four

### Package Details

Authoritative metadata only.

### System Overview

Placeholder until telemetry exists.

Must never fabricate health, uptime, or availability.

---

# Runtime Classification

Every visible region must be one of:

- Authoritative
- Derived
- Placeholder
- Deferred

A region may never silently change classifications.

---

# Authorized Implementation Scope

Only:

- client/src/shell/MissionDashboardWorkspace.tsx
- client/src/shell/mission-dashboard.css

No backend, provider, Mission Read, persistence, governance, telemetry, or shell architecture changes.

---

# Acceptance Criteria

Structural work is complete only when:

- Current Mission dominates the layout.
- Mission Status sits beside it.
- Lifecycle is horizontal and inside Current Mission.
- Latest Event and Next Step match the approved proportions.
- Mission Pipeline is horizontal and distinct from event history.
- Package Details, Active Agent, and System Overview occupy the approved lower regions.
- Unsupported capabilities remain explicit placeholders.
- Client build passes.
- Semantic drift guard passes.
- Browser review confirms structural parity before visual polish begins.

