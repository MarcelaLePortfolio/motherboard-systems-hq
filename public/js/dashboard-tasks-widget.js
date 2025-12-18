/**
 * Dashboard Tasks Widget (Next-2)
 * - Subscribes to /events/tasks (SSE)
 * - Renders a lightweight "Recent Tasks" list under Task Delegation
 * - UX hardening (Phase 13): loading/empty/error/stale + dedupe + timestamps
 */
(function () {
  if (typeof window === "undefined" || typeof document === "undefined") return;

  // Allow safe re-eval without duplicate streams (bundle reload / navigation)
  if (window.__dashboardTasksWidgetInited) return;
  window.__dashboardTasksWidgetInited = true;

  const TASKS_SSE_URL = "/events/tasks";
  const MAX_ITEMS = 8;
  const STALE_MS = 15_000;
  const STALE_TICK_MS = 5_000;

  function el(id) { return document.getElementById(id); }

  function ensureContainer() {
    const delegationCard = el("delegation-card");
    if (!delegationCard) return null;

    let box = el("recent-tasks-box");
    if (box) return box;

    box = document.createElement("div");
    box.id = "recent-tasks-box";
    box.className = "mt-3 bg-gray-900 border border-gray-700 rounded-lg p-3";

    const title = document.createElement("div");
    title.className = "text-xs uppercase tracking-wide text-gray-400 mb-2";
    title.textContent = "Recent Tasks";

    const list = document.createElement("div");
    list.id = "recent-tasks-list";
    list.className = "space-y-2";

    const hint = document.createElement("div");
    hint.id = "recent-tasks-hint";
    hint.className = "text-xs text-gray-500 italic";
    hint.textContent = "Loading tasks…";

    box.appendChild(title);
    box.appendChild(list);
    box.appendChild(hint);

    // Insert right after the delegation response area if possible; else append to card
    const anchor = el("delegation-response");
    if (anchor && anchor.parentNode === delegationCard) {
      anchor.insertAdjacentElement("afterend", box);
    } else {
      delegationCard.appendChild(box);
    }

    return box;
  }

  function selfHealHintContainer() {
    const __hint = el("recent-tasks-hint");
    let __container = el("recent-tasks-container");
    let __list = el("recent-tasks-list");

    if (__hint && (!__container || !__list)) {
      const __mount = __hint.parentElement;

      if (!__container) {
        __container = document.createElement("div");
        __container.id = "recent-tasks-container";
        __container.appendChild(__hint); // move hint into container
        __mount.appendChild(__container);
      } else if (__hint.parentElement !== __container) {
        __container.appendChild(__hint);
      }

      if (!__list) {
        __list = document.createElement("div");
        __list.id = "recent-tasks-list";
        __container.appendChild(__list);
      }
    }
  }

  function setHint(text) {
    const hint = el("recent-tasks-hint");
    if (!hint) return;
    hint.style.display = "block";
    hint.textContent = text;
  }

  function clearHint() {
    const hint = el("recent-tasks-hint");
    if (!hint) return;
    hint.style.display = "none";
    hint.textContent = "";
  }

  function fmtTime(s) {
    if (!s) return "";
    const d = new Date(String(s));
    if (isNaN(d.getTime())) return "";
    return d.toLocaleString();
  }

  function dedupeTasks(tasks) {
    const safe = Array.isArray(tasks) ? tasks : [];
    const seen = new Set();
    const out = [];
    for (const t of safe) {
      const id = t && (t.id != null) ? String(t.id) : "";
      const key = id || JSON.stringify(t || {});
      if (seen.has(key)) continue;
      seen.add(key);
      out.push(t);
    }
    return out;
  }

  function renderTasks(tasks) {
    const box = ensureContainer();
    selfHealHintContainer();
    if (!box) return;

    const list = el("recent-tasks-list");
    if (!list) return;

    const items = dedupeTasks(tasks).slice(0, MAX_ITEMS);

    list.innerHTML = "";

    if (!items.length) {
      setHint("No recent tasks yet.");
      return;
    }

    clearHint();

    items.forEach((t) => {
      const row = document.createElement("div");
      row.className = "flex items-start justify-between gap-3 text-sm";

      const left = document.createElement("div");
      left.className = "min-w-0 flex-1";

      const title = document.createElement("div");
      title.className = "text-gray-200 truncate";
      title.textContent =
        (t && (t.title || t.task || t.name)) ? String(t.title || t.task || t.name) : "(untitled)";

      const sub = document.createElement("div");
      sub.className = "text-xs text-gray-500 mt-0.5 truncate";

      const created = fmtTime(t && (t.created_at || t.createdAt));
      const updated = fmtTime(t && (t.updated_at || t.updatedAt));
      const when = updated || created;
      sub.textContent = when ? `Updated: ${when}` : "";

      left.appendChild(title);
      if (sub.textContent) left.appendChild(sub);

      const right = document.createElement("div");
      right.className = "text-xs text-gray-400 flex items-center gap-2 shrink-0";

      const agent = (t && t.agent) ? String(t.agent) : "—";
      const status = (t && t.status) ? String(t.status) : "unknown";

      const pill = document.createElement("span");
      pill.className = "px-2 py-0.5 rounded-full bg-gray-800 border border-gray-700";
      pill.textContent = status;

      const meta = document.createElement("span");
      meta.textContent = agent;

      right.appendChild(pill);
      right.appendChild(meta);

      row.appendChild(left);
      row.appendChild(right);
      list.appendChild(row);
    });
  }

  function start() {
    ensureContainer();
    selfHealHintContainer();
    setHint("Loading tasks…");

    // Close any prior instance to prevent duplicates (bundle reloads / navigation)
    try {
      if (window.__dashboardTasksWidgetES && typeof window.__dashboardTasksWidgetES.close === "function") {
        window.__dashboardTasksWidgetES.close();
      }
    } catch (e) {
      // ignore
    }

    let es;
    try {
      es = new EventSource(TASKS_SSE_URL);
      window.__dashboardTasksWidgetES = es;
    } catch (err) {
      console.warn("[tasks-widget] Failed to open SSE:", err);
      setHint("Tasks stream unavailable — check /events/tasks.");
      return;
    }

    window.__dashboardTasksWidgetLastEventAt = Date.now();
    window.__dashboardTasksWidgetDisconnected = false;

    es.onmessage = (event) => {
      window.__dashboardTasksWidgetLastEventAt = Date.now();
      window.__dashboardTasksWidgetDisconnected = false;

      let data;
      try {
        data = JSON.parse(event.data || "null");
      } catch {
        return;
      }
      if (!data) return;

      const tasks = data.tasks || data.items || [];
      window.__latestTasksSnapshot = data;
      renderTasks(tasks);
    };

    es.onerror = () => {
      window.__dashboardTasksWidgetDisconnected = true;
      setHint("Tasks stream disconnected — check /events/tasks.");
    };

    // Soft stale indicator (no console spam)
    if (!window.__dashboardTasksWidgetStaleTimer) {
      window.__dashboardTasksWidgetStaleTimer = setInterval(() => {
        const last = window.__dashboardTasksWidgetLastEventAt || 0;
        const disconnected = !!window.__dashboardTasksWidgetDisconnected;
        if (disconnected) return; // error hint already shown
        if (!last) return;
        const age = Date.now() - last;
        if (age > STALE_MS) {
          setHint("Tasks stream quiet (stale) — waiting for updates…");
        }
      }, STALE_TICK_MS);
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start);
  } else {
    start();
  }
})();
