
Phase 11 – Step 3: Full Dashboard Behavior Audit (Post v11.4-ops-pill-bundled-stable)
Context

Branch: feature/v11-dashboard-bundle

Latest stable tag: v11.4-ops-pill-bundled-stable

Bundle: public/bundle.js built via:

npm run build:dashboard-bundle

This step verifies that the entire dashboard behaves correctly with the bundled JS:

Matilda chat

Task delegation

Broadcast / status tiles

OPS pill

Console cleanliness

1. Repo and Process Sanity

From the repo root:

 git status → clean working tree

 Docker / dev server for the dashboard is running (containerized dashboard on http://127.0.0.1:8080/dashboard
 or your current dev URL)

Recommended quick commands:

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

git status

2. Dashboard Load + Global Health

Open the dashboard:

 URL loads: http://127.0.0.1:8080/dashboard

 Page renders without blank sections or obvious layout breaks

 No red errors appear immediately in DevTools Console

In DevTools → Console:

Run:

window.lastOpsHeartbeat

window.lastOpsStatusSnapshot

Check:

 window.lastOpsHeartbeat is a recent Unix timestamp

 window.lastOpsStatusSnapshot is a non-null object with at least:

type: "hello"

source: "ops-sse"

timestamp: recent

message: "OPS SSE connected"

 No EventSource-related errors for OPS or reflections

3. OPS Pill Behavior (Regression Check)

 OPS pill visible near the top of the dashboard

 Initial text: "OPS: Unknown" (baseline expected)

 After SSE connects, pill updates to live state (e.g., "OPS: Online")

 Pill text is stable (no continuous flipping between variants like NO SIGNAL / No Signal)

 No CSS glitches (no overlap, no clipping)

If any unexpected behavior occurs, note exact text and timing before making any code changes.

4. Matilda Chat Console

In the dashboard:

 Matilda chat area renders (input + transcript region)

 DevTools Console shows:

"[matilda-chat] Matilda chat wiring complete."

Test a message:

Type a short message into the chat input (e.g., "ping from dashboard").

Click the send button (or equivalent trigger).

Verify:

 Input is temporarily disabled during send (if implemented)

 Transcript area shows your sent message with a sender label (e.g., "You:" or "User:")

 If Matilda responds, her response appears in the transcript

 No console errors appear during send or response

If an error appears, copy its message and the stack snippet for debugging before proceeding.

5. Task Delegation Buttons

Locate the task delegation section:

 Task delegation controls render (buttons/inputs as designed)

 No overlap with chat or other cards

Click a delegation button to send a basic task:

 Button click does not break the page

 Any expected UI feedback occurs (task row, log entry, or confirmation)

 DevTools Console shows no new errors during or immediately after the click

Note: backend success is less important than front-end stability. The key is absence of front-end JS errors.

6. Status / Broadcast Tiles

If status/broadcast tiles are present on the dashboard:

 Tiles render with readable text

 No “undefined” / “null” strings in the UI

 Tiles do not duplicate or vanish unexpectedly on reload

If there is an SSE-driven tile:

 Tile content updates when new SSE data comes in (if test data is available)

 No console errors indicate JSON parse or DOM injection issues

7. Console Cleanliness (Final Pass)

With the dashboard open and idle for a short time (30–60 seconds):

 No recurring error logs in DevTools Console

 No repeated EventSource connection errors

 No “Cannot read properties of null” errors tied to dashboard elements

Warnings are acceptable if they are known and benign; errors are not.

8. Pass/Fail Summary for Step 3

Mark one:

 PASS – All checks above are effectively green. No regressions detected.

 FAIL – One or more checks failed.

If FAIL:

Briefly describe the failing area (OPS pill, chat, delegation, tiles, or console).

Capture the exact error message(s) and observed behavior.

Address the issues in a focused follow-up change set before declaring a new stable tag.

If PASS:

Safe to treat:

v11.4-ops-pill-bundled-stable
as the current dashboard behavior baseline for Phase 11.

