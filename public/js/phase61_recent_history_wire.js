(function () {
  const RECENT_ENDPOINT = "/api/tasks?limit=12";
  const HISTORY_ENDPOINT = "/api/runs?limit=20";
  const REFRESH_MS = 10000;

  function log() {
    try {
      console.log("[phase61_recent_history_wire]", ...arguments);
    } catch (_) {}
  }

  function escapeHtml(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function formatTime(value) {
    if (value == null || value === "") return "—";
    const d = new Date(value);
    if (!Number.isNaN(d.getTime())) return d.toLocaleString();
    if (typeof value === "number") {
      const n = new Date(value);
      if (!Number.isNaN(n.getTime())) return n.toLocaleString();
    }
    return String(value);
  }

  function statusTone(status) {
    const s = String(status || "").toLowerCase();
    if (/fail|error|cancel|timeout/.test(s)) return "rgba(240,90,90,0.95)";
    if (/complete|done|success|ok/.test(s)) return "rgba(80,200,120,0.95)";
    if (/queue|pending|wait|retry|hold/.test(s)) return "rgba(250,204,21,0.95)";
    if (/run|start|active|lease|progress|created/.test(s)) return "rgba(96,165,250,0.95)";
    return "rgba(255,255,255,0.18)";
  }

  async function fetchJson(url) {
    const res = await fetch(url, {
      headers: { Accept: "application/json" },
      cache: "no-store",
    });

    const text = await res.text();
    let data = {};
    try {
      data = text ? JSON.parse(text) : {};
    } catch (err) {
      throw new Error(`Invalid JSON from ${url}: ${err.message}`);
    }

    if (!res.ok) {
      throw new Error(data?.error || data?.message || `HTTP ${res.status} ${res.statusText}`);
    }

    return data;
  }

  function findRecentCard() {
    return (
      document.getElementById("recent-tasks-card") ||
      document.querySelector("#obs-panel-recent .obs-surface") ||
      document.querySelector("[data-phase61-panel='recent']") ||
      null
    );
  }

  function findHistoryCard() {
    return (
      document.getElementById("task-activity-card") ||
      document.querySelector("#obs-panel-activity .obs-surface") ||
      document.querySelector("[data-phase61-panel='history']") ||
      null
    );
  }

  function buildOwnedShell(key) {
    const shell = document.createElement("div");
    shell.setAttribute("data-phase61-shell", key);
    shell.style.display = "flex";
    shell.style.flexDirection = "column";
    shell.style.gap = "10px";
    shell.style.minHeight = "320px";

    const statusEl = document.createElement("div");
    statusEl.setAttribute("data-phase61-status", key);
    statusEl.style.fontSize = "12px";
    statusEl.style.opacity = ".72";

    const listEl = document.createElement("div");
    listEl.setAttribute("data-phase61-list", key);
    listEl.style.display = "flex";
    listEl.style.flexDirection = "column";
    listEl.style.gap = "8px";

    shell.appendChild(statusEl);
    shell.appendChild(listEl);

    return { shell, statusEl, listEl };
  }

  function ensureOwnedCard(card, key) {
    let shell = card.querySelector(`:scope > [data-phase61-shell="${key}"]`);
    if (!shell) {
      card.innerHTML = "";
      const owned = buildOwnedShell(key);
      card.appendChild(owned.shell);
      shell = owned.shell;
    }

    const statusEl = shell.querySelector(`[data-phase61-status="${key}"]`);
    const listEl = shell.querySelector(`[data-phase61-list="${key}"]`);
    return { shell, statusEl, listEl };
  }

  function renderEmpty(listEl, message) {
    listEl.innerHTML =
      `<div class="rounded-xl border border-slate-800 bg-slate-950/60 px-3 py-3 text-sm text-slate-400">${escapeHtml(message)}</div>`;
  }

  function extractRecentRows(payload) {
    if (Array.isArray(payload)) return payload;
    if (Array.isArray(payload?.tasks)) return payload.tasks;
    if (Array.isArray(payload?.rows)) return payload.rows;
    if (Array.isArray(payload?.data)) return payload.data;
    return [];
  }

  function extractHistoryRows(payload) {
    if (Array.isArray(payload)) return payload;
    if (Array.isArray(payload?.runs)) return payload.runs;
    if (Array.isArray(payload?.rows)) return payload.rows;
    if (Array.isArray(payload?.data)) return payload.data;
    return [];
  }

  function normalizeRecentTask(row) {
    const payload = row?.payload && typeof row.payload === "object" ? row.payload : {};
    return {
      id: String(row?.task_id ?? row?.id ?? "unknown"),
      title: row?.title || payload?.title || row?.task || row?.name || "(untitled)",
      status: String(row?.status || payload?.status || "unknown"),
      kind: String(row?.kind || payload?.kind || "task"),
      updatedAt: row?.updated_at || row?.updatedAt || row?.created_at || row?.createdAt || row?.ts || null,
      agent: row?.agent || payload?.agent || payload?.target || row?.actor || row?.owner || "unassigned",
    };
  }

  function normalizeRun(row) {
    return {
      id: String(row?.run_id ?? row?.runId ?? row?.id ?? "unknown"),
      taskId: String(row?.task_id ?? row?.taskId ?? row?.title ?? "—"),
      status: String(row?.task_status ?? row?.status ?? row?.state ?? "unknown"),
      updatedAt: row?.updated_at || row?.updatedAt || row?.finished_at || row?.created_at || row?.createdAt || row?.ts || null,
      agent: row?.agent || row?.actor || row?.owner || row?.last_actor || "unassigned",
    };
  }

  function recentRowHtml(item) {
    return `
      <div class="rounded-xl border border-slate-800 bg-slate-950/60 px-3 py-3" data-phase61-recent-row="${escapeHtml(item.id)}">
        <div class="flex items-start justify-between gap-3">
          <div class="min-w-0">
            <div class="text-sm font-medium text-slate-100 truncate">${escapeHtml(item.title)}</div>
            <div class="mt-1 text-xs text-slate-400 break-all">${escapeHtml(item.id)}</div>
          </div>
          <div class="shrink-0 text-xs uppercase tracking-wide" style="color:${statusTone(item.status)}">${escapeHtml(item.status)}</div>
        </div>
        <div class="mt-2 flex flex-wrap gap-x-3 gap-y-1 text-xs text-slate-400">
          <span>kind: ${escapeHtml(item.kind)}</span>
          <span>agent: ${escapeHtml(item.agent)}</span>
          <span>updated: ${escapeHtml(formatTime(item.updatedAt))}</span>
        </div>
      </div>
    `;
  }

  function historyRowHtml(item) {
    return `
      <div class="rounded-xl border border-slate-800 bg-slate-950/60 px-3 py-3">
        <div class="flex items-start justify-between gap-3">
          <div class="min-w-0">
            <div class="text-sm font-medium text-slate-100 break-all">${escapeHtml(item.id)}</div>
            <div class="mt-1 text-xs text-slate-400 break-all">task=${escapeHtml(item.taskId)}</div>
          </div>
          <div class="shrink-0 text-xs uppercase tracking-wide" style="color:${statusTone(item.status)}">${escapeHtml(item.status)}</div>
        </div>
        <div class="mt-2 flex flex-wrap gap-x-3 gap-y-1 text-xs text-slate-400">
          <span>agent: ${escapeHtml(item.agent)}</span>
          <span>updated: ${escapeHtml(formatTime(item.updatedAt))}</span>
        </div>
      </div>
    `;
  }

  async function refreshRecent() {
    const card = findRecentCard();
    if (!card) {
      log("recent card not found");
      return;
    }

    const parts = ensureOwnedCard(card, "recent");
    parts.statusEl.textContent = "Loading recent tasks…";

    try {
      const payload = await fetchJson(RECENT_ENDPOINT);
      const rows = extractRecentRows(payload);
      log("recent payload", payload);
      log("recent rows", rows.length);

      if (!rows.length) {
        parts.statusEl.textContent = "No recent tasks returned.";
        renderEmpty(parts.listEl, "No recent tasks yet.");
        return;
      }

      parts.listEl.innerHTML = rows
        .slice(0, 12)
        .map(normalizeRecentTask)
        .map(recentRowHtml)
        .join("");

      parts.statusEl.textContent = `Loaded ${rows.length} recent task${rows.length === 1 ? "" : "s"}`;
      card.setAttribute("data-phase61-rendered", String(rows.length));
    } catch (err) {
      parts.statusEl.textContent = "Recent Tasks unavailable";
      renderEmpty(parts.listEl, `Error loading Recent Tasks: ${err.message}`);
      console.error("[phase61_recent_history_wire] refreshRecent failed", err);
    }
  }

  async function refreshHistory() {
    const card = findHistoryCard();
    if (!card) {
      log("history card not found");
      return;
    }

    const parts = ensureOwnedCard(card, "history");
    parts.statusEl.textContent = "Loading task history…";

    try {
      const payload = await fetchJson(HISTORY_ENDPOINT);
      const rows = extractHistoryRows(payload);
      log("history rows", rows.length);

      if (!rows.length) {
        parts.statusEl.textContent = "No task history returned.";
        renderEmpty(parts.listEl, "No task history yet.");
        return;
      }

      parts.listEl.innerHTML = rows
        .slice(0, 12)
        .map(normalizeRun)
        .map(historyRowHtml)
        .join("");

      parts.statusEl.textContent = `Loaded ${rows.length} run${rows.length === 1 ? "" : "s"}`;
      card.setAttribute("data-phase61-rendered", String(rows.length));
    } catch (err) {
      parts.statusEl.textContent = "Task Activity unavailable";
      renderEmpty(parts.listEl, `Error loading Task Activity: ${err.message}`);
      console.error("[phase61_recent_history_wire] refreshHistory failed", err);
    }
  }

  async function refreshAll() {
    await Promise.allSettled([refreshRecent(), refreshHistory()]);
  }

  function debounceRefresh() {
    if (window.__PHASE61_RECENT_HISTORY_DEBOUNCE) {
      window.clearTimeout(window.__PHASE61_RECENT_HISTORY_DEBOUNCE);
    }
    window.__PHASE61_RECENT_HISTORY_DEBOUNCE = window.setTimeout(refreshAll, 400);
  }

  function boot() {
    log("boot");
    refreshAll();
    window.addEventListener("mb.task.event", debounceRefresh);
    window.setInterval(refreshAll, REFRESH_MS);
    window.__PHASE61_RECENT_HISTORY_WIRE = {
      refreshAll,
      refreshRecent,
      refreshHistory,
      findRecentCard,
      findHistoryCard,
    };
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
