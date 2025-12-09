
Phase 11 — OPS Pill Browser Check (Post-Revert)
What to do in the browser

Open or refresh the dashboard:

http://127.0.0.1:8080/dashboard

Confirm initial state:

OPS pill is visible near the top.

Initial label: OPS: Unknown (or your previous known-good baseline).

Wait a short moment and observe:

The pill should settle into a live state (for example, OPS: Online).

It should NOT keep flipping between “NO SIGNAL” / “No Signal”.

It should feel stable and aligned with the OPS state.

Open DevTools Console and run:

window.lastOpsHeartbeat

window.lastOpsStatusSnapshot

Confirm:

window.lastOpsHeartbeat is a recent Unix timestamp (not null/undefined).

window.lastOpsStatusSnapshot is a non-null object matching the OPS SSE payload.

No console errors related to:

OPS SSE

EventSource failures

Null DOM references for the pill

Next step after this check

If everything looks stable and the OPS pill behavior matches your previous expectations:

Return to ChatGPT and say what the pill text is showing now (e.g., “It shows OPS: Online and stays there”).

We will then proceed to Phase 11 – Step 2: Safe Bundling Integration.

If anything is off (e.g., still flipping, stuck on Unknown, or errors in console):

Describe exactly what the pill text is doing and any console error messages.

We will debug the specific behavior before touching bundling again.
