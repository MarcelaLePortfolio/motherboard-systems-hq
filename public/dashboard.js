/*
Phase 31.6 — Recent Tasks empty-state helper

Why this exists:

The dashboard "Recent Tasks" panel is driven by task-events (SSE) + mb.task.event bridge.

When the worker is intentionally scaled to 0, /events/task-events will usually stream only
hello/heartbeat frames (cursor advances) but no task.* events — leaving the panel blank.

This helper renders a friendly empty-state until a task.* event arrives.

Notes:

This file is intentionally lightweight and non-invasive.

It does NOT alter the core renderer; it only adds/removes an empty-state message.
*/
(() => {
const container = document.getElementById("recentTasks");
if (!container) {
// keep old behavior of warning if someone is on a page without this panel
try { console.warn("⚠️ No #recentTasks container found."); } catch {}
return;
}

const EMPTY_SEL = '[data-empty="recent-tasks"]';
let sawTask = false;

function ensureEmpty() {
if (container.querySelector(EMPTY_SEL)) return;
const box = document.createElement("div");
box.dataset.empty = "recent-tasks";
box.className =
  "text-sm text-slate-300/90 border border-white/10 rounded-2xl p-4 bg-white/5";

const title = document.createElement("div");
title.className = "font-semibold text-slate-100";
title.textContent = "No task events yet";

const body = document.createElement("div");
body.className = "mt-2 leading-relaxed";
body.innerHTML =
  'You are connected to <code class="px-1 py-0.5 rounded bg-black/30 border border-white/10">/events/task-events</code>, but only <span class="opacity-90">heartbeats</span> are arriving. ' +
  'If the worker is intentionally scaled to <code class="px-1 py-0.5 rounded bg-black/30 border border-white/10">0</code>, this is expected.';

const cursor = document.createElement("div");
cursor.id = "recentTasksCursor";
cursor.className = "mt-3 opacity-80";
cursor.textContent = "";

box.appendChild(title);
box.appendChild(body);
box.appendChild(cursor);

container.appendChild(box);
}

function clearEmpty() {
const el = container.querySelector(EMPTY_SEL);
if (el) el.remove();
}

// When any task.* event hits the bridge, remove the empty-state immediately.
window.addEventListener("mb.task.event", (e) => {
try {
const ev = e?.detail || {};
const kind = String(ev.kind || "");
if (kind.startsWith("task.")) {
sawTask = true;
clearEmpty();
}
} catch {}
});

// After a short delay, if no task events arrived, show the message and (if available) cursor.
setTimeout(() => {
if (sawTask) return;
ensureEmpty();
try {
const snap = window.__taskEventsSnap || null; // set by task-events SSE client (if present)
const cursor = snap?.cursor ?? null;
if (cursor != null) {
const el = document.getElementById("recentTasksCursor");
if (el) el.textContent = last heartbeat cursor: ${cursor};
}
} catch {}
}, 1500);
})();
