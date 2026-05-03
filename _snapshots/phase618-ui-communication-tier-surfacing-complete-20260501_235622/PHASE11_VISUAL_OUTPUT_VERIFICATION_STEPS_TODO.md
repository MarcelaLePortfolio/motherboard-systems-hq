# Phase 11 – Live Container Verification (Step-by-Step Guide)

Use this checklist to perform the REQUIRED verification task for the containerized dashboard.

---

## 0. Progress Log (Quick Snapshot)

- [x] STEP 1 – Containers are running and HTTP check at localhost:3000 returned 200 OK
  - docker compose ps:
    - motherboard_systems_hq-dashboard-1 → Up (mapped 0.0.0.0:8080->3000/tcp)
    - motherboard_systems_hq-postgres-1 → Up (0.0.0.0:5432->5432/tcp)
  - curl -I http://localhost:3000 → HTTP/1.1 200 OK

- [ ] STEP 2 – Open containerized dashboard in browser and visually verify layout at http://localhost:8080
- [ ] STEP 3 – Verify Project Visual Output styling and viewport height
- [ ] STEP 4 – Quick functional checks (chat + delegation + console)
- [ ] STEP 5 – Append final verification note in this file

When you come back, start at the first unchecked step.

---

## STEP 1 – Confirm Containers Are Running (COMPLETED)

Already done in this session:

1. Ran:
   - docker compose ps

2. Confirmed:
   - "dashboard" container is listed as "Up"
   - "postgres" container is listed as "Up"

3. Ran:
   - curl -I http://localhost:3000

4. Confirmed:
   - HTTP/1.1 200 OK
   - Express server responding

You do not need to repeat this unless something breaks later.

---

## STEP 2 – Open the Containerized Dashboard (NEXT ACTION)

Now verify the actual dashboard UI served from the container:

1. Open your browser on the same machine where Docker is running.

2. In the address bar, go to:
   http://localhost:8080

   Notes:
   - docker compose ps shows port 8080 mapped to port 3000 inside the dashboard container.
   - Visiting http://localhost:8080 ensures you are seeing the containerized dashboard, not a local dev server.

3. Wait for the dashboard to load.

4. If it does not load or shows an error page, capture:
   - Visible error text
   - Screenshot (optional)
   - Browser console errors (DevTools → Console)

Once this loads successfully, STEP 2 is complete.

---

## STEP 3 – Verify Layout and Structure

On the loaded dashboard page, visually confirm:

1. Left column contains:
   - Matilda Chat Console
   - Key Metrics
   - Task Delegation
   - Atlas Status

2. Right column contains:
   - One large Project Visual Output “screen” card.

3. No visual glitches:
   - No floating/duplicate visual output elements
   - No broken or collapsed containers
   - Clean grid alignment

If something is off, describe it for later logging.

---

## STEP 4 – Verify Project Visual Output Styling and Function

### A. Project Visual Output Styling

Confirm the right-hand visual output card displays:

- 3D monitor-style design  
- Soft glow / holographic rim  
- Beveled / depth edges  
- LED indicator  
- Dark-glass inner gradient  
- Smooth rounded corners  
- Clean inset shadows  

Viewport height & alignment:

- The “screen” area is ~640px tall  
- Bottom of the right card aligns with the Task Delegation card  
- Page looks balanced vertically  

### B. Functional Checks

1. Matilda Chat Console:
   - Send: "ping from container dashboard"
   - Confirm a response.

2. Task Delegation:
   - Submit: "test container dashboard delegation"
   - Confirm UI responds without errors.

3. Browser console (Command+Option+I → Console):
   - Confirm no recurring red errors.

---

## STEP 5 – Mark Verification Complete

1. At the top of this file (Progress Log), mark remaining steps as:
   - [x] when completed

2. Append a final note at the bottom, e.g.:

   2025-12-03 – Container dashboard verified OK at http://localhost:8080.  
   Layout and 3D screen styling match local. Minor cosmetic tweaks optional.

3. You may now treat:
   - Tag: v11.1-visual-output-stable  
   - Branch: feature/v11-dashboard-bundle  
   as a fully verified container baseline.

