# Phase 11 – Dashboard Bundling & Reliability Handoff Overview
(Starting point for a new thread)

## 🎯 Current Status (End of Last Thread)

You have:
- Successfully isolated DB-backed endpoints.
- Deferred DB storage work intentionally.
- Documented the exact pause point:
  - PHASE11_DB_ENDPOINTS_STATUS.md
  - PHASE11_NEXT_STEPS_RECOMMENDATION.md
- Restored dashboard container stability.
- Preserved all Phase 11 stubbed endpoints (UI-facing) fully functional.

**Everything is clean, stable, and ready for front-end progress.**

## 🎯 Immediate Goal for This Thread

Proceed with **Phase 11’s original deliverable**:
### ➤ JS/CSS Bundling + Dashboard Reliability

This involves:
1. Moving all scattered dashboard JS into a **single bundled build** (e.g., via Rollup or esbuild).
2. Ensuring:
   - Matilda Chat Console still works,
   - Task Delegation panel works,
   - SSE streams (Reflections + OPS) reconnect cleanly,
   - Agent tiles update correctly,
   - No duplicated event listeners appear after reload.
3. Verifying visual layout consistency:
   - No duplicate cards,
   - No overlapping sections,
   - Left/right column alignment maintained,
   - Project Visual Output viewport stability.
4. Preparing a stable tag:
   - Example: `v11.1-dashboard-bundled-stable`

This work is **independent from backend DB logic** and is the next intended milestone for Phase 11.

## 🧭 Sequence to Follow in the New Thread

### STEP 1 — Identify All Dashboard JS Entry Points
We will scan `/public/js/`, `/public/scripts/`, and dashboard.html to list all currently-imported scripts.

### STEP 2 — Build a Bundling Plan
Choose a strategy:
- Single dashboard bundle (recommended), or
- Small set of grouped bundles if necessary.

### STEP 3 — Install & Configure a Bundler
Options:
- Rollup (simple, clean)
- esbuild (very fast)
- Vite (overkill for this phase)

### STEP 4 — Replace Script Tags in dashboard.html
Remove excessive `<script>` tags → replace with one built asset.

### STEP 5 — Functional Regression Testing
After bundling:
- Verify Matilda Chat input/output.
- Verify /api/delegate-task (stubbed).
- Verify SSE streams.
- Verify agent status tiles.
- Verify no errors in browser console.

### STEP 6 — Reload/Refresh Reliability
Ensure:
- Hard reload reconnects SSE.
- No double listeners.
- No flickering UI.

### STEP 7 — Layout Verification
Confirm:
- Clean structure,
- No overlaps,
- Correct viewport height,
- Fully rendered right column.

### STEP 8 — Tag Stable Checkpoint
Create:
`v11.1-dashboard-bundled-stable`

Update Phase 11 docs accordingly.

## 🔒 DB-Backed Endpoints (Reminder)
Do NOT work on:
- Database URLs,
- Pool configuration,
- Schema creation,
- Table creation,
- DB task logic.

These are intentionally deferred until:
`Phase 11.5 – DB Task Storage`

## 🚀 How to Resume in a New Thread

Say:

**“Continue Phase 11 dashboard bundling work from PHASE11_BUNDLING_HANDOFF.md.”**

The assistant will:
- Automatically load this baseline,
- Start with STEP 1 (listing dashboard JS entrypoints),
- Proceed through the bundling plan safely and methodically.

