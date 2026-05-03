PHASE 456.5 — IMPLEMENTATION STEP 8

SAFE MOUNT PLAN

Classification:
Controlled exposure wiring implementation

Purpose:

Define the exact safe mount action for SystemHealthBlock now that
mountpoint discovery is complete.

This step defines:

Where it will be inserted.
How it will be inserted.
What must remain unchanged.

No code changes yet.

────────────────────────────────

MOUNT PRINCIPLE

Mount must be:

Top of dashboard render tree.

Before:

Governance panels
Execution panels
Planning panels
Telemetry panels

Never inserted mid-tree.

Never nested inside another panel.

Must be sibling to existing panels.

────────────────────────────────

SAFE INSERTION RULE

Insertion must:

Import SystemHealthBlock
Create signals object
Pass props
Render component

Only these four actions allowed.

No refactors.
No file moves.
No panel restructuring.

Minimal mutation rule.

────────────────────────────────

EXPECTED INSERTION SHAPE

Conceptual structure only:

import { SystemHealthBlock } from "...";

const healthSignals = {
  governance: existingValue ?? "UNKNOWN",
  execution: existingValue ?? "UNKNOWN",
  approval: existingValue ?? "UNKNOWN",
  executionMode: existingValue ?? "UNKNOWN"
};

<SystemHealthBlock signals={healthSignals} />

Existing panels follow unchanged.

────────────────────────────────

SAFETY GUARANTEES

Mount must NOT:

Change panel order (except adding health at top)
Modify signal producers
Add state
Add hooks
Add context
Modify routing
Modify layouts

Single insertion only.

────────────────────────────────

REGRESSION CHECK TARGET

After mount:

Dashboard loads
Health block visible
Existing panels unchanged
Signals render or UNKNOWN
No console errors
No layout shifts

If violation:

Immediate revert.

────────────────────────────────

SUCCESS CONDITION

Mount plan complete when:

Insertion location known.
Insertion shape defined.
Mutation boundaries defined.
Regression checks defined.

Ready for controlled mount execution.

────────────────────────────────

DETERMINISTIC STOP

Stop after mount plan definition.

Next step:

Controlled mount execution.

PHASE 456.5 IMPLEMENTATION STEP 8 COMPLETE.
