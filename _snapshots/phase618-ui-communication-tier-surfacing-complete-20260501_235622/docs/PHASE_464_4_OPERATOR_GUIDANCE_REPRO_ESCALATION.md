STATE HANDOFF — DO NOT LOSE CONTEXT

ASSISTANT OPERATES IN ENGINEERING CONTINUATION MODE

(Phase 464.4 — operator guidance repro escalation corridor opened,
symptom confirmed recurrent, targeted boundary isolation now required)

────────────────────────────────

PHASE 464.4 — OPERATOR GUIDANCE REPRO ESCALATION

CORRIDOR CLASSIFICATION:

TARGETED RUNTIME SYMPTOM ISOLATION

OBSERVATION

The operator guidance stream restarted again after tab interaction.

This upgrades the issue from:

possible duplicate-init symptom

to:

confirmed recurring lifecycle-triggered stream restart

────────────────────────────────

CURRENT HYPOTHESIS CLASS

Most likely fault surfaces:

• React effect re-run without idempotent guard
• tab visibility / focus lifecycle restart
• reconnect logic without dedupe protection
• polling interval restart without cleanup
• stream initialization on remount without singleton guard

────────────────────────────────

OBJECTIVE

Narrow the issue to the smallest safe file boundary by extracting:

• top candidate files
• actual lifecycle anchors
• actual stream init anchors
• actual cleanup anchors
• likely first mutation site

STRICTLY DISALLOWED:

• No fix yet
• No speculative mutation
• No multi-file edits
• No fix-forward behavior

────────────────────────────────

EXPECTED OUTPUT

This proof must produce:

• ranked candidate file list
• bounded code excerpts from likely files
• explicit note on whether cleanup/idempotent guard is missing
• smallest safe first-fix surface

────────────────────────────────

NEXT SAFE MOVE

After this targeted review:

• mutate ONE file only
• add ONE idempotent guard or cleanup repair only
• re-test tab open / tab switch reproduction

────────────────────────────────

STATE

STABLE
GUARDED
DETERMINISTIC
READY FOR TARGETED FILE ISOLATION

