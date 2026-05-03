PHASE 455.8 — OPERATOR DEMO RUNBOOK

CLASSIFICATION:

OPERATOR EXECUTION GUIDE

PURPOSE

Provide a minimal deterministic procedure for demonstrating the governed runtime system.

This document exists to remove operator memory dependency.

No architecture is introduced.

No execution behavior is modified.

This is a stabilization artifact.

────────────────────────────────

DEMO OBJECTIVE

Demonstrate that the system can:

Accept a natural language request
Translate it into governed execution
Run deterministically
Report results

Without pre-configuration.

────────────────────────────────

DEMO STEPS

Step 1

Start system:

docker compose up -d

Verify dashboard:

http://localhost:8080

────────────────────────────────

Step 2

Open demo page:

/demo-runtime

────────────────────────────────

Step 3

Enter natural language request:

Example:

"Create a simple project with three tasks"

or

"Run a minimal demo project"

────────────────────────────────

Step 4

Submit request.

Expected system flow:

Prompt received
→ Parsed into request structure
→ Governance admission check
→ Deterministic execution
→ Outcome reporting

────────────────────────────────

EXPECTED RESULT CHARACTERISTICS

Result should show:

• Request accepted or denied
• Governance reasoning
• Execution outcome
• Final status

Not:

Raw logs
Unstructured output
Hidden execution behavior

────────────────────────────────

DEMO SUCCESS CONDITION

Demo is successful if:

System accepts at least two different prompts
Both follow same governed runtime path
Results are readable
No special-case logic is required

────────────────────────────────

STATUS

OPERATOR DEMO RUNBOOK:

ESTABLISHED

