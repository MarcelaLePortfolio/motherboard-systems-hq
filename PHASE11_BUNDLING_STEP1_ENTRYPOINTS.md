
Phase 11 – Dashboard Bundling STEP 1: Dashboard JS Entrypoints

This file is the authoritative map for all JavaScript entrypoints currently powering the Phase 11 dashboard.
It will be used to design the bundling strategy and verify behavior after bundling.

0. Project Context

Repo: Motherboard_Systems_HQ

Branch: feature/v11-dashboard-bundle

Phase: 11 – Dashboard Bundling & Reliability

Important constraint: All DB-backed work is deferred to Phase 11.5 – DB Task Storage.

Do not modify or reason about database schemas, pools, or DB-backed endpoints as part of this step.

1. Dashboard Template Discovery (Completed)

From the latest filesystem inspection:

There is no src/ directory.

There is no views/ directory.

The active dashboard HTML lives under public/.

1.1 Primary Dashboard Template

Path: public/dashboard.html

Notes: Standalone HTML file that serves as the main Phase 11 dashboard UI.
Contains a single root container:

<div id="dashboard-root"></div>

All cards and UI structure are injected via JavaScript (primarily /bundle.js).

1.2 Related Dashboard Variants / Backups

These are historical or backup variants of the dashboard HTML. They are not the active template but are useful reference during bundling:

public/dashboard.pre-bundle-tag.html

public/dashboard.html.bak

public/dashboard.html.bad_structure

public/dashboard.html.bak_1762372376

public/dashboard.html.bak.1762457360

public/dashboard.html.bak_1762904490

public/dashboard.html.bak_1762905357

public/dashboard.html.bak_9.7.0b

All STEP 1 mapping reflects the current public/dashboard.html.

2. Scope of STEP 1

In this step, you will:

Identify every JavaScript file currently loaded by public/dashboard.html.

Note the order in which scripts are loaded.

Note each script’s type (module, classic, or inline).

Note each script’s role (Matilda Chat, Task Delegation, SSE, layout, utilities, etc.).

Record any obvious dependencies or ordering constraints.

You will not change any JS or HTML as part of STEP 1 — this is a mapping/documentation step only.

3. STEP 1A – Raw Script Tag Inventory (COMPLETED)

Using public/dashboard.html as the source of truth, we listed every <script> tag in the exact order they appear.

3.1 Commands Used

Ripgrep (rg) is not installed on this machine. We used grep + cat:

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

grep -n "<script" public/dashboard.html
cat public/dashboard.html

3.2 Script Tag Table (Active Dashboard)

Source: public/dashboard.html

  <!-- Existing scripts for bundle + status -->
  <script src="/bundle.js"></script>
  <script src="/js/dashboard-status.js"></script>

  <!-- 🔥 NEW: Matilda Chat Console script (enables the new UI card) -->
  <script src="/js/matilda-chat-console.js"></script>


Resulting table:

Order	Script Path / Identifier	Type	Role / Responsibility	Comments
1	/bundle.js	classic	Primary compiled dashboard bundle: injects UI into #dashboard-root, wires cards	Likely built from public/js/dashboard-bundle-entry.js and legacy public/dashboard*.js
2	/js/dashboard-status.js	classic	Dashboard status helper: updates high-level status indicators/components	Lives in public/js/dashboard-status.js
3	/js/matilda-chat-console.js	classic	Matilda Chat Console UI: powers the Matilda card, input, and response rendering	Lives in public/js/matilda-chat-console.js

Notes:

There are no inline <script> blocks in public/dashboard.html.

All behavior is driven by these three external JS files.

3.3 Secondary JS Modules Discovered (NOT directly referenced in dashboard.html)

From directory listings:

ls public/js


Output:

public/js/agent-status-row.js

public/js/agent-status.js

public/js/dashboard-broadcast.js

public/js/dashboard-bundle-entry.js

public/js/dashboard-graph-loader.js

public/js/dashboard-graph.js

public/js/dashboard-status.js

public/js/matilda-chat-console.js

public/js/task-activity-graph.js

public/js/task-activity.js

public/js/task-completion.js

public/js/task-delegation.js

From public/scripts:

public/scripts/agent-status-row.js

public/scripts/dashboard-chat.js

public/scripts/dashboard-ops.js

public/scripts/dashboard-reflections.js

public/scripts/matilda-chat.js

