/**
 * Dashboard Tasks Widget (Next-2)
 * - Subscribes to /events/tasks (SSE)
 * - Renders a lightweight "Recent Tasks" list under Task Delegation
 * - Safe/no-op if elements are missing
 */
(function () {
  if (typeof window === "undefined" || typeof document === "undefined") return;
  if (window.__dashboardTasksWidgetInited) return;
  window.__dashboardTasksWidgetInited = true;

  const TASKS_SSE_URL = "/events/tasks";
  const MAX_ITEMS = 8;

  function ensureContainer() {
    const delegationCard = document.getElementById("delegation-card");
    if (!delegationCard) return null;

    let box = document.getElementById("recent-tasks-box");
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
    hint.textContent = "Waiting for /events/tasks…";

    box.appendChild(title);
    box.appendChild(list);
    box.appendChild(hint);

    // Insert right after the delegation response area if possible; else append to card
    const anchor = document.getElementById("delegation-response");
    if (anchor && anchor.parentNode === delegationCard) {
      anchor.insertAdjacentElement("afterend", box);
    } else {
      delegationCard.appendChild(box);
    }

    return box;
  }

  function renderTasks(tasks) {
    const box = ensureContainer();

    /* Self-heal: if hint exists but container/list are missing, build them around the hint */
    const __hint = document.getElementById("recent-tasks-hint");
    let __container = document.getElementById("recent-tasks-container");
    let __list = document.getElementById("recent-tasks-list");

    if (__hint && (!__container || !__list)) {
      const __mount = __hint.parentElement;

      if (!__container) {
        __container = document.createElement("div");
        __container.id = "recent-tasks-container";
        __container.appendChild(__hint); /* move hint into container */
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
    if (!box) return;

    const list = document.getElementById("recent-tasks-list");
    const hint = document.getElementById("recent-tasks-hint");
    if (!list) return;

    const safe = Array.isArray(tasks) ? tasks : [];
    if (hint) { hint.style.display = safe.length ? "none" : "block"; hint.textContent = safe.length ? "" : "Waiting for /events/tasks…"; }

    list.innerHTML = "";
    safe.slice(0, MAX_ITEMS).forEach((t) => {
      const row = document.createElement("div");
      row.className = "flex items-center justify-between gap-3 text-sm";

      const left = document.createElement("div");
      left.className = "text-gray-200 truncate";
      const title = (t && (t.title || t.task || t.name)) ? String(t.title || t.task || t.name) : "(untitled)";
      left.textContent = title;

      const right = document.createElement("div");
      right.className = "text-xs text-gray-400 flex items-center gap-2";

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

    /* Self-heal: if hint exists but container/list are missing, build them around the hint */
    const __hint = document.getElementById("recent-tasks-hint");
    let __container = document.getElementById("recent-tasks-container");
    let __list = document.getElementById("recent-tasks-list");

    if (__hint && (!__container || !__list)) {
      const __mount = __hint.parentElement;

      if (!__container) {
        __container = document.createElement("div");
        __container.id = "recent-tasks-container";
        __container.appendChild(__hint); /* move hint into container */
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

    let es;
    try {
      es = new EventSource(TASKS_SSE_URL);
    } catch (err) {
      console.warn("[tasks-widget] Failed to open SSE:", err);
      return;
    }

    es.onmessage = (event) => {
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
      const hint = document.getElementById("recent-tasks-hint");
      if (hint) {
        hint.style.display = "block";
        hint.textContent = "Tasks stream disconnected — check /events/tasks.";
      }
    };
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start);
  } else {
    start();
  }
})();
