#!/usr/bin/env bash
set -euo pipefail

cat <<MSG

==============================
FL-3 DEMO — READY TO EXECUTE
==============================

Paste the following into the Operator Console (Matilda input):

----------------------------------------
Create a new project:

Name: Demo — Social Campaign Launch

Objective:
Launch a 2-week social media campaign to promote a new product.

Tasks:
1. Generate campaign strategy outline
2. Create 5 social media post concepts
3. Draft captions for each post
4. Define posting schedule
5. Output final campaign plan

Constraints:
- Require approval before execution
- Provide full reasoning for each step

Additional Requirement:
- After execution, summarize outcomes in a clear, operator-facing report
----------------------------------------

Expected system flow:

Operator request
→ Structured intake
→ Governance evaluation
→ Approval request
→ Execution (if approved)
→ Outcome reporting in telemetry
→ Final summarized report

What to watch:

- Does intake structure correctly?
- Does governance produce reasoning?
- Does system request approval?
- Do tasks appear in telemetry?
- Does execution produce outputs?
- Is a final report generated?

NOTE:
Matilda reply may be silent or partial — this is OK.
Focus on system behavior, not chat response.

==============================
END DEMO INSTRUCTIONS
==============================

MSG
