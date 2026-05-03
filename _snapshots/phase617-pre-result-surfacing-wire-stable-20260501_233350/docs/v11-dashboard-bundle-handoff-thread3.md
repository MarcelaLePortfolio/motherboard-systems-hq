# v11 Dashboard Bundling — Minimal Handoff Stub (Thread 3 Anchor)

Branch: `feature/v11-dashboard-bundle`  
Rollback tag: `v11.0-stable-dashboard`

This stub exists so any **future thread** has a single, lightweight anchor that points to the core v11 bundling docs and confirms the current state.

---

## 1. Current state (as of 2025-11-27)

- `feature/v11-dashboard-bundle` is up-to-date with origin.
- Phase 1 of bundling is complete:
  - `pnpm run build:dashboard-bundle` works and produces `public/bundle.js`.
  - `public/dashboard.html`:
    - Matches the Gemini baseline layout.
    - Has a **single additive change**: `<script src="bundle.js"></script>` inserted right before `</body>`.
  - `public/dashboard.pre-bundle-tag.html` is the pre-bundle Gemini snapshot.
- `.gitignore` ensures `public/bundle.js.map` is ignored.
- SSE endpoints for Reflections (`3101`) and OPS (`3201`) are healthy when the stack is running.

Detailed records are in:

- `docs/v11-dashboard-bundle-status.md`
- `docs/v11-dashboard-bundle-next-steps.md`
- `docs/v11-dashboard-bundle-todo.md`
- `docs/v11-dashboard-bundle-handoff-v3.md`
- `docs/v11-dashboard-bundle-thread-summary-2025-11-27.md`

This file is intentionally short and just serves as a **pointer**.

---

## 2. How to resume work (quick checklist)

When you open a new ChatGPT thread for v11 bundling:

1. Re-orient:

   - `cd /Users/marcela-dev/Projects/Motherboard_Systems_HQ`
   - `git status`
   - `git branch --show-current`  (expect: `feature/v11-dashboard-bundle`)

2. Review the main docs:

   - `sed -n '1,200p' docs/v11-dashboard-bundle-status.md`
   - `sed -n '1,200p' docs/v11-dashboard-bundle-handoff-v3.md`
   - `sed -n '1,200p' docs/v11-dashboard-bundle-todo.md`
   - `sed -n '1,200p' docs/v11-dashboard-bundle-thread-summary-2025-11-27.md`

3. Rebuild bundle (if needed):

   - `pnpm run build:dashboard-bundle`

4. Check runtime health (if servers are supposed to be up):

   - `lsof -i :3000 -i :3101 -i :3201 || true`
   - `curl -N http://127.0.0.1:3101/events/reflections | head -n 10 || true`
   - `curl -N http://127.0.0.1:3201/events/ops | head -n 10 || true`

5. Begin whatever the **next** bundling phase is at that time (likely Phase 2):

   - Stream the relevant portion of `public/dashboard.html` into the new thread.
   - Ask ChatGPT for a single, minimal `cat > public/dashboard.html << 'EOF'` edit following your golden rules.

---

This stub should be the first doc you glance at when re-opening the v11 bundling work in a new thread; it simply redirects you to the richer handoff + status docs without adding more complexity.

