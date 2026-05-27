STATE NOTE — PHASE 79 CONTROLLED AUTOMATION BOUNDARY SPEC
Date: 2026-03-16

────────────────────────────────

PURPOSE

Define the absolute structural boundary that any future controlled automation must obey.

This document defines:

What automation may observe  
What automation may propose  
What automation may never do  
What authority always remains human-only  

This is a constraint document, not an implementation document.

────────────────────────────────

DEFINITION — CONTROLLED AUTOMATION

Controlled automation is defined as:

A cognition-only advisory layer capable of:
• analyzing system state
• generating recommendations
• proposing safe next actions
• producing dry-run plans

Controlled automation is NOT:

Execution authority  
Mutation authority  
Background processing  
Self-directed action  
Persistent authority  

Automation in this system is advisory only unless a future explicit phase changes this rule.

Current system remains:

HUMAN EXECUTION ONLY.

────────────────────────────────

ABSOLUTE PROHIBITIONS (NON-NEGOTIABLE)

Automation must NEVER:

Execute tasks
Modify reducers
Modify UI state
Modify telemetry
Write to database
Trigger workers
Trigger retries
Perform restores
Perform recovery actions
Create background loops
Schedule actions
Self-trigger logic
Escalate authority
Override safety gates
Override runbooks
Override recovery-first rules
Act without human confirmation
Act using stale confirmation
Reuse prior approval
Store approval state
Hide decisions
Operate silently

Any future proposal violating any item above must be rejected automatically.

────────────────────────────────

ALLOWED AUTOMATION CAPABILITIES (PLANNING CLASS ONLY)

Automation may only:

Analyze telemetry
Analyze diagnostics
Analyze operator signals
Analyze runbook outputs
Generate summaries
Propose ranked options
Suggest runbooks
Suggest safe next steps
Generate dry-run plans
Generate validation checklists
Highlight risks
Highlight unknowns
Recommend pause
Recommend recovery-first

Automation may never transition from proposal to execution.

That boundary is absolute in Phase 79.

────────────────────────────────

HUMAN-ONLY AUTHORITY (PERMANENT)

The following authority remains permanently human:

Restore checkpoint
Run mutation scripts
Change reducers
Change persistence
Change telemetry wiring
Approve execution
Reject execution
Approve recovery
Approve rollback
Override safety gates
Change policies
Grant authority
Revoke authority

Automation may only recommend.
Human must always decide.

────────────────────────────────

CONFIRMATION MODEL (FUTURE CONTRACT REQUIREMENT)

Any future approval system must require:

Explicit target
Explicit scope
Explicit effect
Explicit risk statement
Explicit rollback path
Explicit expiration
Explicit confirmation event

Approval must be:

Single use
Session scoped
Non persistent
Revocable
Auditable
Narrowly scoped

Disallowed:

Standing approvals
Global approvals
Implicit approvals
Silent approvals
Reused approvals

────────────────────────────────

FAIL-CLOSED REQUIREMENT

If automation cannot determine safety:

Automation must:

Return NO-OP recommendation
Return OBSERVE-ONLY
Return INVESTIGATE recommendation
Return RECOVERY-FIRST recommendation

Automation must never guess.

Uncertainty must halt recommendation strength.

────────────────────────────────

RECOVERY-FIRST SUPERIORITY RULE

Automation must always defer to:

Structural protection
Telemetry integrity
Recovery-first discipline
Safety gates
Runbook ordering

If automation recommendation conflicts with recovery-first:

Recovery-first wins automatically.

Automation must downgrade to advisory only.

────────────────────────────────

NO-OP DEFAULT RULE

Default automation output must be:

NO ACTION

Unless explicitly asked for recommendation generation.

Automation must never:

Proactively act
Proactively trigger
Proactively schedule
Proactively execute

Automation is passive cognition only.

────────────────────────────────

DRY-RUN REQUIREMENT

Any future action proposal must support:

Dry-run description
Expected impact
Zero side effects
Rollback explanation
Failure scenarios

Dry-run must exist before any execution discussion.

────────────────────────────────

REVOCATION REQUIREMENT

Any future approval model must support:

Immediate revoke
Immediate halt
Immediate downgrade to observe-only

Revocation must not require system restart.

Revocation must not require cleanup.

Revocation must terminate authority instantly.

────────────────────────────────

TRANSPARENCY REQUIREMENT

Automation must always expose:

Why recommendation exists
What signals were used
What risks exist
What unknowns exist
Why action is blocked
Why recovery is suggested
Why continuation is safe

Automation must never:

Hide reasoning
Hide risk
Hide uncertainty
Hide blocking signals

────────────────────────────────

BOUNDARY SUMMARY

Automation may:

Analyze
Summarize
Recommend
Plan

Automation may never:

Execute
Mutate
Persist
Trigger
Schedule
Override
Escalate

Human remains execution authority.

This boundary holds unless explicitly replaced by a later phase.

────────────────────────────────

PHASE 79 SUCCESS STATE (BOUNDARY SPEC)

Boundaries documented
Forbidden powers documented
Human authority documented
Confirmation requirements documented
Failure mode documented
Recovery superiority documented
No-op defaults documented

System remains unchanged.

────────────────────────────────

NEXT PLANNING ARTIFACT

AUTHORITY MODEL CONTRACT

Define exact separation between:

Human authority
Advisory cognition
Forbidden authority

END OF SPEC
