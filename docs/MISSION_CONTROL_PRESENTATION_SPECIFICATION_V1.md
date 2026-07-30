# Mission Control Presentation Specification v1

## Status

Approved design direction for the Mission Control Presentation Program.

This document defines the target executive experience represented by the approved Mission Control visual mockup. The mockup is to be treated as a presentation specification rather than general inspiration.

Implementation must preserve the authoritative runtime, Mission Read architecture, governance boundaries, project context, conversation architecture, and existing safety corridors.

---

## 1. Product Intent

Mission Control is the executive interface into Motherboard Systems HQ.

It should allow the user to understand, at a glance:

1. What mission is active.
2. What outcome the organization is pursuing.
3. Where the mission is in the operational workflow.
4. What has just happened.
5. What happens next.
6. Who currently owns the work.
7. Whether anything is blocked or unhealthy.
8. Whether the organization itself is operating normally.
9. What authoritative evidence supports the displayed state.

The interface should feel like an executive briefing inside an operating organization, not a developer dashboard, database viewer, or generic status page.

---

## 2. Design Principles

### 2.1 Executive usefulness before technical completeness

Primary cards should answer executive questions.

Technical identifiers, counts, timestamps, and evidence remain available, but they should support the briefing rather than dominate it.

### 2.2 Operational state before historical audit

The primary progress visualization should show where the mission currently sits in the organizational workflow.

Historical governance events remain valuable but should appear as supporting evidence rather than substitute for operational progress.

### 2.3 Authoritative data only

Mission Control must not invent progress, ownership, deadlines, health, or completion.

When authoritative data is unavailable, use an explicit unavailable, unassigned, pending, or not-yet-recorded state.

### 2.4 Compact information density

The approved mockup is designed for efficient desktop scanning.

Cards should not use oversized typography, excessive vertical padding, or touch-interface proportions.

### 2.5 Visual hierarchy should reflect decision value

The largest and most visually prominent elements should communicate:

- mission objective,
- current operational stage,
- health,
- ownership,
- next action.

Supporting metadata should receive less visual weight.

---

## 3. Page-Level Structure

The intended desktop composition is:

1. Mission Control page header.
2. Executive Brief hero card.
3. Mission Status summary card.
4. Mission Progress operational tracker.
5. Latest Event card.
6. Next Step card.
7. Active Agent or Current Owner card.
8. Mission Pipeline card.
9. Package Details card.
10. System Overview card.
11. Authoritative Event Feed or Governance History.

The layout may adapt responsively, but desktop presentation should remain compact and information-rich.

---

## 4. Card Specifications

### 4.1 Executive Brief

**Mockup counterpart**

Current Mission.

**Purpose**

Provide the highest-value summary of the active mission.

**Executive questions answered**

- What are we trying to accomplish?
- Why does it matter?
- Where is the mission now?
- Is it progressing normally?
- What should I understand before reading further?

**Required content**

- Human-readable mission title.
- Mission objective or requested outcome.
- Current operational stage.
- Mission health.
- Package version or revision, visually secondary.
- Concise progress context.
- Optional compact progress indicator when authoritative.

**Current implementation gap**

The existing Current Mission card contains:

- formatted package ID,
- version,
- generic governance sentence.

This is an identification card rather than an executive brief and is materially lower-value than the mockup counterpart.

**Data mapping**

| Field | Preferred source | Current status |
|---|---|---|
| Mission title | Canonical package title or human-readable requested outcome | Mapping required |
| Objective | Canonical package requested outcome | Repository capability exists; projection verification required |
| Current stage | Mission Read | Available |
| Health | Mission Read | Available |
| Version | Mission Read identity | Available |
| Progress context | Mission Read plus operational mapper | Mapping required |

**Visual behavior**

- Large but compact hero card.
- Mission title should not dominate the entire viewport.
- Objective should be readable without opening another view.
- Version should appear as secondary metadata.
- Avoid placeholder prose.

---

### 4.2 Mission Status

**Purpose**

Provide a concise executive snapshot of current mission condition.

**Required content**

- Current stage.
- Health.
- Current owner.
- Started timestamp.
- Estimated completion only when authoritative.
- Blocking state when present.

