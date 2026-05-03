PHASE 475 — STEP 1
VISIBILITY REPLAY + ISOLATION AUDIT PLAN

OBJECTIVE

Prove that operator visibility remains replay-safe and isolated across repeated mixed run order without stale-surface ambiguity.

This step audits whether:

• repeated visibility refreshes remain deterministic
• stale execution does not mask later failure state
• stale failure does not mask later execution state
• latest-surface regeneration remains explicit and inspectable
• visibility continues to avoid mutating pipeline artifacts

────────────────────────────────

MIXED VISIBILITY RUN ORDER

Run 1:
approval APPROVED
echo hello world

Refresh visibility

Run 2:
approval REJECTED
echo reject hello world

Refresh visibility

Run 3:
governance REJECTED
say hello world

Refresh visibility

Run 4:
entry-invalid
""

Refresh visibility

Run 5:
approval APPROVED
echo deterministic flow

Refresh visibility

────────────────────────────────

EXPECTED VISIBILITY RULES

After each refresh:

• docs/visibility_latest_run.txt must regenerate deterministically
• latest surfaced governance state must match latest run-relevant governance artifact
• latest surfaced approval state must match latest run-relevant approval artifact when present
• latest surfaced failure state must match latest failure artifact when present
• latest surfaced execution outcome must match latest execution artifact when present

────────────────────────────────

CROSS-RUN INVARIANTS

• visibility refresh must not create new proof artifacts
• visibility refresh must not mutate existing proof artifacts
• later failure visibility must not erase prior success proof artifacts
• later success visibility must not erase prior failure proof artifacts
• surfaced latest-state must remain replay-safe for identical run order
• visibility must remain file-based and deterministic

────────────────────────────────

SUCCESS CRITERIA

Step 1 is complete when:

• mixed visibility refresh order is defined
• latest-surface expectations are explicit
• cross-run visibility invariants are explicit

