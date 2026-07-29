# Mission Control Mockup Translation Map

## Purpose

This document converts the approved Mission Control mockup into an implementation blueprint before further React or CSS changes occur.

The mockup is authoritative for information hierarchy, card geometry, visual grouping, executive reading order, and user attention flow.

Runtime truth remains authoritative for the values displayed inside those regions.

---

# Executive Reading Order

Mission Control should answer these questions in order:

1. What mission is active?
2. Where is it right now?
3. What just happened?
4. What happens next?
5. Who owns it?
6. Is anything unhealthy?
7. What operational details are available?

The frontend should be organized around answering these questions—not around exposing backend fields.

---

# Region Mapping

## Header

Purpose:
Workspace identity.

Contains:
- Mission Control title
- Subtitle
- Future "New Mission" action

Runtime:
Static.

---

## Current Mission (Dominant Card)

Purpose:
Anchor the entire dashboard.

Contains:
- Mission name
- Mission objective
- Horizontal governance progression

Runtime:
Mission Read.

Rule:
The lifecycle belongs inside this card.

---

## Mission Status

Purpose:
Summarize current operational state.

Contains:
- Current stage
- Health
- Owner (only if authoritative)

Placeholder:
Owner may display "Not Assigned".

Never invent an owner.

---

## Latest Event

Purpose:
Display the newest authoritative lifecycle event.

Runtime:
Latest Mission Read lifecycle event.

---

## Next Step

Purpose:
Display the next authoritative governance action.

Placeholder:
"No authoritative next step reported."

Never fabricate assignment countdowns.

---

## Mission Pipeline

Purpose:
Operational position.

This is NOT the lifecycle history.

Pipeline answers:
"Where are we?"

History answers:
"What happened?"

Future stages may appear visually but must be clearly marked as unavailable until runtime exists.

---

## Event Feed

Purpose:
Chronological history.

Runtime:
Mission Read lifecycle events.

---

## Package Details

Purpose:
Metadata only.

Runtime:
Mission Read package metadata.

---

## Active Agent

Purpose:
Current authoritative owner.

Placeholder:
Not Assigned.

Never invent Cade, Engineering, execution percentages, or task progress.

---

## System Overview

Purpose:
Overall organization health.

Current status:
Deferred.

May exist visually as a placeholder, but must not display fabricated health or telemetry.

---

# Implementation Rule

Future implementation begins by reproducing this structure first.

Only after structural parity is achieved should spacing, colors, typography, and visual polish be refined.

