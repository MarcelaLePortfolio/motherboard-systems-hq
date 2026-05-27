
Phase 11 – STEP 3B: Entry File Wiring & Initialization Implementation

This file contains the specific code changes needed to:

Add explicit initialization flows

Wrap unsafe side-effect modules in initX() functions

Add SSE/chat/delegation singleton guards

Safely expand the bundle to replace standalone scripts

No changes will be executed automatically — this is the blueprint for controlled edits.

1. Goals for STEP 3B

We will:

Convert /public/js/dashboard-bundle-entry.js from a side-effect importer into an ordered orchestrator:

Example target shape:

import { initStatus } from "./dashboard-status.js";
import { initGraphs } from "./dashboard-graph-loader.js";
import { initBroadcast } from "./dashboard-broadcast.js";
import { initReflections } from "../scripts/dashboard-reflections.js";
import { initOps } from "../scripts/dashboard-ops.js";
import { initChat } from "../scripts/dashboard-chat.js";
import { initMatildaConsole } from "./matilda-chat-console.js";
import { initTaskDelegation } from "./task-delegation.js";

export function initDashboard() {
initStatus();
initGraphs();
initBroadcast();
initReflections();
initOps();
initChat();
initMatildaConsole();
initTaskDelegation();
}

document.addEventListener("DOMContentLoaded", initDashboard);

This ensures:

One-time initialization

Controlled ordering

Prevention of top-level side effects

2. Define initX() wrappers needed in each module

Modules needing wrappers:

dashboard-status.js

dashboard-reflections.js (SSE)

dashboard-ops.js (SSE)

dashboard-chat.js

matilda-chat-console.js

task-delegation.js

Example transformation:

Before:

const es = new EventSource("/events/reflections");
es.onmessage = ...

After:

let reflectionsInitialized = false;

export function initReflections() {
if (reflectionsInitialized) return;
reflectionsInitialized = true;

const es = new EventSource("/events/reflections");
es.onmessage = ...
}

3. Add universal singleton guards

3.1 SSE guard

if (!window.MBHQ_SSE) window.MBHQ_SSE = {};

export function initOps() {
if (window.MBHQ_SSE.ops) return;
window.MBHQ_SSE.ops = true;
...
}

3.2 Chat guard

export function initChat() {
if (window.MBHQ_CHAT_INIT) return;
window.MBHQ_CHAT_INIT = true;

const form = document.getElementById("matilda-chat-form");
if (!form) return;
form.addEventListener("submit", handleChatSubmit);
}

3.3 Delegation guard

export function initTaskDelegation() {
if (window.MBHQ_DELEGATION_INIT) return;
window.MBHQ_DELEGATION_INIT = true;
...
}

4. Entry File Rewrite Plan

Replace current imports:

import "./dashboard-status.js";
import "./dashboard-graph-loader.js";
import "./dashboard-graph.js";
import "./dashboard-broadcast.js";
import "../scripts/dashboard-reflections.js";
import "../scripts/dashboard-ops.js";
import "../scripts/dashboard-chat.js";

With explicit init imports:

import { initStatus } from "./dashboard-status.js";
import { initGraphs } from "./dashboard-graph-loader.js";
import { initBroadcast } from "./dashboard-broadcast.js";
import { initReflections } from "../scripts/dashboard-reflections.js";
import { initOps } from "../scripts/dashboard-ops.js";
import { initChat } from "../scripts/dashboard-chat.js";
import { initMatildaConsole } from "./matilda-chat-console.js";
import { initTaskDelegation } from "./task-delegation.js";

Then add orchestrator:

document.addEventListener("DOMContentLoaded", () => {
initStatus();
initGraphs();
initBroadcast();
initReflections();
initOps();
initChat();
initMatildaConsole();
initTaskDelegation();
});

5. Safety Rules Before Committing Code

Do NOT remove <script> tags from dashboard.html yet.

Do NOT delete legacy modules yet.

Do NOT introduce DB logic.

After each change:

Rebuild bundle: npm run build:dashboard-bundle

Refresh dashboard and verify:

No double listeners

Chat works

Delegation works

SSE streams work

No JS console errors

If anything destabilizes the UI:
REVERT immediately to last stable commit.

6. Completion Criteria for STEP 3B

STEP 3B is complete when:

All modules have init() wrappers where needed.

Entry file has orchestrated initialization flow.

Singleton guards prevent multiple listener bindings.

Bundle builds successfully.

Dashboard loads without duplicated behavior.

All changes are committed safely.

