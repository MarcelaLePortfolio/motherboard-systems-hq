PHASE 78 — OPERATOR RUNBOOK SYSTEM
Implementation Plan (Cognition Layer Only)
Date: 2026-03-16

GOAL

Introduce deterministic operator runbooks derived from adaptive playbooks without changing reducers, telemetry, UI, database, or automation authority.

SAFETY MODEL

This phase creates a READ-ONLY cognition layer.

No runtime mutation.
No reducer interaction.
No DB writes.
No automation hooks.

This is an interpretation layer only.

SUCCESS OUTPUT MODEL

Single operator command should produce:

SYSTEM STATE
RISK CLASSIFICATION
RECOMMENDED WORKFLOW
ORDERED RUNBOOK
SAFE-TO-CONTINUE SIGNAL
RECOVERY-FIRST PATH

IMPLEMENTATION STRATEGY

Create a pure TypeScript cognition module:

dashboard/src/operator/runbooks/

FILES TO CREATE

operatorRunbookTypes.ts
operatorRunbookCatalog.ts
operatorRunbookResolver.ts
operatorRunbookFormatter.ts

DESIGN STRUCTURE

operatorRunbookTypes.ts

Defines structure only:

RunbookStep
Runbook
RiskLevel
SystemStateClass

operatorRunbookCatalog.ts

Static deterministic runbooks.

Example categories:

SYSTEM_STABLE
TELEMETRY_DRIFT
SSE_INTERRUPTION
REDUCER_WARNING
UNKNOWN_STATE

operatorRunbookResolver.ts

Pure resolver:

Input:

system snapshot
diagnostics classification
operator signals

Output:

runbook id
ordered steps
continue/hold

No side effects.

operatorRunbookFormatter.ts

Produces operator readable output block.

No UI wiring.
Console/test usage only.

INITIAL RUNBOOKS (PHASE 78 MINIMUM SET)

RUNBOOK_STABLE_CONTINUE

Steps:

Verify diagnostics clean
Verify drift detector clean
Verify reducers healthy
Continue development

RUNBOOK_INVESTIGATE_DRIFT

Steps:

Check drift report
Check replay validation
Compare reducer snapshots
HOLD changes until verified

RUNBOOK_RECOVERY_FIRST

Steps:

Identify last golden tag
Restore if structural issue detected
Verify layout contract
Reapply work cleanly

RUNBOOK_OBSERVE_ONLY

Steps:

No change allowed
Monitor telemetry
Re-run diagnostics later

CONSTRAINTS

No imports from reducers.
No imports from telemetry writers.
No mutation functions allowed.

Pure classification only.

TEST METHOD

Add local script:

scripts/operator-runbook-smoke.ts

Feed sample inputs.
Print runbook output.

No dashboard wiring yet.

PHASE EXIT CONDITIONS

Runbook resolver returns deterministic result.
Runbook output readable.
No runtime impact.
No reducer interaction.
No UI changes.

NEXT PHASE

Phase 79 (optional future):

Controlled automation preparation.

Only considered if Phase 78 remains zero-risk.
