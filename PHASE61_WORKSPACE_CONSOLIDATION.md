# PHASE 61 — WORKSPACE CONSOLIDATION

## Purpose
Transition the dashboard from stacked vertical panels into a two-workspace operator layout that reduces scrolling and supports a full-viewport operational workflow.

Phase 61 restructures the **middle dashboard region only** while preserving all existing backend behavior, SSE streams, and Phase 60 visual polish.

No backend changes are allowed.

---

# Design Goal

Move from:

Stacked panel dashboard

to

Operator workspace model supporting the loop:

observe → decide → instruct → observe

---

# Target Layout

Header  
Agent Pool  
Metrics Row

------------------------------------------------------------

[ Control Workspace ]      [ Observation Workspace ]

------------------------------------------------------------

Subsystem Status Band (Atlas / subsystem health)

---

# Workspace Definitions

## Control Workspace
Operator interaction surfaces.

Contains:

• Matilda Chat  
• Task Delegation

Purpose:

Allow operator to **issue instructions and interact with the system** without scrolling away from telemetry.

Future extensibility:

Tabs or segmented controls inside workspace.

---

## Observation Workspace
System telemetry and task monitoring.

Contains:

• Recent Tasks  
• Task Activity Over Time

Purpose:

Provide a continuous **observability surface** for system activity.

---

## Subsystem Status Band

Full-width passive system telemetry.

Contains:

• Atlas subsystem status
• subsystem indicators

Purpose:

Quiet system health visibility without dominating the interface.

---

# Phase 61 Structural Strategy

Preferred approach:

HTML regrouping + CSS grid.

Avoid:

• runtime DOM injection
• overlay logic
• layout mutation scripts
• dynamic widget mounting

Use deterministic layout structure instead.

---

# Proposed HTML Structure

.dashboard-main

  .operator-workspace-grid

      .workspace.workspace-control
          Matilda
          Delegation

      .workspace.workspace-observe
          Recent Tasks
          Task Activity

  .subsystem-status-band
      Atlas subsystem panel

---

# CSS Layout Model

Use a two-column grid:

grid-template-columns: 1fr 1fr

Behavior:

• equal width workspaces
• maintain responsive collapse on smaller screens
• preserve current card styling language

Sub-panels inside workspace should stack vertically.

---

# Non-Goals

Do NOT:

• change backend endpoints
• modify SSE logic
• alter task lifecycle
• introduce collapsible sections yet
• add animations or cinematic UI
• expand architecture

---

# Implementation Plan

Step 1 — Introduce workspace grid container  
Step 2 — Move existing panel containers into workspace groups  
Step 3 — Ensure telemetry panels maintain height balance  
Step 4 — Preserve existing CSS polish from Phase 60  
Step 5 — Confirm dashboard loads with no JS errors  
Step 6 — Confirm SSE panels remain connected  
Step 7 — Verify no regression in event stream rendering

---

# Safety Rules

Maintain:

• static HTML structure
• CSS layout changes only
• existing bundle.js behavior unchanged

---

# Verification Checklist

After implementation:

Dashboard must still show:

• probe lifecycle card  
• probe run id visible  
• SSE streams connected  
• event stream readable  
• Matilda console functional  
• delegation console functional  
• task telemetry visible  

No regressions allowed.

---

# Future Extension (NOT in Phase 61)

Possible later improvements:

• workspace tabs
• telemetry filters
• collapsible subsystem band
• workspace resizing

These are **Phase 62+ considerations**.

---

# Phase 61 Definition of Done

Dashboard loads and displays:

Header  
Agent Pool  
Metrics Row  

Two workspaces side-by-side:

Control Workspace | Observation Workspace

Subsystem band remains full-width.

Operator can:

observe → instruct → observe

without vertical scrolling.

