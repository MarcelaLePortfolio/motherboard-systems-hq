PHASE 480 STEP 3 — INTERACTIVE APPROVAL ISOLATION FIX

OBJECTIVE

Restore deterministic isolation for interactive approval by ensuring:

• REJECT removes any stale execution artifact for the same planId
• APPROVE regenerates execution cleanly
• invalid approval input fails deterministically
• same request with different approval decisions diverges cleanly

ISSUE OBSERVED

A prior APPROVE run for the same request could leave an execution artifact in place,
causing ambiguity after a later REJECT run for the same planId.

FIX APPLIED

The interactive approval script now:

• removes execution artifact before evaluating approval decision
• removes stale approval-failure artifacts before APPROVE
• removes stale input-failure artifacts before APPROVE/REJECT
• emits approval_input_failure artifact for invalid approval input

EXPECTED RESULT

For the same request:

APPROVE
→ approval true
→ execution present

REJECT
→ approval false
→ approval failure present
→ execution absent

INVALID APPROVAL INPUT
→ approval input failure present
→ execution absent

SUCCESS CRITERIA

• stale execution artifact is absent after REJECT
• approval rejection remains deterministic
• invalid approval decision remains deterministic
• isolation is restored for same-input mixed approval runs

