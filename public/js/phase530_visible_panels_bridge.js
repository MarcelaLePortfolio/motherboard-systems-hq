(function () {
  if (window.__PHASE530_VISIBLE_PANELS_BRIDGE__) return;
  window.__PHASE530_VISIBLE_PANELS_BRIDGE__ = true;

  const POLL_MS = 10000;

  function esc(value) {
    return String(value ?? "")
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;");
  }

  async function getJson(url) {
    const res = await fetch(url, { cache: "no-store" });
    const data = await res.json();
    if (!res.ok) throw new Error(data?.error || "Request failed");
    return data;
  }

  function renderAgents(rows) {
    const root = document.getElementById("agent-status-container");
    if (!root) return;

    root.innerHTML = `
      <h2 class="text-xl font-semibold border-b border-gray-700 pb-2 mb-4">Agent Pool</h2>
      <div style="display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:0.9rem;width:100%;">
        ${(rows || []).map((agent) => `
          <div style="min-height:5.4rem;border:1px solid rgba(75,85,99,.9);background:rgba(17,24,39,.72);border-radius:1rem;padding:1rem;display:flex;flex-direction:column;justify-content:space-between;">
            <div>
              <div style="font-weight:800;color:#e5e7eb;font-size:1rem;line-height:1.2;">${esc(agent.agent_name)}</div>
              <div style="font-size:.82rem;color:#94a3b8;margin-top:.35rem;">${esc(agent.status)}</div>
            </div>
            <div style="font-size:.84rem;color:#cbd5e1;margin-top:.65rem;">${esc(agent.current_task || "Available")}</div>
          </div>
        `).join("")}
      </div>
    `;
  }


  function taskRows(tasks) {

    if (!tasks || !tasks.length) {

      return `<div style="color:#94a3b8;font-size:.8rem;">No recent tasks yet.</div>`;

    }

    return tasks.map((t) => {

      const title = esc(t.title || t.task_id || t.id || "Untitled task");

      const status = esc(t.status || "unknown");

      const taskId = esc(t.task_id || t.id || "");

      const updated = esc(t.updated_at || "");

      const outcome = esc(t.outcome_preview || "");

      const explanation = esc(t.explanation_preview || "");

      const guidance = t.guidance || {};

      const trace = guidance.communicationResult && guidance.communicationResult.systemTrace

        ? guidance.communicationResult.systemTrace.content

        : null;

      const traceJson = trace ? esc(JSON.stringify(trace, null, 2)) : "";

      return `

        <article data-phase716-contained-task="true" data-phase717-execution-card="true" style="display:block;width:100%;min-width:0;max-width:100%;box-sizing:border-box;border:1px solid rgba(148,163,184,.22);border-radius:12px;padding:10px;margin:0 0 10px 0;background:rgba(15,23,42,.72);overflow:hidden;">

          <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:8px;min-width:0;">

            <div style="font-weight:600;color:#e5e7eb;overflow-wrap:anywhere;word-break:break-word;min-width:0;">${title}</div>

            <div style="flex:0 0 auto;color:#93c5fd;border:1px solid rgba(147,197,253,.35);border-radius:999px;padding:2px 7px;font-size:10px;line-height:1.4;background:rgba(30,64,175,.18);">lifecycle</div>

          </div>

          <div style="margin-top:4px;color:#94a3b8;font-size:12px;overflow-wrap:anywhere;word-break:break-word;">status=${status} · id=${taskId}</div>

          ${updated ? `<div style="margin-top:4px;color:#64748b;font-size:11px;overflow-wrap:anywhere;">updated=${updated}</div>` : ""}

          <div style="margin-top:8px;border:1px solid rgba(71,85,105,.55);border-radius:10px;padding:7px;background:rgba(2,6,23,.22);">

            <div style="color:#cbd5e1;font-size:11px;font-weight:700;margin-bottom:5px;">Operator actions</div>

            <div style="display:flex;flex-wrap:wrap;gap:6px;">

              <button type="button" data-phase717-requeue="true" data-task-id="${taskId}" data-task-title="${title}" title="Explicit operator action: requeue this task" style="cursor:pointer;border:1px solid rgba(148,163,184,.35);background:rgba(15,23,42,.8);color:#cbd5e1;border-radius:8px;padding:5px 8px;font-size:11px;">Requeue</button>

              <button type="button" data-phase717-retry-differently="true" data-task-id="${taskId}" data-task-title="${title}" title="Explicit operator action: retry this task differently" style="cursor:pointer;border:1px solid rgba(96,165,250,.45);background:rgba(30,41,59,.92);color:#dbeafe;border-radius:8px;padding:5px 8px;font-size:11px;">Retry differently</button>

            </div>

          </div>

          ${outcome ? `<div style="margin-top:8px;color:#d1d5db;font-size:12px;overflow-wrap:anywhere;word-break:break-word;">${outcome}</div>` : ""}

          ${explanation ? `<details style="margin-top:8px;display:block;max-width:100%;overflow:hidden;"><summary style="cursor:pointer;color:#93c5fd;font-size:12px;">details</summary><div style="margin-top:6px;color:#cbd5e1;font-size:12px;white-space:pre-wrap;overflow-wrap:anywhere;word-break:break-word;">${explanation}</div></details>` : ""}

          ${traceJson ? `<details style="margin-top:8px;display:block;max-width:100%;overflow:hidden;"><summary style="cursor:pointer;color:#fbbf24;font-size:12px;">advanced JSON</summary><pre style="display:block;box-sizing:border-box;width:100%;max-width:100%;max-height:220px;overflow:auto;margin-top:6px;padding:8px;border-radius:8px;background:#020617;color:#e5e7eb;font-size:11px;line-height:1.35;white-space:pre-wrap;overflow-wrap:anywhere;word-break:break-word;">${traceJson}</pre></details>` : ""}

        </article>

      `;

    }).join("");

  }


  function renderRecent(tasks) {
    const recentTasks = document.getElementById("recentTasks");
    const recentLogs = document.getElementById("recentLogs");
    const recentCard = document.getElementById("recent-tasks-card");

    if (recentCard) {
      recentCard.style.display = "grid";
      recentCard.style.gridTemplateRows = "1fr 1fr";
      recentCard.style.gap = "1rem";
      recentCard.style.minHeight = "0";
      recentCard.style.height = "100%";
    }

    [recentTasks, recentLogs].forEach((el) => {
      if (!el) return;
      el.style.minHeight = "0";
      el.style.height = "100%";
      el.style.overflow = "auto";
      el.style.display = "block";
    });

    if (recentTasks) recentTasks.innerHTML = taskRows(tasks);

    if (recentLogs) {
      recentLogs.innerHTML = (tasks && tasks.length)
        ? tasks.map((task) => `
            <div style="border-bottom:1px solid rgba(51,65,85,.55);padding:.5rem 0;color:#cbd5e1;font-size:.8rem;">
              ${esc(task.updated_at || task.created_at || "time unavailable")} · ${esc(task.status || "unknown")} · ${esc(task.title || task.task_id || "Untitled task")}
            </div>
          `).join("")
        : `<div style="color:#94a3b8;font-size:.8rem;">No task history yet.</div>`;
    }
  }

  function renderActivity(rows) {
    const canvas = document.getElementById("task-activity-graph");
    if (!canvas || !window.Chart) return;

    const card = document.getElementById("task-activity-card");
    const shell = canvas.parentElement;

    if (card) {
      card.style.height = "100%";
      card.style.minHeight = "0";
      card.style.display = "flex";
      card.style.flexDirection = "column";
    }

    if (shell) {
      shell.style.flex = "1 1 auto";
      shell.style.height = "100%";
      shell.style.minHeight = "0";
      shell.style.display = "flex";
      shell.style.padding = "0.75rem";
    }

    canvas.style.flex = "1 1 auto";
    canvas.style.width = "100%";
    canvas.style.height = "100%";
    canvas.style.minHeight = "0";

    const labels = (rows || []).map((row) => {
      const d = new Date(row.timestamp || Date.now());
      return Number.isNaN(d.getTime()) ? "now" : d.toLocaleTimeString();
    });

    const created = (rows || []).map((row) => Number(row.created_count || 0));
    const completed = (rows || []).map((row) => Number(row.completed_count || 0));
    const failed = (rows || []).map((row) => Number(row.failed_count || 0));

    if (window.__PHASE530_ACTIVITY_CHART__) {
      window.__PHASE530_ACTIVITY_CHART__.data.labels = labels;
      window.__PHASE530_ACTIVITY_CHART__.data.datasets[0].data = created;
      window.__PHASE530_ACTIVITY_CHART__.data.datasets[1].data = completed;
      window.__PHASE530_ACTIVITY_CHART__.data.datasets[2].data = failed;
      window.__PHASE530_ACTIVITY_CHART__.resize();
      window.__PHASE530_ACTIVITY_CHART__.update();
      return;
    }

    window.__PHASE530_ACTIVITY_CHART__ = new Chart(canvas, {
      type: "line",
      data: {
        labels,
        datasets: [
          { label: "Created", data: created },
          { label: "Completed", data: completed },
          { label: "Failed", data: failed }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        resizeDelay: 0,
        layout: {
          padding: 8
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              precision: 0
            }
          }
        }
      }
    });
  }

  function phase717EscapeModalText(value) {

    return String(value ?? "")

      .replace(/&/g, "&amp;")

      .replace(/</g, "&lt;")

      .replace(/>/g, "&gt;")

      .replace(/"/g, "&quot;")

      .replace(/'/g, "&#39;");

  }

  function phase717RetryModal(options) {

    return new Promise((resolve) => {

      const rootId = "phase717-retry-modal-root";

      let root = document.getElementById(rootId);

      if (!root) {

        root = document.createElement("div");

        root.id = rootId;

        document.body.appendChild(root);

      }

      const title = phase717EscapeModalText(options.title || "Confirm action");

      const message = phase717EscapeModalText(options.message || "");

      const confirmLabel = phase717EscapeModalText(options.confirmLabel || "Confirm");

      const cancelLabel = options.cancelLabel === null ? null : phase717EscapeModalText(options.cancelLabel || "Cancel");

      const tone = options.tone === "error" ? "#fecaca" : options.tone === "success" ? "#bbf7d0" : "#dbeafe";

      const border = options.tone === "error" ? "rgba(248,113,113,.45)" : options.tone === "success" ? "rgba(74,222,128,.42)" : "rgba(96,165,250,.45)";

      root.innerHTML = `

        <div data-phase717-modal-overlay="true" style="position:fixed;inset:0;z-index:9999;display:flex;align-items:center;justify-content:center;padding:18px;background:rgba(2,6,23,.72);backdrop-filter:blur(6px);">

          <section role="dialog" aria-modal="true" aria-labelledby="phase717-retry-modal-title" style="width:min(520px,calc(100vw - 28px));border:1px solid ${border};border-radius:16px;background:rgba(15,23,42,.98);box-shadow:0 24px 80px rgba(0,0,0,.45);padding:16px;color:#e5e7eb;">

            <div id="phase717-retry-modal-title" style="font-size:14px;font-weight:800;color:${tone};letter-spacing:.01em;">${title}</div>

            <div style="margin-top:8px;color:#cbd5e1;font-size:12px;line-height:1.5;white-space:pre-wrap;overflow-wrap:anywhere;">${message}</div>

            <div style="display:flex;justify-content:flex-end;gap:8px;margin-top:14px;">

              ${cancelLabel ? `<button type="button" data-phase717-modal-cancel="true" style="cursor:pointer;border:1px solid rgba(148,163,184,.35);background:rgba(15,23,42,.85);color:#cbd5e1;border-radius:10px;padding:7px 10px;font-size:12px;">${cancelLabel}</button>` : ""}

              <button type="button" data-phase717-modal-confirm="true" style="cursor:pointer;border:1px solid ${border};background:rgba(30,41,59,.95);color:${tone};border-radius:10px;padding:7px 10px;font-size:12px;font-weight:700;">${confirmLabel}</button>

            </div>

          </section>

        </div>

      `;

      const close = (value) => {

        root.innerHTML = "";

        resolve(value);

      };

      const confirm = root.querySelector("[data-phase717-modal-confirm]");

      const cancel = root.querySelector("[data-phase717-modal-cancel]");

      const overlay = root.querySelector("[data-phase717-modal-overlay]");

      if (confirm) confirm.focus();

      if (confirm) confirm.addEventListener("click", () => close(true), { once: true });

      if (cancel) cancel.addEventListener("click", () => close(false), { once: true });

      if (overlay) {

        overlay.addEventListener("click", (event) => {

          if (event.target === overlay) close(false);

        }, { once: true });

      }

    });

  }

  async function phase717RetryTask(taskId, mode, button, taskTitle) {

    if (!taskId) {

      await phase717RetryModal({ title: "Retry not submitted", message: "Missing task id; retry was not submitted.", confirmLabel: "Close", cancelLabel: null, tone: "error" });

      return;

    }

    const label = mode === "fresh-context" ? "retry differently" : "requeue";

    const displayName = taskTitle && taskTitle.trim() ? taskTitle.trim() : taskId;

    const modalTitle = mode === "fresh-context" ? "Confirm retry action" : "Confirm requeue";

    const detailMessage = mode === "fresh-context"

      ? "This will create a new queued attempt using a fresh-context execution strategy. Please confirm this action to continue."

      : "This will create a new queued attempt for this task. Please confirm this action to continue.";

    const ok = await phase717RetryModal({ title: modalTitle, message: `Submit ${label} for “${displayName}”?\n\n${detailMessage}`, confirmLabel: "Submit", cancelLabel: "Cancel" });

    if (!ok) return;

    const originalText = button ? button.textContent : "";

    if (button) {

      button.disabled = true;

      button.textContent = "Submitting...";

    }

    try {

      const res = await fetch("/api/delegate-task", {

        method: "POST",

        headers: { "Content-Type": "application/json" },

        body: JSON.stringify({

          kind: "retry",

          strategy: mode === "fresh-context" ? "fresh-context" : "standard",

          title: `${label} ${taskId}`,

          meta: { retry_of_task_id: taskId },

          source: "operator-guidance-ui"

        })

      });

      const data = await res.json();

      if (!res.ok || data.ok === false) {

        throw new Error(data.error || data.details || `HTTP ${res.status}`);

      }

      await phase717RetryModal({ title: "Retry submitted", message: `Retry submitted: ${data.task_id || data.id || "created"}`, confirmLabel: "Close", cancelLabel: null, tone: "success" });

      await refresh();

    } catch (err) {

      await phase717RetryModal({ title: "Retry failed", message: `${err && err.message ? err.message : String(err)}`, confirmLabel: "Close", cancelLabel: null, tone: "error" });

    } finally {

      if (button) {

        button.disabled = false;

        button.textContent = originalText;

      }

    }

  }

  document.addEventListener("click", function(event) {

    const requeue = event.target.closest("[data-phase717-requeue]");

    const retryDifferently = event.target.closest("[data-phase717-retry-differently]");

    if (!requeue && !retryDifferently) return;

    const button = requeue || retryDifferently;

    const taskId = button.getAttribute("data-task-id");

    const taskTitle = button.getAttribute("data-task-title");

    const mode = retryDifferently ? "fresh-context" : "standard";

    phase717RetryTask(taskId, mode, button, taskTitle);

  });

  async function refresh() {
    try {
      const agents = await getJson("/api/agents");
      renderAgents(Array.isArray(agents) ? agents : []);
    } catch (e) {
      console.warn("[phase530] agents render failed", e);
    }

    try {
      const data = await getJson("/api/tasks?limit=12");
      renderRecent(data.tasks || []);
    } catch (e) {
      console.warn("[phase530] recent tasks render failed", e);
    }

    try {
      const activity = await getJson("/api/activity-graph");
      renderActivity(Array.isArray(activity) ? activity : []);
    } catch (e) {
      console.warn("[phase530] activity graph render failed", e);
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", refresh, { once: true });
  } else {
    refresh();
  }

  setInterval(refresh, POLL_MS);
})();
