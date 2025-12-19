/**
 * Tasks Widget (bulletproof, no SSE required)
 * - Renders tasks from GET /api/tasks
 * - Complete button -> POST /api/complete-task { taskId }
 * - Optimistic UI update + automatic refetch for consistency
 */
(() => {
  const API = {
    list: "/api/tasks",
    complete: "/api/complete-task",
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
    lastFetchAt: 0,
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

  function normalizeTask(t) {
    return {
      id: String(t.id),
      title: t.title || "",
      agent: t.agent || "",
      status: t.status || "",
      notes: t.notes || "",
      created_at: t.created_at || null,
      updated_at: t.updated_at || null,
    };
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
      const list = Array.isArray(data) ? data : data.tasks || [];
      state.tasks = list.map(normalizeTask);
      state.lastFetchAt = Date.now();
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

    state.tasks = state.tasks.filter(t => t.id !== taskId);
    render();

    try {
      await apiJson(API.complete, {
        method: "POST",
        body: { taskId },
      });
      await fetchTasks();
    } catch (e) {
      state.lastError = e.message;
      await fetchTasks();
    } finally {
      state.inflightComplete.delete(taskId);
    }
  }

  function render() {
    const mount = findMount();
    if (!mount) return;

    mount.innerHTML = `
      <div>
        <strong>Tasks</strong>
        ${state.lastError ? `<div style="color:red">${esc(state.lastError)}</div>` : ""}
        <div>
          ${state.tasks.map(t => `
            <div style="display:flex;justify-content:space-between">
              <span>${esc(t.title)}</span>
              <button data-id="${t.id}">Complete</button>
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
})();
