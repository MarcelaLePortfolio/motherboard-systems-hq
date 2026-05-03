
Phase 11 – STEP 3: Bundling Implementation Plan (esbuild + Entry File Wiring)
Objective

Turn the STEP 2 strategy into an actionable, low-risk implementation plan that:

Uses esbuild (or confirms existing bundler) to compile a single /bundle.js

Wires public/js/dashboard-bundle-entry.js as the main entrypoint

Imports and initializes all required dashboard modules

Avoids double-listeners (SSE + chat + delegation)

Leaves DB-backed behavior untouched (still deferred to Phase 11.5)

Keeps the dashboard fully functional during incremental changes

This file describes what to do next and the exact files/areas to touch, without yet forcing risky refactors.

1. Confirm Existing Bundler & Scripts
1.1 Check package.json for existing bundling commands

Planned command:

cat package.json | sed -n '1,160p'

Goal:

Identify any existing bundle, build:dashboard, esbuild, or similar npm scripts.

Determine whether /bundle.js is already produced via a script we should reuse (instead of inventing a new command).

Record findings here:

Bundling script name (if any):

Tool used (esbuild, webpack, etc.):

Output path:

Notes:

2. Inspect Current Entry + Bundle Relationship
2.1 Open public/js/dashboard-bundle-entry.js

Planned command:

sed -n '1,200p' public/js/dashboard-bundle-entry.js

Goal:

See how the entry currently initializes the dashboard.

Identify existing imports (if any) for:

Task delegation

Agent status

SSE

Matilda chat

Note any direct DOM/window usage.

Record summary:

Uses ES modules: (yes/no)

Imports task modules: (which?)

Imports agent status modules: (which?)

Imports SSE modules: (which?)

Imports Matilda chat modules: (which?)

Direct DOM access patterns to be careful about:

3. Map Module Imports for Bundling

Using STEP 1 + STEP 2, decide how modules should be wired:

3.1 Target imports from dashboard-bundle-entry.js:

Planned conceptual imports:

./task-delegation.js

./task-activity.js

./task-completion.js

./agent-status.js

./agent-status-row.js

Potentially ../scripts/dashboard-ops.js

Potentially ../scripts/dashboard-reflections.js

Potentially ../scripts/dashboard-chat.js

./dashboard-status.js

./matilda-chat-console.js

In this step we only plan the import graph:

Which modules are safe to import directly?

Which modules require light refactor (e.g., wrap code in an init() instead of top-level side effects)?

Which legacy modules will remain unused after bundling?

Fill this out before editing files:

Modules to import as-is:

Modules that need an initX() function:

Modules to retire (with justification):

4. Design Initialization Order Inside Entry File

We want all initialization to happen through one orchestrated sequence in dashboard-bundle-entry.js, for example:

Ensure DOM ready (DOMContentLoaded or equivalent)

Initialize base layout / cards

Initialize SSE streams (OPS, Reflections)

Initialize agent status tiles

Initialize task delegation UI

Initialize task activity / completion listeners

Initialize Matilda Chat Console

Planned pseudocode (high-level sketch only):

initLayout()

initSSE()

initAgentStatus()

initDelegation()

initTasks()

initMatildaChatConsole()

Use this section to sketch that sequence before writing real code.

5. Double-Listener & Singleton Guards

Based on pain points, define the specific guard patterns you will use.

5.1 SSE Guard

Singleton pattern, example:

Global flag: window.__MBHQ_SSE_INITIALIZED__

Only attach EventSource listeners if not already set.

Set the flag immediately after attaching.

5.2 Matilda Chat Guard

Options:

Attach form submit listener with { once: true } and rebind only on reload.

Or maintain window.MBHQ.chatInitialized and skip if true.

5.3 Task Delegation Guard

Ensure delegation buttons/forms use a single handler per element.

Avoid re-binding handlers on the same DOM nodes.

Record chosen patterns here so STEP 4 (verification) knows exactly what to test.

6. Planned esbuild Command (Conceptual)

Before editing package.json, define the planned CLI usage.

Example (subject to adjustment based on package.json and existing tooling):

Entry: public/js/dashboard-bundle-entry.js

Output: public/bundle.js

Format: iife

Target: es2020

Sourcemap: true

Minify: false (for Phase 11 debugging)

Sketch:

npx esbuild public/js/dashboard-bundle-entry.js --bundle --outfile=public/bundle.js --format=iife --target=es2020 --sourcemap

In this step we are only documenting this plan.
Actual script/command insertion into package.json will be done after confirming there is no conflict with existing scripts.

7. Safety Guardrails for Implementation

When you actually implement:

Do not modify DB-backed endpoints or behavior (Phase 11.5 only).

Do not remove /js/dashboard-status.js or /js/matilda-chat-console.js from dashboard.html until:

The new bundle is built and tested locally.

Dashboard status behavior works.

Matilda Chat Console works.

Use small, focused commits:

One for entry file imports + basic wiring.

One for esbuild script introduction.

One for removing extra <script> tags (once verified).

Additionally:

If the bundler change introduces any uncertainty, revert to the last known tag/commit for Phase 11 and re-approach with smaller changes (follow your three-failed-attempts rule).

8. Next Actions Checklist (For Future You)

Before editing any JS or package.json, complete these:

 Inspect package.json for existing bundling/build scripts.

 Inspect public/js/dashboard-bundle-entry.js and summarize behavior.

 Decide which modules will be imported into the entry file and how.

 Define the initialization sequence (layout, SSE, status, tasks, chat).

 Choose concrete singleton/guard implementations for SSE, chat, and delegation.

 Draft the exact esbuild command that will generate /bundle.js.

After this plan is completed and checked, you can safely proceed to:

STEP 3A – Implement entry file imports and init sequence.
STEP 3B – Wire esbuild into package.json or a dedicated script.
STEP 3C – Rebuild /bundle.js and test the dashboard locally.

