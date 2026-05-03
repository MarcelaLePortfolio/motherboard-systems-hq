PHASE 481 STEP 1 — INTERACTIVE APPROVAL REPLAY + ISOLATION PLAN
================================================================

OBJECTIVE

Prove that interactive approval remains:

• replay-safe
• input-isolated
• decision-isolated
• artifact-isolated

across repeated mixed approval decisions.

────────────────────────────────

TEST MATRIX

Same input:
"echo hello world"

Approval sequence:

Run 1 → APPROVE  
Run 2 → REJECT  
Run 3 → APPROVE  
Run 4 → INVALID (MAYBE)  
Run 5 → REJECT  

────────────────────────────────

EXPECTED BEHAVIOR

APPROVE runs:

• approval_plan exists (true)
• execution_plan exists
• no approval_failure
• no approval_input_failure

REJECT runs:

• approval_plan exists (false)
• approval_failure exists
• execution_plan must NOT exist

INVALID runs:

• approval_input_failure exists
• approval_plan may be absent or unchanged
• execution_plan must NOT exist

────────────────────────────────

CROSS-RUN INVARIANTS

• prior APPROVE must not leave execution artifact after REJECT
• prior REJECT must not block later APPROVE execution
• INVALID must not contaminate subsequent APPROVE or REJECT
• artifact filenames must remain deterministic per input
• latest run must fully determine final artifact state

────────────────────────────────

SUCCESS CRITERIA

Step 1 complete when:

• mixed sequence executes
• snapshots captured
• isolation expectations defined
• no stale artifacts persist incorrectly

