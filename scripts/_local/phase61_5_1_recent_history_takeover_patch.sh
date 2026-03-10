#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

TARGET_HTML="public/dashboard.html"
TARGET_JS="public/js/phase61_recent_history_wire.js"

scripts/verify-dashboard-layout-contract.sh "$TARGET_HTML"

cp "$TARGET_JS" "${TARGET_JS}.bak.phase61_5_1"

cat > "$TARGET_JS" << 'JS'
(() => {
  const RECENT_ENDPOINT = "/api/tasks?limit=12";
  const HISTORY_ENDPOINT = "/api/runs?limit=20";
  const REFRESH_MS = 15000;

  function fmtTime(value) {
    if (value == null || value === "") return "—";
    const d = new Date(value);
    if (!Number.isNaN(d.getTime())) return d.toLocaleString();
    if (typeof value === "number") {
      const n = new Date(value);
      if (!Number.isNaN(n.getTime())) return n.toLocaleString();
    }
    return String(value);
  }

  function esc(value) {
    return String(value ?? "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function statusTone(status) {
    const s = String(status ?? "").toLowerCase();
    if (/fail|error|cancel|timeout/.test(s)) return "rgba(240,90,90,0.95)";
    if (/complete|done|success|ok/.test(s)) return "rgba(80,200,120,0.95)";
    if (/queue|pending|wait|retry|hold/.test(s)) return "rgba(250,204,21,0.95)";
    if (/run|start|active|lease|progress|created/.test(s)) return "rgba(96,165,250,0.95)";
    return "rgba(255,255,255,0.18)";
  }

  function renderEmpty(listEl, text) {
    listEl.innerHTML = `<div style="font-size:12px;opacity:.72;padding:8px 2px;">${esc(text)}</div>`;
  }

  function renderRows(listEl, rows) {
    listEl.innerHTML = rows.join("");
  }

  function normalizeRecentTask(row) {
    return {
      title: row.title ?? row.task ?? row.name ?? row.task_id ?? "Untitled task",
      taskId: row.task_id ?? row.id ?? row.taskId ?? "—",
      status: row.status ?? row.state ?? "unknown",
      agent: row.agent ?? row.actor ?? row.owner ?? "—",
      updatedAt: row.updated_at ?? row.updatedAt ?? row.ts ?? row.created_at ?? row.createdAt ?? null,
    };
  }

  function normalizeRun(row) {
    return {
      runId: row.run_id ?? row.runId ?? row.id ?? "—",
      taskId: row.task_id ?? row.taskId ?? row.title ?? "—",
      status: row.task_status ?? row.status ?? row.state ?? "unknown",
      agent: row.agent ?? row.actor ?? row.owner ?? row.last_actor ?? "—",
      updatedAt: row.updated_at ?? row.updatedAt ?? row.last_event_ts ?? row.ts ?? row.created_at ?? row.createdAt ?? null,
    };
  }

  function recentRowHtml(item) {
    return `
      <div style="position:relative;display:grid;grid-template-columns:minmax(0,1fr) auto;gap:10px;padding:10px 12px 10px 14px;border:1px solid rgba(255,255,255,0.08);border-radius:12px;background:rgba(255,255,255,0.03);">
        <span aria-hidden="true" style="position:absolute;left:0;top:10px;bottom:10px;width:3px;border-radius:999px;background:${statusTone(item.status)};"></span>
        <div style="min-width:0;">
          <div style="font-size:13px;font-weight:600;color:rgba(255,255,255,0.94);word-break:break-word;">${esc(item.title)}</div>
          <div style="margin-top:4px;font-size:12px;color:rgba(255,255,255,0.7);word-break:break-word;">task=${esc(item.taskId)} • agent=${esc(item.agent)}</div>
        </div>
        <div style="text-align:right;">
          <div style="font-size:12px;font-weight:600;color:rgba(255,255,255,0.88);">${esc(item.status)}</div>
          <div style="margin-top:4px;font-size:11px;color:rgba(255,255,255,0.6);white-space:nowrap;">${esc(fmtTime(item.updatedAt))}</div>
        </div>
      </div>
    `;
  }

  function historyRowHtml(item) {
    return `
      <div style="position:relative;display:grid;grid-template-columns:minmax(110px,130px) minmax(0,1fr) auto;gap:10px;padding:10px 12px 10px 14px;border:1px solid rgba(255,255,255,0.08);border-radius:12px;background:rgba(255,255,255,0.03);">
        <span aria-hidden="true" style="position:absolute;left:0;top:10px;bottom:10px;width:3px;border-radius:999px;background:${statusTone(item.status)};"></span>
        <div style="font-size:11px;color:rgba(255,255,255,0.64);font-variant-numeric:tabular-nums;white-space:nowrap;">${esc(item.runId)}</div>
        <div style="min-width:0;">
          <div style="font-size:12px;font-weight:600;color:rgba(255,255,255,0.9);word-break:break-word;">task=${esc(item.taskId)}</div>
          <div style="margin-top:4px;font-size:12px;color:rgba(255,255,255,0.7);word-break:break-word;">agent=${esc(item.agent)} • status=${esc(item.status)}</div>
        </div>
        <div style="font-size:11px;color:rgba(255,255,255,0.6);white-space:nowrap;">${esc(fmtTime(item.updatedAt))}</div>
      </div>
    `;
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

  function ensureOwnedCard(target, key) {
    let shell = target.querySelector(`:scope > [data-phase61-shell="${key}"]`);
    if (shell) {
      return {
        shell,
        statusEl: shell.querySelector(`[data-phase61-status="${key}"]`),
        listEl: shell.querySelector(`[data-phase61-list="${key}"]`)
      };
    }

    target.innerHTML = "";
    target.removeAttribute("data-empty");
    target.removeAttribute("data-panel");
    target.removeAttribute("data-probe");
    target.querySelectorAll("*").forEach((node) => {
      node.removeAttribute?.("data-empty");
      node.removeAttribute?.("data-probe");
    });

    const owned = buildOwnedShell(key);
    target.appendChild(owned.shell);
    return owned;
  }

  function ensureHistoryCard(panel) {
    let card = panel.querySelector(':scope > [data-phase61-history-card="true"]');
    if (card) return card;

    panel.innerHTML = "";
    card = document.createElement("section");
    card.className = "obs-surface";
    card.setAttribute("data-phase61-history-card", "true");
    panel.appendChild(card);
    return card;
  }

  async function fetchJson(url) {
    const res = await fetch(url, { headers: { Accept: "application/json" } });
    if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);
    return res.json();
  }

  async function refreshRecent() {
    const card = document.getElementById("recent-tasks-card");
    if (!card) return;

    const { statusEl, listEl } = ensureOwnedCard(card, "recent");
    statusEl.textContent = `Loading ${RECENT_ENDPOINT} …`;

    try {
      const payload = await fetchJson(RECENT_ENDPOINT);
      const rows = Array.isArray(payload)
        ? payload
        : Array.isArray(payload.rows)
        ? payload.rows
        : Array.isArray(payload.tasks)
        ? payload.tasks
        : [];

      if (!rows.length) {
        statusEl.textContent = "No recent tasks returned";
        renderEmpty(listEl, "No recent tasks yet.");
        return;
      }

      const html = rows.slice(0, 12).map(normalizeRecentTask).map(recentRowHtml);
      statusEl.textContent = `Loaded ${rows.length} recent task${rows.length === 1 ? "" : "s"}`;
      renderRows(listEl, html);
    } catch (err) {
      statusEl.textContent = "Recent Tasks unavailable";
      renderEmpty(listEl, `Error loading Recent Tasks: ${err.message}`);
    }
  }

  async function refreshHistory() {
    const panel = document.getElementById("obs-panel-activity");
    if (!panel) return;

    const card = ensureHistoryCard(panel);
    const { statusEl, listEl } = ensureOwnedCard(card, "history");
    statusEl.textContent = `Loading ${HISTORY_ENDPOINT} …`;

    try {
      const payload = await fetchJson(HISTORY_ENDPOINT);
      const rows = Array.isArray(payload)
        ? payload
        : Array.isArray(payload.rows)
        ? payload.rows
        : Array.isArray(payload.runs)
        ? payload.runs
        : [];

      if (!rows.length) {
        statusEl.textContent = "No task history returned";
        renderEmpty(listEl, "No task history yet.");
        return;
      }

      const html = rows.slice(0, 20).map(normalizeRun).map(historyRowHtml);
      statusEl.textContent = `Loaded ${rows.length} history row${rows.length === 1 ? "" : "s"}`;
      renderRows(listEl, html);
    } catch (err) {
      statusEl.textContent = "Task History unavailable";
      renderEmpty(listEl, `Error loading Task History: ${err.message}`);
    }
  }

  async function refreshAll() {
    await Promise.allSettled([refreshRecent(), refreshHistory()]);
  }

  function boot() {
    refreshAll();
    setInterval(refreshAll, REFRESH_MS);

    window.addEventListener("mb.task.event", () => {
      window.clearTimeout(window.__PHASE61_RECENT_HISTORY_DEBOUNCE);
      window.__PHASE61_RECENT_HISTORY_DEBOUNCE = window.setTimeout(refreshAll, 400);
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
JS

scripts/verify-dashboard-layout-contract.sh "$TARGET_HTML"
