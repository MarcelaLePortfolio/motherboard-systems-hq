# v11 Dashboard Bundling — Handoff v2

Branch: `feature/v11-dashboard-bundle`  
Baseline rollback tag: `v11.0-stable-dashboard`

## 1. Current state (after this session)

- Esbuild is configured and working via `package.json`:

  - `"build:dashboard-bundle": "esbuild public/js/dashboard-bundle-entry.js --bundle --outfile=public/bundle.js --sourcemap"`

- Successful build produced:

  - `public/bundle.js` (~475 KB)
  - `public/bundle.js.map` (now ignored via `.gitignore` and safe to regenerate on demand)

- Dashboard bundle entry:

  - `public/js/dashboard-bundle-entry.js` is a pure import fan-in of:
    - `./dashboard-status.js`
    - `./dashboard-graph-loader.js`
    - `./dashboard-graph.js`
    - `./dashboard-broadcast.js`
    - `../scripts/dashboard-reflections.js`
    - `../scripts/dashboard-ops.js`
    - `../scripts/dashboard-chat.js`

- Esbuild warning:

  - Non-fatal mismatch between `dashboard-graph-loader.js` and `task-activity-graph.js`
  - Can be cleaned up later; does not block bundling or wiring.

- No runtime wiring changes have been made yet:

  - `public/dashboard.html` still uses the existing multiple `<script>` tags.
  - There is **no** `<script src="bundle.js"></script>` yet.

## 2. Safety checkpoints

- Rollback:

  - You can always return to the last stable dashboard baseline via:

    - `git fetch --all --tags`
    - `git reset --hard v11.0-stable-dashboard`
    - Restart servers as needed (PM2 or `node server.mjs` etc.)

- Bundler reproducibility:

  - Rebuild the bundle at any time with:

    - `pnpm run build:dashboard-bundle`

  - This will regenerate `public/bundle.js` and `public/bundle.js.map` (sourcemap ignored by git).

## 3. Next concrete task (for the *next* working session)

Goal: **Wire `bundle.js` into `public/dashboard.html` non-destructively**, then verify behavior.

### 3.1. Backup the current dashboard HTML

From repo root:

- `cp public/dashboard.html public/dashboard.pre-bundle-tag.html`

This preserves a known-good copy of the dashboard markup before adding the bundle tag.

### 3.2. Capture full dashboard.html for AI-assisted edit

Because `dashboard.html` is large and has many style/script blocks, the safest workflow is:

1. Dump the entire file to the ChatGPT thread in manageable chunks (for example):

   - `sed -n '1,200p' public/dashboard.html`
   - `sed -n '200,400p' public/dashboard.html`
   - ...repeat until the full file is provided.

2. Ask ChatGPT to:
   - Reconstruct the full file.
   - Insert a **single** `<script src="bundle.js"></script>` near the bottom (just before `</body>`).
   - Keep **all existing script tags** in place for this first wiring step.
   - Return a terminal-ready `cat > public/dashboard.html << 'EOF'` block with the updated content.

3. Apply the returned `cat` block to overwrite `public/dashboard.html`.

This preserves the golden rule:

- First change is **additive** (bundle + existing scripts), not destructive.

### 3.3. Manual runtime verification

Once the new `dashboard.html` is in place:

1. Rebuild bundle (if needed):

   - `pnpm run build:dashboard-bundle`

2. Ensure servers are running:

   - `lsof -i :3000 -i :3101 -i :3201`
   - Or restart your stack (PM2 / direct node processes).

3. Open the dashboard in the browser and confirm:

   - Agent tiles (Matilda, Cade, Effie, OPS, Reflections) are visible and updating.
   - OPS and Reflections SSE feeds still stream (check logs/indicators).
   - Chat section still connects and responds.
   - Task activity graph still renders (if it did before).

If everything behaves as expected, the next phase (Phase 2 of bundling) will be:

- Gradually remove now-redundant script tags from `dashboard.html`, one at a time, confirming that `bundle.js` alone is shouldering their logic.

## 4. Quick re-orient commands for the next thread

From repo root:

- `git status`
- `git branch --show-current`  (expect: `feature/v11-dashboard-bundle`)
- `pnpm run build:dashboard-bundle`
- `sed -n '1,200p' docs/v11-dashboard-bundle-status.md`
- `sed -n '1,200p' docs/v11-dashboard-bundle-handoff-v2.md`

Then proceed to:

- Backup `public/dashboard.html`
- Stream `dashboard.html` into the new ChatGPT thread for the first bundle wiring edit.

