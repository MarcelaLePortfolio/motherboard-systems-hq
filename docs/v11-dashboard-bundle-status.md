# v11 Dashboard Bundling — Status Snapshot

Branch: feature/v11-dashboard-bundle  
Baseline tag: v11.0-stable-dashboard

## 1. Esbuild wiring

Added script in `package.json`:

- `"build:dashboard-bundle": "esbuild public/js/dashboard-bundle-entry.js --bundle --outfile=public/bundle.js --sourcemap"`

This builds:

- `public/bundle.js` (currently ~475 KB)
- `public/bundle.js.map` (ignored via `.gitignore`, regenerated on demand)

## 2. Dashboard bundle entry

File:

- `public/js/dashboard-bundle-entry.js`

Current content (import fan-in):

- `./dashboard-status.js`
- `./dashboard-graph-loader.js`
- `./dashboard-graph.js`
- `./dashboard-broadcast.js`
- `../scripts/dashboard-reflections.js`
- `../scripts/dashboard-ops.js`
- `../scripts/dashboard-chat.js`

This confirms the bundle pulls in both the newer modular JS under `public/js` and the legacy/parallel dashboard scripts under `public/scripts`.

## 3. Esbuild warning (non-fatal)

On build, esbuild reports:

- Import `renderTaskActivityGraph` will always be undefined because the file `public/js/task-activity-graph.js` has no exports.

Source:

- `public/js/dashboard-graph-loader.js` imports `{ renderTaskActivityGraph }` from `./task-activity-graph.js`.

This suggests:

- `dashboard-graph-loader.js` expects a named export from `task-activity-graph.js`,
- But `task-activity-graph.js` likely uses globals or side-effects instead of explicit exports.

For now:

- This is non-fatal and does not prevent `bundle.js` from being generated.
- It is safe to proceed with wiring `bundle.js` into the dashboard while leaving this as a later cleanup task.

## 4. Next safe step (future thread)

The next concrete move for this branch:

1. Add a non-destructive `<script src="bundle.js"></script>` tag near the bottom of `public/dashboard.html`, keeping all existing script tags in place initially.
2. Reload the dashboard in the browser and ensure:
   - Agent tiles (Matilda, Cade, Effie, OPS, Reflections) still render and update.
   - OPS and Reflections SSE feeds still stream.
   - Chat section still works.
   - Task activity graph still renders (if previously working).
3. Only after verifying behavior, begin gradually removing now-redundant script tags, one by one, confirming that the bundle covers their logic.

This doc is a snapshot so any new ChatGPT thread can see:

- Esbuild is configured and working.
- `bundle.js` is reproducible.
- `bundle.js.map` is intentionally ignored.

---

## 5. Phase 1 — bundle.js wiring status (2025-11-27)

- `public/dashboard.html` now matches the Gemini-constructed layout, with a **single** additive change:
  - A `<script src="bundle.js"></script>` tag is injected just before `</body>`.
- Backup snapshot:
  - `public/dashboard.pre-bundle-tag.html` holds the original, pre-bundle Gemini dashboard HTML.
- `pnpm run build:dashboard-bundle` successfully produces:
  - `public/bundle.js` (~475 KB)
  - `public/bundle.js.map` (ignored via `.gitignore`)
- No existing `<script>` tags in `dashboard.html` have been removed yet.
- Next phase (not started):
  - Gradually remove redundant dashboard JS `<script>` tags once runtime behavior is fully validated.


---

## 6. Phase 2 — initial script consolidation (2025-11-27)

- Removed the external CDN Chart.js script tag from `public/dashboard.html`.
- Confirmed Chart.js is now provided exclusively via the bundled ES modules:
  - `public/js/dashboard-graph.js` imports `Chart` from `"chart.js"`.
- Rewrote `public/js/task-activity-graph.js` as an ES module that:
  - Imports `Chart` from `"chart.js"`.
  - Exports `renderTaskActivityGraph(ctx, tasks)` for `dashboard-graph-loader.js`.
- `pnpm run build:dashboard-bundle` now completes with **no warnings**.
- Runtime check:
  - Dashboard chat ok
  - Agent tiles ok
  - Task activity graph renders via the bundled Chart.js dependency.

---

## 7. Phase 2 — script tag consolidation complete

- Confirmed `public/dashboard.html` now uses a single script tag:
  - `<script src="bundle.js"></script>`
- All dashboard JS is loaded via the bundle (no remaining inline or CDN script tags).
- Staging PM2 ecosystem added as `ecosystem.staging.config.cjs` with namespace `main-staging`.

