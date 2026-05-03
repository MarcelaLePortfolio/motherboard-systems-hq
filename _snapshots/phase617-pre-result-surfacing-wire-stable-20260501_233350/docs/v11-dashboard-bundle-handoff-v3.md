# v11 Dashboard Bundling — Phase 1 Complete, Phase 2 Handoff

## 1. Where you are

- Repo: `Motherboard_Systems_HQ`
- Branch: `feature/v11-dashboard-bundle` (tracking `origin/feature/v11-dashboard-bundle`)
- Golden rollback tag: `v11.0-stable-dashboard`

Stability:

- SSE still healthy (verified via `curl` to:
  - `http://127.0.0.1:3101/events/reflections`
  - `http://127.0.0.1:3201/events/ops`
- Dashboard backend is assumed to be running on port `3000` via `server.mjs` (and/or PM2) as in previous phases.

Key artifacts:

- `public/dashboard.html` — current active dashboard (Gemini version + bundle wiring).
- `public/dashboard.pre-bundle-tag.html` — backup of Gemini-constructed dashboard **before** bundle wiring.
- `public/bundle.js` — esbuild-compiled dashboard bundle.
- `docs/v11-dashboard-bundle-status.md` — detailed status log.
- `docs/v11-dashboard-bundle-next-steps.md` — earlier planning doc.
- `docs/v11-dashboard-bundle-todo.md` — concise TODO snapshot.

## 2. What Phase 1 accomplished

Phase 1 goals were:

1. **Introduce a reproducible bundle build** (without changing runtime behavior).
2. **Wire the bundle into the dashboard HTML** in a strictly additive way, preserving the Gemini layout.

Completed:

- `package.json` now includes:

  - `"scripts": { "build:dashboard-bundle": "esbuild public/js/dashboard-bundle-entry.js --bundle --outfile=public/bundle.js --sourcemap" }`
  - `esbuild` listed in `devDependencies`.

- Running:

  - `pnpm run build:dashboard-bundle`

  produces:

  - `public/bundle.js` (~475 KB)
  - `public/bundle.js.map` (ignored via `.gitignore`).

- **Esbuild warning** (non-fatal, documented):

  - Import `renderTaskActivityGraph` from `public/js/task-activity-graph.js` is reported as undefined because that file has no exports.
  - Source: `public/js/dashboard-graph-loader.js`.
  - This is a future cleanup, not a blocker for bundling.

- `public/dashboard.html`:

  - Matches the Gemini-constructed version, with **one additive change**:
    - A single `<script src="bundle.js"></script>` is injected just before `</body>`.
  - Existing script tags have **not** been removed yet.

- Backup:

  - `public/dashboard.pre-bundle-tag.html` contains the Gemini HTML before inserting the bundle script tag.

All of this is recorded in:

- `docs/v11-dashboard-bundle-status.md` (Phase 1 section).

## 3. Guardrails for Phase 2 (removing redundant script tags)

Phase 2 must **only** start once:

- The dashboard is visually confirmed to be working with:
  - All original script tags.
  - The new `bundle.js` tag.

Phase 2 should:

1. **Inventory existing script tags** in `public/dashboard.html`:

   - Identify each `<script>` tag that loads:
     - `public/dashboard.js`
     - `public/dashboard-stream.js`
     - `public/dashboard-logs.js` / `dashboard-logs.v3.js`
     - Any scripts under `public/scripts/` (e.g., `dashboard-chat.js`, `dashboard-ops.js`, `dashboard-reflections.js`, `matilda-chat.js`)
     - Any scripts under `public/js/` (e.g., `dashboard-bundle-entry.js`, `dashboard-status.js`, etc.)

2. **Cross-map to bundle entry**:

   - Compare the script tags to the imports in `public/js/dashboard-bundle-entry.js`:

     - `./dashboard-status.js`
     - `./dashboard-graph-loader.js`
     - `./dashboard-graph.js`
     - `./dashboard-broadcast.js`
     - `../scripts/dashboard-reflections.js`
     - `../scripts/dashboard-ops.js`
     - `../scripts/dashboard-chat.js`

   - Any script directly imported into `dashboard-bundle-entry.js` is already included in the bundle.

3. **Define a removal order**:

   - Start with scripts that are **directly imported** by `dashboard-bundle-entry.js`.
   - Leave any "mystery" or legacy scripts (e.g., `dashboard.backup.js`, older tab/log variants) for last.
   - Avoid touching any CDN or third-party scripts (like `chart.js`).

4. **Safe removal procedure** (for the future thread):

   For each candidate script tag:

   1. Comment it out or remove it from `public/dashboard.html`.
   2. Rebuild bundle (if needed):
      - `pnpm run build:dashboard-bundle`
   3. Reload `http://localhost:3000/dashboard.html` and verify:
      - Chat still works (Matilda conversation, delegate button).
      - SSE tiles for OPS and Reflections still show live state.
      - Task activity graph still renders (if previously working).
      - No new errors in the browser console.

   4. If anything breaks:
      - Restore the script tag from `public/dashboard.pre-bundle-tag.html` or via `git diff`/`git restore`.
      - Treat that script as a "required until refactor" item and move it down the removal list.

5. **Keep rollback simple**:

   - The existence of `v11.0-stable-dashboard` tag means you can always restore the pre-bundle world by:
     - Hard resetting to the tag on a **new branch**, or
     - Using the pre-bundle backup files if you only want to revert `dashboard.html`.

## 4. How to resume in a future thread

When you come back:

1. Re-orient:

   - `cd /Users/marcela-dev/Projects/Motherboard_Systems_HQ`
   - `git status`
   - `git branch --show-current` (expect `feature/v11-dashboard-bundle`)

2. Review docs:

   - `sed -n '1,200p' docs/v11-dashboard-bundle-status.md`
   - `sed -n '1,200p' docs/v11-dashboard-bundle-handoff-v3.md`
   - `sed -n '1,200p' docs/v11-dashboard-bundle-todo.md`

3. Rebuild bundle (if necessary):

   - `pnpm run build:dashboard-bundle`

4. Check runtime:

   - `lsof -i :3000 -i :3101 -i :3201 || true`
   - `curl -N http://127.0.0.1:3101/events/reflections | head -n 10 || true`
   - `curl -N http://127.0.0.1:3201/events/ops | head -n 10 || true`

5. Begin Phase 2:

   - Stream the bottom portion of `public/dashboard.html` into the new thread so we can:
     - Inventory the current `<script>` tags.
     - Decide the first **single** script tag to remove or comment out.
     - Generate a `cat > public/dashboard.html << 'EOF'` edit that only removes that one tag.

This file is the anchor for continuing Phase 2 safely without losing alignment with the Gemini-constructed dashboard or your v11 golden rules.

