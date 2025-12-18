
# Phase 14 — Ops Reliability + Cadence Hardening

Baseline:

* Tag: v13.5.7-compose-warning-gone
* Status: Phase 13.5 complete

Primary outcome:
Make Motherboard Systems HQ feel “boringly reliable” in day-to-day operator use:

* No phantom tasks
* Clear task lifecycle
* Strong validation + cleanup
* Audit trail that proves what happened and why
* Minimal UI confusion when SSE / backend is unavailable

---

## Phase 14.1 — Task lifecycle contract (source of truth)

Deliverables:

* Define canonical task states and transitions:

  * queued → delegated → running → blocked → complete → canceled → failed
* Define required fields (minimum payload contract):

  * id, title, agent, status, created_at, updated_at
  * optional: notes, source, trace_id, error
* Define API expectations:

  * create/delegate, update, complete, cancel
  * idempotency rules where relevant (avoid duplicate tasks)

Acceptance checks:

* A single task cannot “complete” without a known id.
* Updates cannot regress state (e.g., complete → running).
* UI never shows blank/undefined critical fields.

---

## Phase 14.2 — Server-side validation + defensive writes

Deliverables:

* Input validation for task endpoints (reject bad payloads early)
* Normalize ids to a consistent type across DB + API + UI
* Ensure created_at/updated_at always set server-side

Acceptance checks:

* Invalid requests return clear 4xx with message
* DB rows are never created with missing required fields
* update timestamps always reflect last change

---

## Phase 14.3 — Change-detect + SSE robustness

Deliverables:

* Reduce noisy SSE updates (emit only on meaningful change)
* Ensure SSE stream closes cleanly and does not leak handlers
* Ensure UI gracefully handles:

  * SSE disconnected
  * SSE connected but idle
  * backend down / 404 endpoints

Acceptance checks:

* No runaway network activity when dashboard left open
* Reconnect behavior is sane (no duplicate listeners)
* UI status indicators always reflect “unknown/offline/online” accurately

---

## Phase 14.4 — Operator UX: validation, cleanup, and audit

Deliverables:

* “Last action” + “last error” surfaced in a compact operator-friendly way
* Add a lightweight audit log entry on key actions:

  * delegated, updated, completed, canceled, failed
* Add cleanup rules:

  * stale “running” tasks can be marked “blocked” after N minutes (optional toggle)
  * consistent handling for “unknown agent”

Acceptance checks:

* Operator can explain any task outcome by reading audit entries
* No silent failures: errors are visible and traceable

---

## Phase 14.5 — Golden baseline + rollback airbag

Deliverables:

* New stable tag at end of Phase 14 once checks pass
* A single “resume/verify” script to confirm health quickly

Acceptance checks:

* One command can verify ports, API endpoints, and SSE basic behavior
* Tag created and pushed

---

## Guardrails (no-drama upgrades)

* One issue per push. No patch cascades.
* If we hit 3 consecutive “failed build” attempts on a hypothesis: revert to last stable tag/commit and switch approach.
* Prefer small diffs + quick verification loops.
  EOF

cat > "scripts/phase14_resume_from_v13_5_7.sh" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "────────────────────────────────────────────"
echo " Phase 14 – Resume + Quick Verification"
echo "────────────────────────────────────────────"
echo

echo "1) Git status"
git status
echo

echo "2) Docker: rebuild + start"
docker compose down || true
docker compose up -d --build
echo

echo "3) Health checks (adjust ports if needed)"
set +e
curl -fsS "[http://127.0.0.1:8080/dashboard](http://127.0.0.1:8080/dashboard)" >/dev/null && echo "✅ dashboard ok (8080)" || echo "⚠️ dashboard not reachable (8080)"
curl -fsS "[http://127.0.0.1:8080/api/tasks](http://127.0.0.1:8080/api/tasks)" >/dev/null && echo "✅ /api/tasks ok" || echo "⚠️ /api/tasks not reachable"
set -e
echo

echo "4) SSE smoke (5s) — ensure no persistent curl remains"
( timeout 5 curl -N "[http://127.0.0.1:8080/events/tasks](http://127.0.0.1:8080/events/tasks)" || true ) >/dev/null 2>&1
echo "✅ SSE smoke done (5s)"
echo

echo "5) Show docker ps"
docker ps
echo
echo "Done."
