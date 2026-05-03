PHASE 489 — H1 OPERATOR GUIDANCE ROUTE MISMATCH FIX

STATUS:
READY TO APPLY

────────────────────────────────

ROOT CAUSE

The mounted Operator Guidance SSE client is pointing at:

/api/operator-guidance

But the actual served backend route found in server.mjs is:

/events/operator-guidance

This route mismatch causes the UI to remain on fallback:
confidence: insufficient

────────────────────────────────

FIX

Update the existing read-only SSE client to consume:

/events/operator-guidance

No contract, governance, approval, execution, or backend mutation required.

────────────────────────────────

SUCCESS CRITERIA

• Operator Guidance no longer remains on fallback
• Existing SSE client receives live event payloads
• UI remains read-only and deterministic

