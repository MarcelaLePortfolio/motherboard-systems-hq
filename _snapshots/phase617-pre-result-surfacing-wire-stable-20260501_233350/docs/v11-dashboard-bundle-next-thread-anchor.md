# v11 Dashboard Bundling — Next Thread Anchor

Branch: `feature/v11-dashboard-bundle`  
Rollback tag: `v11.0-stable-dashboard`

This file is a tiny pointer so the *next* ChatGPT thread can get oriented in under a minute.

---

## 1. Re-orient

From repo root:

- cd /Users/marcela-dev/Projects/Motherboard_Systems_HQ
- git status
- git branch --show-current  # should be: feature/v11-dashboard-bundle

If not on the branch:

- git fetch
- git checkout feature/v11-dashboard-bundle

---

## 2. Skim core docs (in this order)

Quickly scan:

- sed -n '1,200p' docs/v11-dashboard-bundle-status.md
- sed -n '1,200p' docs/v11-dashboard-bundle-handoff-v3.md
- sed -n '1,200p' docs/v11-dashboard-bundle-todo.md
- sed -n '1,200p' docs/v11-dashboard-bundle-thread-summary-2025-11-27.md
- sed -n '1,200p' docs/v11-dashboard-bundle-handoff-thread3.md

These files contain:

- What Phase 1 did (esbuild + bundle wiring).
- What Phase 2 should do (script-tag consolidation).
- Golden-rule guardrails and rollback notes.

---

## 3. Sanity checks

If you want to test before editing:

- pnpm run build:dashboard-bundle
- lsof -i :3000 -i :3101 -i :3201 || true
- curl -N http://127.0.0.1:3101/events/reflections | head -n 10 || true
- curl -N http://127.0.0.1:3201/events/ops | head -n 10 || true

Then open:

- http://localhost:3000/dashboard.html

to confirm the Gemini dashboard + bundle.js still behave.

---

## 4. Starting Phase 2 in the next thread

When you’re ready to continue bundling:

1. Stream the bottom of dashboard.html (where scripts live):

   - sed -n '1,220p' public/dashboard.html  # or narrower range if needed

2. Ask ChatGPT to:

   - Inventory the existing <script> tags.
   - Choose ONE tag for first removal (or comment-out).
   - Return a full:

     - cat > public/dashboard.html << 'EOF'
       ...
       EOF

     replacement that only changes that one tag and preserves everything else.

3. After applying:

   - pnpm run build:dashboard-bundle
   - Reload dashboard in browser
   - Check for regressions and console errors

If anything feels off, restore from backup or git:

- cp public/dashboard.pre-bundle-tag.html public/dashboard.html
- or: git restore public/dashboard.html

This anchor file should be enough for future-you + ChatGPT to resume safely without re-reading the entire history of this thread.

