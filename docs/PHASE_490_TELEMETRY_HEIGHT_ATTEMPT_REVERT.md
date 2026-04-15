PHASE 490 — TELEMETRY HEIGHT ATTEMPT REVERT

STATUS:
REVERTED TO LAST KNOWN STABLE HEIGHT STATE

────────────────────────────────

WHY THIS REVERT HAPPENED

Recent telemetry-only height patches did NOT change the telemetry height mismatch.

Observed outcome:

• Delegation previously matched Matilda chat correctly
• Telemetry panels remained slightly longer
• Additional telemetry-only sync attempts produced no visible improvement

Per engineering protocol, repeated no-effect attempts should not be layered indefinitely.

────────────────────────────────

ACTION TAKEN

Revert the last two telemetry-height-only commits to return to the last known stable state:

• Delegation panel correctly matched Matilda chat
• No stacking regression
• Telemetry remains functional
• Height mismatch remains isolated for a future measured-layout corridor

────────────────────────────────

NEXT SAFE ENTRY

Future work should begin from DOM measurement and authoritative browser-side layout evidence,
not further speculative CSS/JS height patches.

Recommended next corridor:

PHASE 490.1 — TELEMETRY HEIGHT DOM EVIDENCE CAPTURE