From top-level public/*dashboard*.js:

public/dashboard-logs.js

public/dashboard-logs.v3.js

public/dashboard-status.js

public/dashboard-stream.js

public/dashboard-tabs.backup.js

public/dashboard-tabs.js

public/dashboard.backup.js

public/dashboard.js

Interpretation:

/bundle.js is almost certainly built from one or more of:

public/js/dashboard-bundle-entry.js

public/dashboard.js

plus various feature modules (task, SSE, graphs, agent status, etc.).

Many of these files represent legacy or pre-bundle structures that are now folded into the bundle, but they are still relevant as source modules and for debugging.

We will treat them as candidate internal modules when designing the bundling strategy in STEP 2.

4. STEP 1B – Group Scripts by Functional Area (INITIAL GROUPING)

This section groups both the directly loaded scripts and the secondary modules discovered in public/js, public/scripts, and public/*dashboard*.js.

4.1 Core Dashboard / Layout

Scripts that initialize the dashboard UI, manage tabs/cards, or handle generic layout/DOM wiring.

Directly loaded:

/bundle.js

Source likely includes:

public/js/dashboard-bundle-entry.js

public/dashboard.js

public/dashboard-tabs.js

public/dashboard-logs.js / public/dashboard-logs.v3.js

public/dashboard-stream.js

Possibly public/scripts/dashboard-chat.js, dashboard-ops.js, dashboard-reflections.js

Secondary modules:

public/js/dashboard-bundle-entry.js

public/dashboard.js

public/dashboard-tabs.js

public/dashboard.backup.js (legacy)

public/dashboard-tabs.backup.js (legacy)

public/dashboard-logs.js

public/dashboard-logs.v3.js

public/dashboard-stream.js

4.2 Matilda Chat

Scripts that handle chat with Matilda (UI + API calls).

Directly loaded:

/js/matilda-chat-console.js

public/js/matilda-chat-console.js – powers the Matilda Chat Console card.

Secondary modules:

public/scripts/matilda-chat.js – likely earlier/alternate Matilda chat behavior (pre-console pattern).

public/scripts/dashboard-chat.js – may integrate chat behavior into the main dashboard.

4.3 Task Delegation

Scripts that handle delegation forms/buttons and task-related actions.

Secondary modules (likely bundled into /bundle.js):

public/js/task-delegation.js

public/js/task-activity.js

public/js/task-activity-graph.js

public/js/task-completion.js

Possibly task-related logic inside public/dashboard.js and public/dashboard-stream.js.

4.4 SSE – Reflections / OPS / Other Streams

Scripts that manage server-sent events (SSE) and live dashboard updates.

Secondary modules:

public/scripts/dashboard-ops.js

public/scripts/dashboard-reflections.js

public/dashboard-stream.js (likely SSE for dashboard streams)

Possibly integrated streaming logic in public/dashboard-logs.v3.js.

Currently, these are presumed to be compiled into /bundle.js or wired by public/dashboard.js.

4.5 Agent Status & Tiles

Scripts that manage agent status tiles and rows on the dashboard.

Directly loaded helper:

/js/dashboard-status.js

public/js/dashboard-status.js

Secondary modules:

public/js/agent-status.js

public/js/agent-status-row.js

public/scripts/agent-status-row.js

These likely feed the agent status row/tiles and their live updates.

5. STEP 1C – Ordering & Dependency Notes (INITIAL)

Current order in public/dashboard.html:

/bundle.js

/js/dashboard-status.js

/js/matilda-chat-console.js

Observations / Assumptions

/bundle.js must load first:

It likely mounts the main dashboard UI into #dashboard-root.

It may also attach base SSE handlers and define global helpers used by the other two scripts.

/js/dashboard-status.js is loaded after /bundle.js:

Likely assumes the DOM structure (status elements, containers) has already been created by the bundle.

May rely on globals (e.g., a shared status store or SSE hooks) defined by the bundle.

/js/matilda-chat-console.js is loaded last:

It probably attaches to specific elements within the Matilda Chat Console card created by the bundle.

It may assume both the DOM and any core event buses/utilities are already available.

Potential Ordering Risks

When bundling further or refactoring:

If /js/dashboard-status.js or /js/matilda-chat-console.js are folded into the main bundle or loaded as modules, we must:

Preserve initialization order.

Avoid double-invocation (e.g., same handler running from both bundle and standalone file).

Ensure any DOMContentLoaded or window.onload hooks don’t conflict.

6. STEP 1D – Known Pain Points to Watch During Bundling

From prior Phase 11 work and the current layout:

Double event listeners after reload:

SSE handlers and input listeners must not be registered multiple times.

Multiple EventSource instances for the same endpoint:

Especially for /events/ops and /events/reflections.

Scripts re-attaching DOM handlers without cleanup:

If any script relies on re-rendering or rehydration, we must ensure it doesn’t stack listeners.

Reliance on globals attached to window:

Bundler transformations may change scoping.

Separation of concerns between:

Core bundle (/bundle.js)

Status helper (/js/dashboard-status.js)

Matilda Chat Console (/js/matilda-chat-console.js)

Pain points / risks observed (so far):

The existence of both public/js/* and public/scripts/* plus public/dashboard*.js strongly suggests a mix of legacy and new paths. Bundling must ensure:

Only one canonical path sources the logic for each feature.

No legacy script remains accidentally attached in addition to the bundled code.

7. STEP 1E – Convenience Commands (Reference)

These are terminal commands you can reuse while refining this map or investigating behavior. They are for convenience only and do not modify any files:

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

# List dashboard-related HTML files
ls public/dashboard* public/*dashboard* || true

# Show script tags in active dashboard
grep -n "<script" public/dashboard.html
cat public/dashboard.html

# Show JS modules that likely feed the bundle
ls public/js
ls public/scripts
ls public/*dashboard*.js


You can paste new commands into this section as you work, but do not remove the core STEP 1 structure above.

8. Completion Criteria for STEP 1

STEP 1 is considered functionally mapped when:

 public/dashboard.html is confirmed as the primary template.

 All script tags in public/dashboard.html are listed in the table with:

 Order

 Path / Identifier

 Type

 Role

 Secondary script modules (public/js, public/scripts, public/*dashboard*.js) are inventoried as candidate internal modules.

 Scripts are grouped by functional area (core, chat, delegation, SSE, agent status).

 Initial load-order dependencies and pain points are noted.

You are now ready for:

STEP 2 – Design the bundling strategy (single bundle entrypoint and vendor handling).

In STEP 2 we will:

Decide whether /bundle.js should absorb /js/dashboard-status.js and /js/matilda-chat-console.js.

Identify the true entrypoint file for the bundle (likely public/js/dashboard-bundle-entry.js).

Plan how to avoid double listeners and maintain SSE + Matilda Chat behavior under reloads.
