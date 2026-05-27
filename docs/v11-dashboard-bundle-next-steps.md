# v11 Dashboard Bundling — Immediate Next Steps
Branch: feature/v11-dashboard-bundle
Baseline tag: v11.0-stable-dashboard

This file captures the very next concrete moves so any new thread can reorient quickly and continue safely without touching runtime behavior prematurely.

---

## 1. Reorient and sanity-check

From repo root:

- Confirm branch and status:
  - git status
  - git branch --show-current  (expect: feature/v11-dashboard-bundle)

- Optional: rerun the inspection helper:
  - ./scripts/v11-dashboard-bundle-inspect.sh

Goal: verify we are still on the bundling branch, with tag v11.0-stable-dashboard available as rollback.

---

## 2. Inspect bundling entry point

Target file (from prior inspection script):

- public/js/dashboard-bundle-entry.js

Next commands to run in terminal (read-only inspection):

- sed -n '1,160p' public/js/dashboard-bundle-entry.js
- sed -n '160,320p' public/js/dashboard-bundle-entry.js

Questions to answer while reading:

1. Does this file use ES module syntax (import/export), or does it assume globals via window.*?
2. Which other modules from public/js does it import or reference?
3. Does it wire up:
   - SSE connections for OPS (port 3201)?
   - SSE connections for Reflections (port 3101)?
   - Agent tiles (Matilda, Cade, Effie, OPS, Reflections)?
   - Task activity / graph canvas?

We do NOT edit anything yet. This is pure inspection.

---

## 3. Inspect package.json for existing bundler tooling

From repo root:

- sed -n '1,200p' package.json
- sed -n '200,400p' package.json

Questions to answer while reading:

1. Is there any dependency like esbuild, webpack, rollup, vite, parcel, or similar?
2. Are there any scripts that sound like bundling:
   - "build", "build:dashboard", "bundle", "bundle:dashboard", "dashboard:build", etc.?
3. Does any existing build script already output to public/bundle.js or a similar path?

Based on the answers:

- If there is an existing bundler:
  - Prefer reusing it and pointing it at public/js/dashboard-bundle-entry.js.
- If there is NO bundler yet:
  - Plan to introduce a minimal esbuild-based script dedicated to the dashboard bundle.

We still do NOT change code yet. Only read and decide.

---

## 4. Decide bundler strategy (planning only)

After inspecting:

- If bundler exists:
  - Identify:
    - Input file: ideally public/js/dashboard-bundle-entry.js.
    - Output file: confirm or standardize on public/bundle.js.
  - Check whether the current public/bundle.js (208 KB) matches what the bundler claims to build or looks like a stale artifact.

- If no bundler exists:
  - Plan to:
    - Add esbuild as a dev dependency (via pnpm).
    - Add a script such as:
      - "build:dashboard": "esbuild public/js/dashboard-bundle-entry.js --bundle --outfile=public/bundle.js --sourcemap"
    - Keep this step on paper until we explicitly decide to modify package.json.

This file is intentionally only a planning scaffold; the actual edit to package.json will come in a later, clearly labeled step.

---

## 5. Future step (not to execute yet): wire bundle into dashboard.html

Once bundler behavior is understood and stable, the later sequence will be:

1. Add a single bundle script tag near the bottom of:
   - public/dashboard.html
   Example (concept only, not yet applied):
   - <script src="bundle.js"></script>

2. Confirm the dashboard still works with both:
   - Existing script tags.
   - New bundle.js.

3. Gradually remove redundant script tags in dashboard.html once the bundle is verified to include their logic.

That refactor is deliberately deferred until:

- We know exactly what dashboard-bundle-entry.js does.
- We know exactly how public/bundle.js is built.
- We have a clear rollback path via v11.0-stable-dashboard.

---

## 6. How to use this file in the next session

When starting a new ChatGPT thread:

1. Navigate to repo:
   - cd /Users/marcela-dev/Projects/Motherboard_Systems_HQ

2. Confirm branch and status:
   - git status
   - git branch --show-current

3. Open this file for a quick reminder:
   - sed -n '1,200p' docs/v11-dashboard-bundle-next-steps.md

4. Then begin with:
   - Inspect public/js/dashboard-bundle-entry.js.
   - Inspect package.json.
   - Report findings back to ChatGPT so it can generate precise, minimal edits (package.json + later dashboard.html) using the golden rules.

