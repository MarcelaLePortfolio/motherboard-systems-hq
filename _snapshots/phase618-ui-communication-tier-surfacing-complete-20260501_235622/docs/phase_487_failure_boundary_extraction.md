PHASE 487 — FAILURE BOUNDARY EXTRACTION

OBJECTIVE:
Narrow Operator Guidance failure to the exact UI boundary where valid governance data becomes an incorrect "insufficient" render.

SCOPE:
• Proof-only
• No backend mutation
• No governance mutation
• No execution mutation
• No UI behavior mutation in this step

METHOD:
• Read latest trace probe artifact
• Extract high-signal lines involving:
  - guidance
  - status
  - reason
  - insufficient
  - useState / fallback / hydration
• Produce a focused evidence file for exact boundary review

STOP CONDITION:
Small candidate set identified for the exact failure boundary.
