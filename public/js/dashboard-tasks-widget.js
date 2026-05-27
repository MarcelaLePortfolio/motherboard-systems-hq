/**
 * Tasks Widget + Runs Panel
 * - Stable DOM shell (prevents runs panel remount churn)
 * - Debounced task refresh
 * - Conservative polling
 * - No SSE-triggered fetch storm
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

  const TASK_POLL_MS = 15000;
  const RUNS_POLL_MS = 15000;
  const TASK_EVENT_DEBOUNCE_MS = 1000;

  const state = {
    tasks: [],
    loading: false,
    lastError: null,
    inflightComplete: new Set(),
    shellMounted: false,
    taskFetchPromise: null,
    taskFetchTimer: null,
    runsPanelMounted: false,
    runsPanelTimer: null,
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
      fetchTasksNow().catch((e) => console.warn("[tasks] refresh failed", e));
    }, delayMs);
  }

  async function completeTask(taskId) {
    if (!taskId || state.inflightComplete.has(taskId)) return;
    state.inflightComplete.add(taskId);
    render();

    try {
      await apiJson(API.complete, {
        method: "POST",
        body: { task_id: taskId },
      });
      state.lastError = null;
    } catch (e) {
      state.lastError = e?.message || String(e);
    } finally {
      state.inflightComplete.delete(taskId);
      scheduleFetchTasks(0);
    }
  }

  function buildRunsQuery({ limit, task_status, is_terminal, since_ts }) {
    const p = new URLSearchParams();
    if (limit != null && String(limit).trim() !== "") p.set("limit", String(limit));
    for (const s of task_status || []) p.append("task_status", String(s));
    if (is_terminal === "true" || is_terminal === "false") p.set("is_terminal", is_terminal);
    if (since_ts != null && String(since_ts).trim() !== "") p.set("since_ts", String(since_ts));
    return p.toString();
  }

  async function fetchRuns({ limit, task_status, is_terminal, since_ts }) {
    const q = buildRunsQuery({ limit, task_status, is_terminal, since_ts });
    const url = "/api/runs" + (q ? "?" + q : "");
    const r = await fetch(url, { headers: { Accept: "application/json" } });
    const j = await r.json().catch(() => ({}));
    if (!r.ok) throw new Error(j?.error || j?.detail || "HTTP_" + r.status);
    return j;
  }

  function fmtTs(ms) {
    const n = Number(ms);
    if (!Number.isFinite(n)) return "";
    try {
      return new Date(n).toISOString();
    } catch {
      return String(ms);
    }
  }

  function renderRunsPanel(root) {
    if (!root) return;
    if (root.querySelector('[data-runs-panel="1"]')) return;

    const wrap = document.createElement("div");
    wrap.dataset.runsPanel = "1";
    wrap.className = "card";
    wrap.style.marginTop = "12px";

    const hdr = document.createElement("div");
    hdr.className = "card-header";
    hdr.innerHTML = `<div style="display:flex;align-items:center;gap:10px;justify-content:space-between;">
      <div>
        <div class="card-title">Runs</div>
        <div class="card-subtitle">Read-only from <code>run_view</code> via <code>/api/runs</code> (server ordering is canonical)</div>
      </div>
      <button class="btn" id="runs-refresh-btn" type="button">Refresh</button>
    </div>`;
    wrap.appendChild(hdr);

    const body = document.createElement("div");
    body.className = "card-body";

    const controls = document.createElement("div");
    controls.style.display = "flex";
    controls.style.flexWrap = "wrap";
    controls.style.gap = "10px";
    controls.style.marginBottom = "10px";

    controls.innerHTML = `
      <label style="display:flex;flex-direction:column;gap:4px;">
        <span>limit (1..200)</span>
        <input id="runs-limit" class="input" type="number" min="1" max="200" value="50" />
      </label>

      <label style="display:flex;flex-direction:column;gap:4px;">
        <span>task_status</span>
        <select id="runs-status" class="select" multiple size="4">
          <option value="created">created</option>
          <option value="running">running</option>
          <option value="completed">completed</option>
          <option value="failed">failed</option>
          <option value="canceled">canceled</option>
          <option value="cancelled">cancelled</option>
        </select>
      </label>

      <label style="display:flex;flex-direction:column;gap:4px;">
        <span>is_terminal</span>
        <select id="runs-terminal" class="select">
          <option value="">(any)</option>
          <option value="true">true</option>
          <option value="false">false</option>
        </select>
      </label>

      <label style="display:flex;flex-direction:column;gap:4px;">
        <span>since_ts (epoch-ms)</span>
        <input id="runs-since-ts" class="input" type="text" placeholder="" />
      </label>

      <label style="display:flex;flex-direction:column;gap:4px;">
        <span>last X minutes → since_ts</span>
        <input id="runs-last-min" class="input" type="number" min="1" step="1" placeholder="e.g. 60" />
      </label>
    `;

    body.appendChild(controls);

    const statusLine = document.createElement("div");
    statusLine.style.fontFamily = "monospace";
    statusLine.style.fontSize = "12px";
    statusLine.style.opacity = "0.8";
    statusLine.style.margin = "6px 0";
    body.appendChild(statusLine);

    const tableWrap = document.createElement("div");
    tableWrap.style.overflowX = "auto";

    const table = document.createElement("table");
    table.className = "table";
    table.style.width = "100%";
    table.innerHTML = `
      <thead>
        <tr>
          <th>run_id</th>
          <th>task_id</th>
          <th>task_status</th>
          <th>is_terminal</th>
          <th>last_event_ts</th>
          <th>last_event_kind</th>
          <th>actor</th>
          <th>lease_ttl_ms</th>
          <th>heartbeat_age_ms</th>
        </tr>
      </thead>
      <tbody id="runs-tbody"></tbody>
    `;
    tableWrap.appendChild(table);
    body.appendChild(tableWrap);

    wrap.appendChild(body);
    root.appendChild(wrap);

    const $limit = wrap.querySelector("#runs-limit");
    const $status = wrap.querySelector("#runs-status");
    const $terminal = wrap.querySelector("#runs-terminal");
    const $since = wrap.querySelector("#runs-since-ts");
    const $lastMin = wrap.querySelector("#runs-last-min");
    const $refresh = wrap.querySelector("#runs-refresh-btn");
    const $tbody = wrap.querySelector("#runs-tbody");

    function readFilters() {
      const limit = String($limit.value || "50").trim() || "50";
      const task_status = Array.from($status.selectedOptions || []).map((o) => o.value);
      const is_terminal = String($terminal.value || "").trim();
      let since_ts = String($since.value || "").trim();

      const lastMin = String($lastMin.value || "").trim();
      if (!since_ts && lastMin) {
        const n = Number(lastMin);
        if (Number.isFinite(n) && n > 0) {
          since_ts = String(Date.now() - Math.floor(n * 60_000));
          $since.value = since_ts;
        }
      }

      return { limit, task_status, is_terminal, since_ts };
    }

    function renderRows(rows) {
      $tbody.innerHTML = "";
      for (const r of rows || []) {
        const tr = document.createElement("tr");
        tr.innerHTML = `
          <td><code>${esc(String(r.run_id ?? ""))}</code></td>
          <td><code>${esc(String(r.task_id ?? ""))}</code></td>
          <td>${esc(String(r.task_status ?? ""))}</td>
          <td>${esc(String(r.is_terminal ?? ""))}</td>
          <td><code>${esc(fmtTs(r.last_event_ts))}</code></td>
          <td>${esc(String(r.last_event_kind ?? ""))}</td>
          <td>${esc(String(r.actor ?? ""))}</td>
          <td><code>${r.lease_ttl_ms == null ? "" : esc(String(r.lease_ttl_ms))}</code></td>
          <td><code>${r.heartbeat_age_ms == null ? "" : esc(String(r.heartbeat_age_ms))}</code></td>
        `;
        $tbody.appendChild(tr);
      }
    }

    let runsRefreshInFlight = false;

    async function refresh() {
      if (runsRefreshInFlight) return;
      const f = readFilters();
      const q = buildRunsQuery(f);
      statusLine.textContent = "GET /api/runs" + (q ? "?" + q : "");

      try {
        runsRefreshInFlight = true;
        $refresh.disabled = true;
        const j = await fetchRuns(f);
        renderRows(j.rows || []);
        statusLine.textContent += `  → count=${j.count ?? (j.rows?.length ?? 0)}`;
      } catch (e) {
        statusLine.textContent += `  → ERROR: ${String(e?.message || e)}`;
        renderRows([]);
      } finally {
        runsRefreshInFlight = false;
        $refresh.disabled = false;
      }
    }

    $refresh.addEventListener("click", refresh);
    $limit.addEventListener("change", refresh);
    $terminal.addEventListener("change", refresh);
    $status.addEventListener("change", refresh);
    $since.addEventListener("change", refresh);
    $lastMin.addEventListener("change", refresh);

    if (state.runsPanelTimer) clearInterval(state.runsPanelTimer);
    state.runsPanelTimer = setInterval(() => {
      if (document.hidden) return;
      refresh();
    }, RUNS_POLL_MS);

    refresh();
  }

  document.addEventListener("DOMContentLoaded", () => {
    render();
    scheduleFetchTasks(0);
  });

  window.addEventListener("mb.task.event", (e) => {
    const k = String(e?.detail?.kind || e?.detail?.type || "");
    if (!k || k === "heartbeat" || k === "task.heartbeat") return;
    if (!k.startsWith("task.")) return;

    window.__MB_TASKS_SSE_SEEN = true;
    window.__MB_TASKS_LAST_TASK_EVENT_AT = Date.now();
    scheduleFetchTasks(TASK_EVENT_DEBOUNCE_MS);
  });

  if (typeof window.__MB_TASKS_SSE_SEEN === "undefined") window.__MB_TASKS_SSE_SEEN = false;
  if (typeof window.__MB_TASKS_LAST_TASK_EVENT_AT === "undefined") window.__MB_TASKS_LAST_TASK_EVENT_AT = 0;

  setInterval(() => {
    if (document.hidden) return;

    const seen = !!window.__MB_TASKS_SSE_SEEN;
    const age = Date.now() - (window.__MB_TASKS_LAST_TASK_EVENT_AT || 0);

    if (seen && age < 30000) return;

    scheduleFetchTasks(0);
  }, TASK_POLL_MS);
})();
