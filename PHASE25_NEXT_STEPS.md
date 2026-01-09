# Phase 25 — Next Steps (Post-Contract)

Status:
- Authority & orchestration contract committed and pushed.
- Phase-24 cleanup is now formally blocked.

Immediate next actions (in order):

1) **Name the Single Writer**
   - Identify the exact module/process responsible for inserting into `task_events`.
   - Add an explicit header comment in that file declaring:
     "SINGLE AUTHORITATIVE TASK EVENT WRITER — Phase 25 contract enforced."

2) **Audit for Violations**
   - Grep for any UI/SSE code that:
     - infers lifecycle state
     - uses event row IDs or DOM IDs as task IDs
   - Log findings before making changes.

3) **Define the Fold Function**
   - Specify (or locate) the deterministic lifecycle fold function.
   - Ensure all consumers reference it (directly or via a shared helper).

4) **Add Guardrails**
   - Runtime assertions rejecting:
     - post-terminal lifecycle events
     - invalid transitions
   - Writer-side idempotency enforcement.

No refactors or cleanup until steps 1–4 are complete.
