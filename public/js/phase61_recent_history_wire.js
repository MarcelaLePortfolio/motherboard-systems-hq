(function () {
  const RECENT_ENDPOINT = "/api/tasks?limit=12";
  const HISTORY_ENDPOINT = "/api/runs?limit=20";

  function fetchJson(url) {
    return fetch(url, {
      headers: { Accept: "application/json" },
      cache: "no-store",
    }).then(async (res) => {
      const text = await res.text();
      let data = {};
      try {
        data = text ? JSON.parse(text) : {};
      } catch (err) {
        throw new Error(`Invalid JSON from ${url}: ${err.message}`);
      }
      if (!res.ok) {
        throw new Error(data?.error || data?.message || `HTTP ${res.status}`);
      }
      return data;
    });
  }

  function ensureOwnedCard(card, key) {
    const statusId = `${key}-status`;
    const listId = `${key}-list`;

    let statusEl = card.querySelector(`#${statusId}`);
    if (!statusEl) {
      statusEl = document.createElement("div");
      statusEl.id = statusId;
      statusEl.className = "text-xs text-slate-400 mb-3";
      card.appendChild(statusEl);
    }

    let listEl = card.querySelector(`#${listId}`);
    if (!listEl) {
      listEl = document.createElement("div");
      listEl.id = listId;
      listEl.className = "space-y-2";
      card.appendChild(listEl);
    }

    return { statusEl, listEl };
  }

  function renderEmpty(listEl, message) {
    listEl.innerHTML =
      `<div class="rounded-xl border border-slate-800 bg-slate-950/60 px-3 py-3 text-sm text-slate-400">${message}</div>`;
  }

  function normalizeRecentTask(row) {
    const payload = row?.payload && typeof row.payload === "object" ? row.payload : {};
    return {
      id: String(row?.task_id ?? row?.id ?? "unknown"),
      title: row?.title || payload?.title || "(untitled)",
      status: String(row?.status || payload?.status || "unknown"),
      kind: String(row?.kind || payload?.kind || "task"),
      updated_at: row?.updated_at || row?.created_at || null,
      agent: payload?.agent || payload?.target || row?.agent || "unassigned",
    };
  }

  function recentRowHtml(item) {
    const when = item.updated_at
      ? new Date(item.updated_at).toLocaleString()
      : "unknown time";

    return `
      <div class="rounded-xl border border-slate-800 bg-slate-950/60 px-3 py-3">
        <div class="flex items-start justify-between gap-3">
          <div class="min-w-0">
            <div class="text-sm font-medium text-slate-100 truncate">${escapeHtml(item.title)}</div>
            <div class="mt-1 text-xs text-slate-400 break-all">${escapeHtml(item.id)}</div>
          </div>
          <div class="shrink-0 text-xs uppercase tracking-wide text-teal-300">${escapeHtml(item.status)}</div>
        </div>
        <div class="mt-2 flex flex-wrap gap-x-3 gap-y-1 text-xs text-slate-400">
          <span>kind: ${escapeHtml(item.kind)}</span>
          <span>agent: ${escapeHtml(item.agent)}</span>
          <span>updated: ${escapeHtml(when)}</span>
        </div>
      </div>
    `;
  }

  function normalizeRun(row) {
    return {
      id: String(row?.run_id ?? row?.id ?? "unknown"),
      status: String(row?.status ?? "unknown"),
      started_at: row?.started_at || row?.created_at || null,
      updated_at: row?.updated_at || row?.finished_at || null,
    };
  }

  function historyRowHtml(item) {
    const started = item.started_at
      ? new Date(item.started_at).toLocaleString()
      : "unknown";
    const updated = item.updated_at
      ? new Date(item.updated_at).toLocaleString()
      : "unknown";

    return `
      <div class="rounded-xl border border-slate-800 bg-slate-950/60 px-3 py-3">
        <div class="flex items-start justify-between gap-3">
          <div class="min-w-0">
            <div class="text-sm font-medium text-slate-100 break-all">${escapeHtml(item.id)}</div>
          </div>
          <div class="shrink-0 text-xs uppercase tracking-wide text-cyan-300">${escapeHtml(item.status)}</div>
        </div>
        <div class="mt-2 flex flex-wrap gap-x-3 gap-y-1 text-xs text-slate-400">
          <span>started: ${escapeHtml(started)}</span>
          <span>updated: ${escapeHtml(updated)}</span>
        </div>
      </div>
    `;
  }

  function escapeHtml(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
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

  async function refreshRecent() {
    const card = document.getElementById("recent-tasks-card");
    if (!card) return;

    const { statusEl, listEl } = ensureOwnedCard(card, "recent");
    statusEl.textContent = "Loading recent tasks…";

    try {
      const payload = await fetchJson(RECENT_ENDPOINT);
      const rows = extractRecentRows(payload);

      if (!rows.length) {
        statusEl.textContent = "No recent tasks returned.";
        renderEmpty(listEl, "No recent tasks yet.");
        return;
      }

      const html = rows
        .slice(0, 12)
        .map(normalizeRecentTask)
        .map(recentRowHtml)
        .join("");

      listEl.innerHTML = html;
      statusEl.textContent = `Loaded ${rows.length} recent task${rows.length === 1 ? "" : "s"}`;
    } catch (err) {
      statusEl.textContent = "Recent Tasks unavailable";
      renderEmpty(listEl, `Error loading Recent Tasks: ${err.message}`);
      console.error("[phase61_recent_history_wire] refreshRecent failed", err);
    }
  }

  async function refreshHistory() {
    const card = document.getElementById("task-activity-card");
    if (!card) return;

    const { statusEl, listEl } = ensureOwnedCard(card, "history");
    statusEl.textContent = "Loading task history…";

    try {
      const payload = await fetchJson(HISTORY_ENDPOINT);
      const rows = extractHistoryRows(payload);

      if (!rows.length) {
        statusEl.textContent = "No task history returned.";
        renderEmpty(listEl, "No task history yet.");
        return;
      }

      const html = rows
        .slice(0, 12)
        .map(normalizeRun)
        .map(historyRowHtml)
        .join("");

      listEl.innerHTML = html;
      statusEl.textContent = `Loaded ${rows.length} run${rows.length === 1 ? "" : "s"}`;
    } catch (err) {
      statusEl.textContent = "Task Activity unavailable";
      renderEmpty(listEl, `Error loading Task Activity: ${err.message}`);
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
    refreshAll();
    window.addEventListener("mb.task.event", debounceRefresh);
    window.setInterval(refreshAll, 10000);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
