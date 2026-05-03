PHASE 489 — H1 NEXT DIAGNOSIS

STATUS:
LIKELY EVENT-NAME MISMATCH

────────────────────────────────

OBSERVATION

Operator Guidance still remains on fallback after:

• mounting the SSE client
• correcting the route path
• broadening payload field handling

────────────────────────────────

LIKELY ROOT CAUSE

The SSE route is probably emitting a NAMED event
instead of a default message event.

Current client only handles:

• eventSource.onmessage

If server emits for example:

event: operator-guidance

then onmessage will never fire.

────────────────────────────────

NEXT ACTION

1. inspect the actual server route emission format
2. update the client to handle BOTH:
   • default message events
   • named operator-guidance events

This remains read-only and UI-safe.

