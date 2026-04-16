PHASE 487 — EXACT LINE NUMBER PINNING

OBJECTIVE:
Pin the exact source line numbers for the Operator Guidance failure boundary in the selected top candidate file.

SCOPE:
• Proof-only
• No backend mutation
• No governance mutation
• No execution mutation
• No UI behavior mutation in this step

OUTPUT:
• Exact line-numbered windows for:
  - guidance render
  - insufficient string
  - status/reason reads
  - fallback/default/state logic
  - hydration/empty-state logic

STOP CONDITION:
Exact patch site narrowed to a line-numbered source window.
