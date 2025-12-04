
Phase 11 – Dashboard Rendering Status & Hotfix Plan
Current Symptom

The dashboard UI is not rendering as expected in the browser.

We previously replaced public/dashboard.html with a minimal shell that only contained:

<div id="dashboard-root"></div>

A small set of <script> tags.

The actual card-based layout (uptime, health, metrics, Matilda chat, task delegation, etc.) is not present in the current dashboard.html, so:

JavaScript modules (like dashboard-status.js, SSE handlers, chat, delegation) are targeting DOM elements that do not exist.

This results in a "blank" or non-rendering dashboard, even though the scripts and bundle build successfully.

Goal

Before continuing bundling work, restore a known-good HTML layout so that:

All expected dashboard DOM elements exist.

Status, SSE, chat, and delegation code have real targets in the document.

We can verify behavior while we continue to unify scripts into the bundle.

Hotfix Plan

Restore public/dashboard.html from the pre-bundle baseline:

Use public/dashboard.pre-bundle-tag.html (previously preserved) as the source of truth for the full layout.

Rebuild the dashboard bundle with the existing esbuild script:

npm run build:dashboard-bundle

Manually re-verify:

Dashboard cards render visibly.

Uptime/health/metrics elements appear.

Matilda chat card appears.

Task delegation controls appear.

Once rendering is confirmed:

Continue Phase 11 bundling work (STEP 3B and beyond) from this visually stable baseline.

Notes

This hotfix does not change any DB behavior (still deferred to Phase 11.5).

It prioritizes visible rendering and UI usability over immediate script consolidation.

Bundling & listener-guard work will proceed after confirming that the dashboard UI is alive again.
