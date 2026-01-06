# Phase 17 — Orchestration Spec (Working Draft)

## 1) Task State Machine + Transition Rules

Minimum Task fields:
- id, kind
- createdAt, updatedAt (epoch ms)
- state (enum)
- priority (number)
- attempts, maxAttempts
- dependsOn (string[])
- payload (json)
- lastError (string|null)

States:
- DRAFT, QUEUED, ROUTED, RUNNING, WAITING, RETRY_WAIT, SUCCEEDED, FAILED, CANCELED

Allowed transitions:
- DRAFT -> QUEUED
- QUEUED -> ROUTED
- ROUTED -> RUNNING
- RUNNING -> WAITING
- WAITING -> QUEUED
- RUNNING -> RETRY_WAIT
- RETRY_WAIT -> QUEUED
- RUNNING -> SUCCEEDED
- RUNNING -> FAILED
- * -> CANCELED (operator only; except terminal)

Deliverable (17.1):
- transition validator + pure reducer
- unit tests for allowed/blocked transitions

## 2) Event → Policy → Task Loop
- Ingest events → normalize → apply policy pipeline → commit → emit outputs

## 3) Routing + Task Dependencies
- Block tasks until dependsOn are SUCCEEDED
- Route based on kind/capabilities + agent availability + operator constraints

## 4) Scheduling / Throttling
- global/per-agent/per-kind caps
- backoff + jitter for retries

## 5) Operator “Mode/Intent” Commands
- modes: NORMAL, SAFE, FOCUS, PAUSE, DRAIN, DEBUG
- commands: mode set, intent set, queue pause/resume, task cancel/retry, budget set
