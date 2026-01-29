# Phase 34 — Lease / Heartbeat / Reclaim (crash-safe workers)

Status
- Start point: v33.0-phase33-delegated-claim-docker-golden (Phase 33 done + golden).
- Branch: feature/phase34-next (branched from golden tag).
- Scope guardrails (hard):
  - NO UI changes
  - NO scheduler changes
  - NO perf work
  - ONLY crash-safety + self-healing for worker claims via lease/heartbeat/reclaim
- Phase 34 is behind an explicit SQL+schema contract and must be verifiable deterministically (reclaim-kill).

---

## 0) First action in a new thread: prove Phase 33 still passes (smoke)

Run:
  bash scripts/phase33_smoke.sh

Pass criteria:
- API create works (task row created).
- SSE /events/task-events emits hello + heartbeat and (if workers running) shows task lifecycle events.
- Workers containerized can claim/complete at least one trivial task (or at minimum, claim without breaking invariants).

---

## 1) Phase 34 objective

Make worker claiming crash-safe and self-healing via:
- a lease (expires_at)
- a worker heartbeat (last_seen_at)
- a reclaim operation that deterministically re-queues tasks whose lease expired OR whose owner is dead
- deterministic verification without real process kills

---

## 2) Phase 34 SQL + schema contract

Minimal additions:
- tasks: claimed_by, claimed_at, lease_expires_at, lease_epoch
- worker_heartbeats table

---

## 3) Phase 34 SQL files

- server/worker/phase34_claim_one.sql
- server/worker/phase34_heartbeat.sql
- server/worker/phase34_reclaim_stale.sql
- server/worker/phase34_kill_owner_for_test.sql

---

## 4) Deterministic verification

Run:
  bash scripts/phase34_reclaim_kill_verify.sh

Must print PASS.

---

## 5) Sequencing

Commit 1:
- Docs + scripts + SQL contract

Commit 2:
- Worker wiring behind env flags

Commit 3:
- Optional invariants (lease_epoch enforcement)

