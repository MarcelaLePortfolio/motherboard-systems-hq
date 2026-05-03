
Phase 11 – STEP 2: Bundling Strategy Design
Objective

Create a single, reliable JavaScript bundle for the dashboard that:

Eliminates multiple scattered script tags

Prevents double listeners and duplicate handlers

Preserves SSE stability (OPS + Reflections)

Preserves Matilda Chat behavior

Preserves Task Delegation behavior

Maintains dashboard layout and right-column stability

Supports future modular growth

Reduces load-time complexity

This step produces the specification for the bundling system.
Actual implementation occurs in STEP 3.

1. Current State Summary (From STEP 1)

Scripts loaded directly in dashboard.html:

/bundle.js

/js/dashboard-status.js

/js/matilda-chat-console.js

Candidate internal modules discovered:

public/js/*

public/scripts/*

public/dashboard.js

Interpretation:

/bundle.js is already a bundled artifact.

It likely originates from public/js/dashboard-bundle-entry.js.

dashboard-status.js and matilda-chat-console.js are not yet folded into the bundle.

2. Goal: One Unified Bundle

All dashboard behavior should be consolidated into one file:

/bundle.js

This bundle will contain:

Dashboard UI mount logic

Agent status and tiles

Task delegation

Task activity graphs

Task completion logic

SSE handlers (OPS and Reflections)

Chat handlers (Matilda Chat Console)

Dashboard status updates

Any shared utilities or helpers

Only one script tag will remain in dashboard.html:

<script src="/bundle.js"></script>
3. Proposed Entrypoint

Entrypoint file:

public/js/dashboard-bundle-entry.js

This file should:

Import all internal modules

Initialize the dashboard root

Wire up SSE streams

Wire up Matilda Chat Console

Wire up task delegation components

Wire up agent status tiles

Avoid leaking symbols globally unless strictly necessary

If Matilda or SSE needs global access, we expose a narrow surface, for example:

window.MBHQ = { matilda, streams, status };

4. Modules to Fold Into the Bundle

Must fold:

public/js/dashboard-status.js

public/js/matilda-chat-console.js

public/scripts/dashboard-ops.js

public/scripts/dashboard-reflections.js

public/scripts/dashboard-chat.js

public/js/task-delegation.js

public/js/task-activity.js

public/js/task-completion.js

public/js/agent-status.js

public/js/agent-status-row.js

Candidate legacy modules (to refactor or absorb):

public/dashboard.js

public/dashboard-stream.js

public/dashboard-logs.js

public/dashboard-logs.v3.js

public/dashboard-tabs.js

We will decide in STEP 3 whether they should merge as-is, be partially inlined, or be retired.

5. Load-Order Rules to Preserve

5.1 /bundle.js must initialize the DOM first

All card containers must exist before:

Dashboard status updates

Matilda Chat Console initialization

5.2 SSE must not attach duplicate listeners

We will enforce a guard, e.g.:

Use a window.MBHQ_SSE_INITIALIZED flag

Only attach listeners if the flag is not set

Set the flag immediately after attaching

5.3 Chat handlers must only attach once

We will ensure:

Only one submit listener is bound to the Matilda chat form, or

A similar singleton guard (e.g., window.MBHQ.chatInitialized) is used.

6. Bundler Recommendation

Use esbuild as the bundler.

Baseline config (conceptual):

Entry: public/js/dashboard-bundle-entry.js

Output: public/bundle.js

Format: immediately-invoked function (IIFE) for now

Target: ES2020

Minify: off during Phase 11 for debugging

Sourcemap: true for dashboard debugging

The actual CLI command and config file will be defined in STEP 3.

7. Acceptance Criteria Before Proceeding to STEP 3

Bundling strategy is ready when:

Entrypoint file is confirmed (public/js/dashboard-bundle-entry.js or an explicitly chosen alternative)

Import tree is mapped at a high level (which features live in which modules)

Legacy files are classified (merge, partial-merge, or retire)

SSE double-bind protections are defined conceptually

Chat double-bind protections are defined conceptually

Task delegation wiring path is identified (which module owns it)

Agent status update flow is mapped (which module owns it)

Build system choice (esbuild) is documented

Final dashboard.html script-tag configuration is planned

Expected final HTML change in dashboard.html:

Current:

<script src="/bundle.js"></script> <script src="/js/dashboard-status.js"></script> <script src="/js/matilda-chat-console.js"></script>

Target:

<script src="/bundle.js"></script>

No other dashboard scripts should be directly loaded by the HTML once the bundling work is complete and verified.

8. Handoff Note for STEP 3

STEP 3 will:

Define the actual esbuild command or config

Wire dashboard-bundle-entry.js to import and initialize all required modules

Remove any dead or duplicate legacy modules

Update dashboard.html to rely solely on /bundle.js

Run manual verification to ensure:

Matilda Chat Console works

Task Delegation works

SSE streams (OPS and Reflections) reconnect cleanly

No double listeners are created on reload

Layout remains stable and fully rendered, including the right column

