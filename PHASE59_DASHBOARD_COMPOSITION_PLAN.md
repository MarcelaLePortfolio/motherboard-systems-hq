# Phase 59 — Dashboard Composition & Presentation Pass

## Purpose
Phase 59 focuses exclusively on UI composition and presentation clarity for the orchestration dashboard.

All backend behavior, schema, SSE logic, lifecycle logic, and policy mechanics are already complete and must not change.

This phase converts the stable operator observability surface into a cohesive operator console layout.

No architecture expansion is allowed.

---

# Guardrails (STRICT)

Do NOT:
- Modify backend APIs
- Modify task lifecycle
- Modify policy system
- Add new data sources
- Change schema
- Modify SSE mechanics
- Touch regression harness
- Touch snapshot smoke
- Touch CI

Allowed changes:
- Layout composition
- Panel hierarchy
- Visual grouping
- Empty state messaging
- Panel container structure
- Dashboard readability improvements

---

# Target Outcome

The dashboard should read visually as a single intentional operator console rather than a collection of development panels.

An operator should be able to determine system state within 2–3 seconds of opening the dashboard.

---

# Phase 59 Composition Goals

## 1 — Establish Console Layout Grid

Define a stable visual hierarchy.

Top:
System Status / Run Lifecycle

Middle:
Live Event Stream

Bottom:
Secondary Panels (Reflections / OPS / diagnostics)

---

## 2 — Operator Header Section

Add a clear top-level console header.

Example:

Operator Console  
Run ID: policy.probe.run  
System Status: RUNNING

This becomes the primary visual anchor of the dashboard.

---

## 3 — Run Lifecycle Card (Primary Panel)

This panel remains visually dominant.

It should show:
- Run ID
- Task ID
- Current status
- Last event
- Terminal state (when reached)

This is the first panel an operator reads.

---

## 4 — Event Stream Panel

Keep the existing improvements:
- human-speed event flow
- grouped heartbeats
- readable lifecycle progression

Visually anchor it as the central console feed.

The event stream should resemble a log console rather than a debug dump.

---

## 5 — Secondary Panels

Panels:
- Reflections
- OPS
- Legacy debug panels

These should appear as secondary diagnostics rather than core console information.

Possible treatments:
- collapsed by default
- placed in a lower section
- tabbed grouping

---

## 6 — Empty State Design

Empty states should read as intentional console states rather than unfinished sections.

Example tone:
"Awaiting system activity."

Avoid:
"No data."

---

## 7 — Remove Visual Noise

Remove or soften:
- duplicate headers
- debug labels
- developer terminology

Replace with operator-friendly terminology.

---

# Acceptance Criteria

Phase 59 is complete when:

- Dashboard reads as a single operator console
- Run lifecycle panel is visually dominant
- Event stream is central and readable
- Secondary panels are visually contained
- Empty states appear intentional
- Dashboard feels stable and composed
- No backend behavior changed

---

# Deliverable

Operator opens console and immediately sees:

1. System status
2. Current run
3. Lifecycle progression
4. Event stream
5. Secondary diagnostics

All within a visually coherent layout.

---

# Resulting Milestone

If Phase 59 completes successfully, cut:

v59.0-dashboard-console-golden

This represents the first fully composed orchestration console milestone.

