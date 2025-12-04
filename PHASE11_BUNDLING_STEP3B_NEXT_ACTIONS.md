
Phase 11 – STEP 3B: Immediate Next Actions

STEP 3B blueprint is in place:

PHASE11_BUNDLING_STEP3_IMPLEMENTATION_PLAN.md

PHASE11_BUNDLING_STEP3A_STATUS.md

PHASE11_BUNDLING_STEP3B_IMPLEMENTATION.md

This file captures the very next concrete actions before changing any JS.

1. Inspect Each Imported Module (Read-Only)

Run these commands to inspect the modules that will need initX() wrappers and/or guards.

From project root:

Dashboard status + graphs + broadcast

sed -n '1,200p' public/js/dashboard-status.js
sed -n '1,200p' public/js/dashboard-graph-loader.js
sed -n '1,200p' public/js/dashboard-graph.js
sed -n '1,200p' public/js/dashboard-broadcast.js

SSE modules (Reflections + OPS)

sed -n '1,200p' public/scripts/dashboard-reflections.js
sed -n '1,200p' public/scripts/dashboard-ops.js

Dashboard chat + Matilda-specific scripts

sed -n '1,200p' public/scripts/dashboard-chat.js
sed -n '1,200p' public/js/matilda-chat-console.js

Task delegation

sed -n '1,200p' public/js/task-delegation.js || echo "task-delegation.js missing"

Paste outputs (or key excerpts) into the STEP 3B implementation file or into a future ChatGPT thread so we can design minimal initX() wrappers without guessing.

2. Confirm Current Bundle Still Builds

Before editing any JS, confirm the bundling pipeline is healthy:

npm run build:dashboard-bundle

Expected:

Command completes without error.

public/bundle.js and public/bundle.js.map are updated.

If this fails, STOP and fix the bundler baseline before changing modules.

3. When Ready to Edit Code

After the inspections above:

Identify which modules:

Already have clear, isolated setup blocks that can become initX().

Contain top-level EventSource or addEventListener calls that must be wrapped.

Begin with the lowest-risk module (often dashboard-status or graphs) and:

Introduce export function initStatus() or similar.

Replace top-level calls with that function body.

Wire it from dashboard-bundle-entry.js as per STEP3B blueprint.

Rebuild bundle and test locally.

Follow the Phase 11 rule:

Small changes

Small commits

Max 3 failed attempts per approach, then revert and reconsider

4. Handoff Reminder

To resume this work in a new thread, you can say:

"Continue Phase 11 bundling from PHASE11_BUNDLING_STEP3B_IMPLEMENTATION.md and PHASE11_BUNDLING_STEP3B_NEXT_ACTIONS.md."

