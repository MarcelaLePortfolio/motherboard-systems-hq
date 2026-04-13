PHASE 476 — STEP 2
VISIBILITY NORMALIZATION PROOF

OBJECTIVE

Prove that the structured normalized visibility surface correctly reflects latest deterministic run state without mutating pipeline behavior.

This proof verifies:

• normalized visibility file regenerates deterministically
• normalized fields reflect latest run artifacts
• success path maps correctly
• approval-rejected path maps correctly
• governance-rejected path maps correctly
• entry-invalid path maps correctly
• normalization remains read-only

────────────────────────────────

TEST ORDER

Run 1:
approval APPROVED
echo hello world
→ regenerate normalized visibility
→ snapshot success state

Run 2:
approval REJECTED
echo reject hello world
→ regenerate normalized visibility
→ snapshot approval-rejected state

Run 3:
governance REJECTED
say hello world
→ regenerate normalized visibility
→ snapshot governance-rejected state

Run 4:
entry-invalid
""
→ regenerate normalized visibility
→ snapshot entry-invalid state

────────────────────────────────

EXPECTED NORMALIZED STATE

SUCCESS snapshot must show:

• intake.status = SUCCESS
• governance.decision = APPROVED
• approval.status = APPROVED
• execution.status = SUCCEEDED
• failure.stage = none

APPROVAL-REJECTED snapshot must show:

• governance.decision = APPROVED
• approval.status = REJECTED
• execution.status = BLOCKED
• failure.stage = approval

GOVERNANCE-REJECTED snapshot must show:

• governance.decision = REJECTED
• approval.status = SKIPPED
• execution.status = BLOCKED
• failure.stage = governance

ENTRY-INVALID snapshot must show:

• intake.status = FAILURE
• execution.status = BLOCKED
• failure.stage = entry_validation

────────────────────────────────

SUCCESS CRITERIA

Step 2 is complete when:

• normalized visibility file regenerates for each run
• normalized snapshots are preserved
• latest-state mapping is inspectable
• no proof artifacts are mutated by normalization

