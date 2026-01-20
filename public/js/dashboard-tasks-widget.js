/**
 * Tasks Widget (stable, no SSE)
 * - GET /api/tasks
 * - POST /api/tasks/complete
 * - No optimistic removal (prevents list blinking)
 */
(() => {
  const API = {
      list: "/api/tasks",
      complete: "/api/tasks/complete",
    };

  const SELECTORS = [
    "#tasks-widget",
    "#tasksWidget",
    "[data-tasks-widget]",
    "[data-widget='tasks']",
  ];

  const state = {
    tasks: [],
    loading: false,
    lastError: null,
    inflightComplete: new Set(),
  };

  function $(sel, root = document) {
    return root.querySelector(sel);
  }

  function findMount() {
    for (const sel of SELECTORS) {
      const el = $(sel);
      if (el) return el;
    }
    return null;
  }

  function esc(s) {
    return String(s ?? "")
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;");
  }

  async function apiJson(url, opts = {}) {
    const res = await fetch(url, {
      method: opts.method || "GET",
      headers: { "Content-Type": "application/json" },
      body: opts.body ? JSON.stringify(opts.body) : undefined,
    });
    const json = await res.json();
    if (!res.ok) throw new Error(json?.error || "Request failed");
    return json;
  }

  async function fetchTasks() {
    state.loading = true;
    render();
    try {
      const data = await apiJson(API.list);
      state.tasks = (data.tasks || []).map(t => ({
        id: String(t.task_id ?? t.taskId ?? t.id),
        title: t.title || "",
        status: t.status || "",
      }));
    } catch (e) {
      state.lastError = e.message;
    } finally {
      state.loading = false;
      render();
    }
  }

  async function completeTask(taskId) {
    if (state.inflightComplete.has(taskId)) return;
    state.inflightComplete.add(taskId);
    render();

    try {
      await apiJson(API.complete, {
        method: "POST",
        body: { task_id: taskId },
      });
    } catch (e) {
      state.lastError = e.message;
    } finally {
      state.inflightComplete.delete(taskId);
      await fetchTasks();
    }
  }

  function render() {
    const mount = findMount();
    if (!mount) return;

    mount.innerHTML = `
      <div>
        
        ${state.lastError ? `<div style="color:red">${esc(state.lastError)}</div>` : ""}
        <div>
          ${state.tasks.map(t => `
            <div style="display:flex;justify-content:space-between;gap:8px">
              <span>${esc(t.title)}</span>
              ${
                (["complete","completed","done"].includes(String(t.status||"").toLowerCase()))
                  ? `<span style="opacity:.5;font-size:12px">Completed</span>`
                  : `<button data-id="${t.id}">Complete</button>`
              }
            </div>
          `).join("")}
        </div>
      </div>
    `;

    mount.querySelectorAll("button[data-id]").forEach(btn => {
      btn.onclick = () => completeTask(btn.dataset.id);
    });
  }

  document.addEventListener("DOMContentLoaded", fetchTasks);

  // Phase22: SSE-driven refresh (ignore heartbeats)
  window.addEventListener("mb.task.event", (e) => {
    const k = String(e?.detail?.kind || e?.detail?.type || "");
    if (k === "heartbeat") return;
    fetchTasks();
  });

// Auto-refresh (no SSE): keep widget feeling live
  setInterval(() => { fetchTasks(); }, 5000);

})();
