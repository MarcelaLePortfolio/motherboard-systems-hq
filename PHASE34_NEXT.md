# Phase 34 — Objectives & Direction

## Purpose
Define the next stability milestone for the worker system without implementing it yet.

Phase 33 established that dockerized workers can:
- Claim delegated tasks
- Coordinate safely across multiple containers
- Emit stable string-based task_ids
- Complete tasks without duplicate terminal events

Phase 34 will build on this foundation.

## High-Level Objective
Make the worker system **crash-safe and self-healing** by introducing task leases and reclaim behavior so that:
- A task claimed by a worker that crashes or stalls can be safely reclaimed
- Only one terminal outcome (completed/failed) can ever be recorded per task
- Multi-worker operation remains deterministic under failure conditions

## Intended Scope (no implementation yet)
- Task leasing / lease expiration model
- Reclaiming stale `running` tasks
- Heartbeat or lease extension mechanism
- Database-enforced guarantees against duplicate terminal events
- Deterministic verification of reclaim behavior (e.g. kill a worker mid-task)

## Explicit Non-Goals (for Phase 34)
- No new agent logic
- No scheduler redesign
- No performance optimization
- No UI changes

## Readiness Criteria to Begin Phase 34
- Phase 33 golden tag is in place ✅
- feature/phase34-next is branched from the golden tag ✅
- Phase 34 objectives are documented (this file) ✅

