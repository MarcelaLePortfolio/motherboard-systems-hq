# Phase 58A — Event Stream Containment & Legibility

## Objective
Reduce noise dominance from the policy probe event stream and improve operator readability of the dashboard without modifying backend systems.

## Scope
Dashboard/UI only.

Do **not** modify:
- backend APIs
- task lifecycle logic
- policy system
- database schema

Use only the existing endpoints:
- /api/health
- /api/runs
- /api/tasks
- task events stream

## Problems Observed
1. Floating **Task Events** box dominates screen.
2. Policy probe events stream too rapidly.
3. Event feed resembles a debug log rather than an operator console.
4. Important lifecycle signals are visually buried.

## Goals
1. Contain the event feed to a dedicated panel.
2. Introduce readable formatting for events.
3. Slow visual churn so humans can follow lifecycle progression.
4. Surface lifecycle milestones clearly.

## Implementation Guidance

### 1. Contain Event Feed
Move the event stream into a fixed dashboard panel rather than a floating overlay.

Preferred layout:

Left column
- System Health
- Run Summary

Right column
- Event Stream Panel

### 2. Event Formatting
Each event row should clearly show:

timestamp  
event kind  
actor  
run id

Example:

[12:04:31] policy.probe.allowed  actor=policy.probe  run=policy.probe.run

### 3. Visual Hierarchy
Apply visual emphasis:

High priority
- task.started
- task.completed
- task.failed

Medium priority
- task.running
- heartbeat

Low priority
- policy probe spam events

### 4. Noise Reduction
Do **not** drop events.

Instead:
- collapse repetitive probe events
- group bursts of identical events
- optionally show a counter

Example:

policy.probe.allowed × 24

### 5. Event Rate Protection
Limit rendering rate so UI does not scroll uncontrollably.

Target:
max ~5–10 visible updates per second

### 6. Operator Visibility
The dashboard should make the following obvious:

- system healthy
- probe run exists
- lifecycle progression visible
- event stream readable

## Demo Success Criteria
Fresh boot should allow an operator to confirm:

1. system health
2. probe run visible
3. lifecycle progressing
4. events readable at human speed

## Out of Scope
- backend features
- schema changes
- policy behavior
- new endpoints

## Next Phase
Phase 58B — Probe Lifecycle Visibility
