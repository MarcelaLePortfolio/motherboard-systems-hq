# Next Steps – Matilda Chat Console Phase 2

Branch: feature/v11-dashboard-bundle

Current baseline:

- Matilda Chat Console:
  - Visible directly under the main header in the dark dashboard UI.
  - Frontend wired to POST /api/chat with:
    - { "message": "<user text>", "agent": "matilda" }
  - Works in:
    - Local dev (server.mjs on port 3000)
    - Containerized dashboard (motherboard_systems_hq-dashboard via docker-compose)
- Docker:
  - Dockerfile.dashboard builds a node:20-alpine image and runs server.mjs.
  - .dockerignore keeps node_modules and build artifacts out of the build context.
  - scripts/docker-dashboard-up.sh:
    - Waits for Docker daemon.
    - Runs docker-compose build && docker-compose up -d.

This document captures the main "Phase 2" paths forward so future work resumes cleanly.

---

## Path 1 – UI Polish for Matilda Chat Console

Goal:
- Make the Matilda Chat Console card feel native to the existing dashboard grid layout.

Potential tasks:
- Align spacing with other cards (margin, padding, border radius).
- Match fonts, font sizes, and header styling from existing cards.
- Move card to a specific column/row position:
  - e.g., directly above Task Delegation card in the main grid.
- Add subtle hover/focus states for the Send button and textarea.

Files to touch:
- public/js/matilda-chat-console.js (DOM insertion, inline styling)
- css/dashboard.css (optional – move styling from inline JS to CSS classes)

---

## Path 2 – Replace Placeholder Matilda Logic

Goal:
- Upgrade /api/chat from a pure placeholder to a meaningful Matilda pipeline.

Potential tasks:
- In server.mjs:
  - Replace "Matilda placeholder" reply with:
    - Real agent call (Matilda runtime) OR
    - Call out to the existing delegation / mirror wrapper, then return a summary.
- Add basic error handling and timeouts:
  - Surface friendly error messages in the chat console UI.
- Optionally log chat exchanges for debugging:
  - Append to logs/reflections or a dedicated chat log.

Files to touch:
- server.mjs (/api/chat route)
- public/js/matilda-chat-console.js (improved error messages / status)

---

## Path 3 – Bundle Integration Cleanup

Goal:
- Make Matilda Chat Console part of the official JS bundle instead of a separate script tag.

Potential tasks:
- Integrate matilda-chat-console.js into the existing bundling pipeline:
  - e.g., import into the main entry file used by bundle.js.
- Remove direct <script defer src="js/matilda-chat-console.js"></script> from public/index.html once bundled.
- Ensure dev vs container builds both use the same bundling pattern.

Files to touch:
- public/js/matilda-chat-console.js (possibly converted to a module)
- Any bundler config (esbuild/rollup/etc.)
- public/index.html (script tag cleanup once stable)

---

## Path 4 – Production / Remote Deployment

Goal:
- Promote the containerized dashboard (with Matilda Chat) to a remote environment.

Potential tasks:
- Decide on target (e.g., Fly.io, Render, Railway, VPS).
- Push the motherboard_systems_hq-dashboard image or build remotely.
- Configure environment variables:
  - NODE_ENV=production
  - PORT (if not 3000)
- Expose the dashboard over HTTPS using existing tunnel or cloud provider options.

Files / infrastructure to touch:
- docker-compose.yml (if extended for prod)
- Cloud provider config / infra as code (if any)
- Tunnel / reverse proxy configuration

---

## Path 5 – Return to Phase 11 Dashboard Bundling Tasks

Goal:
- Continue the broader Phase 11 work:
  - JS/CSS bundling
  - Dashboard reliability
  - Clean separation of dev vs staging vs demo modes

Potential tasks:
- Consolidate multiple script tags into a single compiled bundle.
- Ensure the dashboard’s layout, SSE hooks, and agent status tiles are robust under reloads.
- Tag a new stable baseline once Matilda Chat + bundling is verified:
  - e.g., v11.2-matilda-chat-bundled

---

## Recommended Next Step

If resuming from scratch after a break:

1. Reconfirm current state:
   - Visit local dev dashboard (server.mjs on port 3000).
   - Visit containerized dashboard (docker-compose up path).
   - Ensure Matilda Chat Console appears and can send/receive placeholder replies.

2. Choose a path:
   - If UI bothers you → start with Path 1.
   - If functionality is more important → start with Path 2.
   - If you want codebase cleanliness first → Path 3.
   - If you are demo-focused → Path 5 (bundling and stability) or Path 4 (remote deploy).

This document is the anchor so future threads can quickly pick a single path and proceed
without re-deriving context.
