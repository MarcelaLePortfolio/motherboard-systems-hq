
PHASE 719 NEXT CORRIDOR PLAN

Current baseline:

- Phase 718 operator lineage/title UI is stable.

- Runtime is healthy.

- Phase 719 session start and cleanup are complete.

- External archive backup completed at source-95941e7e.

- Current HEAD after cleanup: 3c07eaaf.

Recommended next corridor:

PHASE 719 — FAILURE CLASSIFICATION AND OPERATOR TRIAGE VISIBILITY

Goal:

Improve Recent Tasks operator understanding without changing execution semantics.

Safe scope:

1. Renderer-only read-only enhancements.

2. Use existing task/status/event fields only.

3. Add lightweight failure/success classification labels where evidence already exists.

4. Improve task card triage clarity.

5. Preserve retry/requeue controls exactly as implemented.

6. Preserve Phase 718 lineage/title behavior.

7. Preserve Task History.

8. Preserve /execution-evidence.html as secondary audit surface.

9. No DB schema changes.

10. No backend retry contract changes.

11. No worker execution changes.

12. No broad CSS/layout experiments.

First safe action:

Inspect existing /api/tasks payload and renderer fields for:

- status

- error

- failure_reason

- result

- events

- execution_meta

- explanation_preview

- completed_at

- updated_at

Do not implement classification until existing field availability is verified.

