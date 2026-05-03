
Phase 11 – STEP 3A: Entry File & Bundling Script Inspection
Purpose

STEP 3A is a read-only inspection step before changing any JS or bundler config.

Goals:

See how /bundle.js is currently built via package.json scripts.

Inspect public/js/dashboard-bundle-entry.js to understand its current role.

Capture notes that will guide safe entry-file wiring and esbuild setup.

No DB behavior is touched in this step.

1. package.json – Bundling / Build Scripts
Commands run in terminal

cat package.json | sed -n '1,160p'

Relevant findings

Existing build/bundle scripts:

"build:dashboard-bundle": "esbuild public/js/dashboard-bundle-entry.js --bundle --outfile=public/bundle.js --sourcemap"

Tool(s) used:

esbuild (already present in devDependencies as "esbuild": "^0.27.0")

Script that appears to generate /bundle.js:

npm run build:dashboard-bundle

Notes / concerns:

Bundling pipeline for /bundle.js already exists and targets public/js/dashboard-bundle-entry.js as the entry.

No explicit format, target, or minify flags are specified yet; defaults will apply.

Good news: we do not need to invent a new bundler or script, just refine how the entry file composes modules.

2. public/js/dashboard-bundle-entry.js – Current Behavior
Commands run in terminal

sed -n '1,200p' public/js/dashboard-bundle-entry.js

Observed contents

import "./dashboard-status.js";
import "./dashboard-graph-loader.js";
import "./dashboard-graph.js";
import "./dashboard-broadcast.js";
import "../scripts/dashboard-reflections.js";
import "../scripts/dashboard-ops.js";
import "../scripts/dashboard-chat.js";

Findings

Uses ES module import syntax:

Yes — the file is an ES module and relies on side-effect imports.

Imports task-related modules (list):

None explicitly related to task delegation/activity/completion in this file yet.

Imports agent-status-related modules (list):

./dashboard-status.js

Imports SSE-related modules (list):

../scripts/dashboard-reflections.js

../scripts/dashboard-ops.js

Imports Matilda chat–related modules (list):

../scripts/dashboard-chat.js

Direct DOM or window usage:

Not visible here; modules likely do top-level DOM operations internally.

Entry file = side-effect aggregator.

3. Quick Interpretation Checklist

Script already builds /bundle.js?

Yes. npm run build:dashboard-bundle.

Does entry file orchestrate everything?

Partially. It imports modules for their side effects, but does not define an ordered init flow.

Modules safe to import directly:

Likely graphs, broadcast, status modules — needs confirmation in STEP 3B.

Modules needing initX() instead of top-level execution:

SSE modules

Chat modules

Possibly dashboard-status

Potential red flags:

Side-effect-only pattern risks double listeners.

SSE may be created multiple times.

Chat handlers might bind multiple times.

4. Handoff Notes

Now that STEP 3A is complete, the project is ready for:

STEP 3B – Implement entry file imports, ordered initialization, and guard/singleton protection for SSE, chat, and delegation.

