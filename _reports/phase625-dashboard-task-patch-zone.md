# Phase 625 Dashboard Task Patch Zone

## Lines 35-175 from public/js/dashboard-tasks-widget.js
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

  function ensureShell() {
    const mount = findMount();
    if (!mount) return null;

    if (!state.shellMounted) {
      mount.innerHTML = `
        <div data-tasks-shell="1">
          <div data-tasks-error></div>
          <div data-tasks-list></div>
          <div data-runs-host></div>
        </div>
      `;
      state.shellMounted = true;
    }

    const shell = mount.querySelector('[data-tasks-shell="1"]');
    return {
      mount,
      shell,
      errorEl: shell?.querySelector("[data-tasks-error]") || null,
      listEl: shell?.querySelector("[data-tasks-list]") || null,
      runsHost: shell?.querySelector("[data-runs-host]") || null,
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

  function render() {
    const ui = ensureShell();
    if (!ui) return;

    if (ui.errorEl) {
      ui.errorEl.innerHTML = state.lastError
        ? `<div style="color:red">${esc(state.lastError)}</div>`
        : "";
    }

    if (ui.listEl) {
      ui.listEl.innerHTML = `
        <div>
          ${state.loading && !state.tasks.length ? `<div style="opacity:.7">Loading…</div>` : ""}
          ${
            state.tasks.length
              ? state.tasks
                  .map(
                    (t) => `
              <div style="display:flex;justify-content:space-between;gap:8px">
                <span>${esc(t.title)}</span>
                ${
                  ["complete", "completed", "done"].includes(String(t.status || "").toLowerCase())
                    ? `<span style="opacity:.5;font-size:12px">Completed</span>`
                    : `<button data-id="${esc(t.id)}">Complete</button>`
                }
              </div>
            `
                  )
                  .join("")
              : !state.loading
              ? `<div style="opacity:.7">No tasks found.</div>`
              : ""
          }
        </div>
      `;

      ui.listEl.querySelectorAll("button[data-id]").forEach((btn) => {
        btn.onclick = () => completeTask(btn.dataset.id);
      });
    }

    if (ui.runsHost && !state.runsPanelMounted) {
      try {
        renderRunsPanel(ui.runsHost);
        state.runsPanelMounted = true;
      } catch (e) {
        console.warn("[runs] panel mount failed", e);
      }
    }
  }

  async function fetchTasksNow() {
    if (state.taskFetchPromise) return state.taskFetchPromise;

    state.taskFetchPromise = (async () => {
      state.loading = true;
      render();
      try {
        const data = await apiJson(API.list);
        state.tasks = (data.tasks || []).map((t) => ({
          id: String(t.task_id ?? t.taskId ?? t.id),
          title: t.title || "",
          status: t.status || "",
        }));
        state.lastError = null;
      } catch (e) {
        state.lastError = e?.message || String(e);
      } finally {
        state.loading = false;
        render();
        state.taskFetchPromise = null;
      }
    })();

    return state.taskFetchPromise;
  }

  function scheduleFetchTasks(delayMs = 0) {
    if (state.taskFetchTimer) clearTimeout(state.taskFetchTimer);
    state.taskFetchTimer = setTimeout(() => {
      state.taskFetchTimer = null;
