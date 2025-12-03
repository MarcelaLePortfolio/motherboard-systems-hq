# Phase 11 – Live Container Verification (Step-by-Step Guide)

Use this checklist to perform the REQUIRED verification task for the containerized dashboard.

---

## STEP 1 – Confirm Containers Are Running

In Terminal (already in project root):

1. Run:
   docker compose ps

2. Confirm:
   - A "dashboard" container is listed with state "Up"
   - A "postgres" container is listed with state "Up"

If either is not "Up", note the problem and check:
   docker compose logs

---

## STEP 2 – Quick HTTP Sanity Check

In Terminal:

1. Run:
   curl -I http://localhost:3000

2. Confirm:
   - Status line includes "HTTP/1.1 200" or "HTTP/1.1 302" that leads to a 200
   - No obvious 5xx errors in the headers

If you see a 500 or 502/503, paste the output into ChatGPT for debugging later.

---

## STEP 3 – Open the Dashboard in the Browser

1. Open your browser on the same machine where Docker is running.
2. In the address bar, go to:
   http://localhost:3000

3. Wait for the dashboard to load.
4. If it does not load or shows an error page, capture:
   - A screenshot (optional)
   - Any visible error text
   - The browser console error (if accessible)

---

## STEP 4 – Verify Layout and Structure

On the loaded dashboard page, visually confirm:

1. Left column contains:
   - Matilda Chat Console
   - Key Metrics
   - Task Delegation
   - Atlas Status (or similar status card)

2. Right column contains:
   - One large Project Visual Output screen card (3D-style monitor).

3. No visual glitches:
   - No floating/duplicate visual output elements
   - No broken or collapsed containers
   - Cards appear aligned in a clean grid

If something is off, describe in your own words what looks wrong.

---

## STEP 5 – Verify Project Visual Output Styling

Still in the browser:

1. Look at the right-hand Project Visual Output card.
2. Confirm:
   - It looks like a 3D monitor-style display
   - It has a soft glow / holographic rim
   - Edges show a subtle bevel effect (faux depth)
   - An LED indicator is visible near the frame
   - The inner area has a dark, glassy gradient look
   - Corners and shadows look smooth and intentional

3. Scroll, if needed, to see the full card.

---

## STEP 6 – Verify Viewport Height and Alignment

1. Look at the main “screen” area inside the Project Visual Output card.
2. Confirm:
   - It is tall enough (minimum height roughly 640px)
   - The bottom edge of the right card aligns visually with the Task Delegation card on the left
   - The overall page feels balanced (no obvious “short” or “cut off” screen)

If the viewport feels too short or too tall, note it but this does NOT block the baseline.

---

## STEP 7 – Quick Functional Check

1. In Matilda Chat Console:
   - Type a short test message (for example: "ping from dashboard")
   - Confirm a response appears as expected.

2. In Task Delegation area:
   - Submit a very simple task (for example: "test dashboard delegation")
   - Confirm the UI responds normally (no breakage or obvious errors).

3. Check the browser console:
   - Open DevTools (Command+Option+I on Mac)
   - Go to the "Console" tab
   - Confirm there are no recurring red errors during idle time.

If you see errors, copy or screenshot them for later debugging.

---

## STEP 8 – Mark Verification Complete

Once all steps above are done:

1. In this file, optionally append:
   - Date and time of verification
   - A short note: "Container dashboard verified OK" or list any minor issues.

2. You can treat this as:
   - The moment Phase 11 visual baseline is confirmed in-container.

When you next return to Phase 11 work, start from:
   - Tag: v11.1-visual-output-stable
   - Branch: feature/v11-dashboard-bundle
and choose between:
   - UX Enhancements (visual output features), or
   - Bundling & reliability improvements.