**Current implementation gap**

The current card shows:

- stage,
- health,
- generic explanatory copy.

It does not yet provide the richer summary represented in the mockup.

---

### 4.3 Mission Progress

**Mockup counterpart**

The horizontal operational lifecycle shown inside the approved visual.

**Purpose**

Show where the mission currently sits in the organization's end-to-end operational workflow.

**Executive question answered**

Where is the mission now, and what remains before completion?

**Canonical stages**

1. Intent.
2. Governance.
3. Envelope.
4. Assignment.
5. Execution.
6. Review.
7. Complete.

**Important distinction**

Mission Progress is not the same as Governance History.

Mission Progress is an operational state model.

Governance History is a chronological evidence record.

**Current implementation gap**

The existing Governance Lifecycle card maps chronological timeline entries directly into a horizontal row.

That preserves real evidence but does not provide the operational progress model shown in the mockup and is therefore lower-value as the primary lifecycle visualization.

---

### 4.4 Latest Event

**Purpose**

Answer: What just happened?

**Required content**

- Latest authoritative event.
- Timestamp.
- Optional actor.
- Optional consequence.

---

### 4.5 Next Step

**Purpose**

Answer: What happens next?

**Required content**

- Next required action.
- Responsible department.
- Waiting condition.
- Progress when authoritative.

**Current implementation gap**

The current card falls back to generic placeholder language rather than communicating the organization's actual next move.

---

### 4.6 Active Agent / Current Owner

**Purpose**

Show who currently owns mission progress.

**Required content**

- Agent or department.
- Organizational role.
- Responsibility.
- Status.
- Progress.

**Current implementation gap**

The current card shows only ownership, while the mockup communicates active responsibility within the organization.

---

### 4.7 Mission Pipeline

**Purpose**

Show how work flows through the organization.

Mission Pipeline and Mission Progress are related but intentionally different concepts.

---

### 4.8 Package Details

Provide compact authoritative metadata while keeping technical information visually secondary.

---

### 4.9 System Overview

Provide confidence that Motherboard Systems HQ itself is healthy.

No speculative metrics.

---

### 4.10 Governance History

Preserve the authoritative chronological audit trail.

This is intentionally separate from Mission Progress.

---

## 5. Information Hierarchy

### First glance

- Mission objective.
- Current stage.
- Health.
- Owner.
- Next action.

### Second glance

- Operational progress.
- Latest event.
- Mission pipeline.
- Blocking conditions.

### Supporting evidence

- Package details.
- Governance history.
- Artifact counts.
- Integrity warnings.
- System overview.

---

## 6. Visual Scale

The implementation should match the mockup's compact desktop density.

Reduce:

- page padding,
- card padding,
- hero height,
- typography scale,
- vertical spacing.

Mission Control should resemble an executive workstation rather than a tablet interface.

---

## 7. Architectural Boundaries

Presentation work must not:

- redesign Mission Read,
- redesign governance,
- invent operational state,
- invent ownership,
- invent progress,
- bypass authoritative projections,
- merge operational and audit concepts.

---

## 8. Implementation Sequence

1. Match page composition.
2. Replace Current Mission with Executive Brief.
3. Introduce Mission Progress.
4. Refine Latest Event, Next Step, and Active Agent.
5. Add Mission Pipeline.
6. Refine Package Details.
7. Add System Overview.
8. Final reconciliation against the approved mockup.

---

## 9. Claude Role

Claude receives:

- this specification,
- the approved mockup,
- only the minimum frontend files,
- explicit validation commands.

Claude implements.

Claude does not reinterpret architecture.

---

## 10. Definition of Done

Mission Control Presentation Specification v1 is complete when:

- the composition closely matches the approved mockup,
- the information hierarchy matches executive priorities,
- Current Mission has become a true Executive Brief,
- Mission Progress replaces the current lower-value lifecycle visualization,
- Governance History remains available,
- all displayed information is authoritative,
- Mission Read remains unchanged,
- governance remains unchanged,
- the client build passes,
- semantic drift checks pass,
- unrelated repository files remain untouched.
