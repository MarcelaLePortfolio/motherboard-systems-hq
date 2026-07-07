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

      const phase718TaskTitleByKey = new Map();

      tasks.forEach((taskForTitle) => {

        const readableTitle = String(taskForTitle.title || taskForTitle.task_title || taskForTitle.task_id || taskForTitle.id || "");

        const keys = [

          taskForTitle.task_id,

          taskForTitle.id,

          taskForTitle.uuid,

          taskForTitle.execution_id

        ].filter(Boolean).map(String);

        keys.forEach((key) => {

          if (key && readableTitle) {

            phase718TaskTitleByKey.set(key, readableTitle);

          }

        });

      });

    return tasks.map((t) => {

      const rawTitle = String(t.title || t.task_id || t.id || "Untitled task");

      const retryTitleMatch = rawTitle.match(/^(retry differently|requeue)\s+(t_[a-f0-9-]+)$/i);

      const phase718ResolveBaseTitle = (candidateTitle, depth = 0) => {

        const candidate = String(candidateTitle || "");

        if (!candidate || depth > 5) return candidate;

        const nestedRetryMatch = candidate.match(/^(retry differently|requeue)\s+(t_[a-f0-9-]+)$/i);

        if (!nestedRetryMatch) return candidate;

        const nestedTarget = nestedRetryMatch[2];

        return phase718TaskTitleByKey.has(nestedTarget)

          ? phase718ResolveBaseTitle(phase718TaskTitleByKey.get(nestedTarget), depth + 1)

          : nestedTarget;

      };

      const operatorAction = retryTitleMatch

        ? (retryTitleMatch[1].toLowerCase() === "requeue" ? "Requeue" : "Retry differently")

        : "";

      const operatorTarget = retryTitleMatch ? retryTitleMatch[2] : "";

      const resolvedTargetTitleRaw = operatorTarget && phase718TaskTitleByKey.has(operatorTarget)

        ? phase718ResolveBaseTitle(phase718TaskTitleByKey.get(operatorTarget))

        : operatorTarget;

      const operatorTitle = operatorAction && resolvedTargetTitleRaw

        ? `${operatorAction}: ${resolvedTargetTitleRaw}`

        : (operatorAction || phase718ResolveBaseTitle(rawTitle));

      const title = esc(operatorTitle);

      const targetTitle = esc(operatorTarget);

      const status = esc(t.status || "unknown");

      const taskId = esc(t.task_id || t.id || "");

      const updated = esc(t.updated_at || "");

      const outcome = esc(t.outcome_preview || "");

      const explanation = esc(t.explanation_preview || "");
      const artifactRaw = t.artifact || (Array.isArray(t.artifacts) ? t.artifacts[0] : null) || null;
      const artifactName = artifactRaw ? esc(artifactRaw.filename || artifactRaw.path || "artifact") : "";
      const artifactType = artifactRaw ? esc(artifactRaw.type || "artifact") : "";
      const artifactSize = artifactRaw && artifactRaw.size_bytes ? esc(String(artifactRaw.size_bytes) + " bytes") : "";
      const artifactPath = artifactRaw ? esc(artifactRaw.path || "") : "";

      const triageStatusRaw = String(t.status || "").toLowerCase();

      const triageLabel = triageStatusRaw === "completed" ? "triage: completed" : "";

      const executionStrategyRaw = t.strategy || t.execution_strategy || t.execution_mode || t.executionMode || "";

      const executionStrategy = esc(String(executionStrategyRaw || ""));

      const retryOfRaw = t.retry_of_task_id || (t.meta && t.meta.retry_of_task_id) || (t.execution_meta && t.execution_meta.retry_of_task_id) || "";

      const retryOf = esc(String(retryOfRaw || ""));

      const guidance = t.guidance || {};

      const trace = guidance.communicationResult && guidance.communicationResult.systemTrace

        ? guidance.communicationResult.systemTrace.content

        : null;

      const traceJson = trace ? esc(JSON.stringify(trace, null, 2)) : "";

      const logContent = esc([

        `task_id=${taskId}`,

        `status=${status}`,

        updated ? `updated=${updated}` : "",

        outcome ? `outcome=${outcome}` : "",

        ""

      ].filter(Boolean).join("\n"));

      return `

        <article data-phase716-contained-task="true" data-phase717-execution-card="true" style="display:block;width:100%;min-width:0;max-width:100%;box-sizing:border-box;border:1px solid rgba(148,163,184,.24);border-radius:14px;padding:12px;margin:0 0 12px 0;background:rgba(15,23,42,.74);overflow:hidden;">

          <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:8px;min-width:0;">

            <div style="font-weight:600;color:#e5e7eb;overflow-wrap:anywhere;word-break:break-word;min-width:0;">${title}</div>

            ${artifactRaw ? `<button type="button" data-phase719-preview-artifact="true" data-task-id="${taskId}" data-task-title="${title}" data-artifact-name="${artifactName}" data-artifact-type="${artifactType}" data-artifact-size="${artifactSize}" data-artifact-path="${artifactPath}" data-artifact-outcome="${outcome}" data-artifact-explanation="${explanation}" title="Preview completed artifact" style="flex:0 0 auto;cursor:pointer;color:#93c5fd;border:1px solid rgba(147,197,253,.35);border-radius:999px;padding:2px 7px;font-size:10px;line-height:1.4;background:rgba(30,64,175,.18);">Preview</button>` : ""}

            ${executionStrategy ? `<div style="flex:0 0 auto;color:#c4b5fd;border:1px solid rgba(196,181,253,.35);border-radius:999px;padding:2px 7px;font-size:10px;line-height:1.4;background:rgba(88,28,135,.18);">strategy: ${executionStrategy}</div>` : ""}

            ${retryOf ? `<div style="flex:0 0 auto;color:#fcd34d;border:1px solid rgba(252,211,77,.35);border-radius:999px;padding:2px 7px;font-size:10px;line-height:1.4;background:rgba(120,53,15,.18);">retry of: ${retryOf}</div>` : ""}

            ${triageLabel ? `<div style="flex:0 0 auto;color:#86efac;border:1px solid rgba(134,239,172,.35);border-radius:999px;padding:2px 7px;font-size:10px;line-height:1.4;background:rgba(22,101,52,.18);">${triageLabel}</div>` : ""}

          </div>
            ${""}

          ${""}

          ${""}

          <div style="margin-top:10px;border:1px solid rgba(71,85,105,.55);border-radius:12px;padding:9px;background:rgba(2,6,23,.24);">

              ${artifactRaw ? `<div style="margin-bottom:8px;color:#86efac;font-size:11px;line-height:1.5;overflow-wrap:anywhere;border:1px solid rgba(134,239,172,.28);border-radius:10px;padding:7px;background:rgba(20,83,45,.14);">Artifact: ${artifactName}${artifactType ? ` · ${artifactType}` : ""}${artifactSize ? ` · ${artifactSize}` : ""}</div>` : ""}
            <div style="color:#cbd5e1;font-size:11px;font-weight:700;margin-bottom:7px;letter-spacing:.02em;">Operator actions</div>

            <div style="display:flex;flex-wrap:wrap;gap:7px;align-items:center;">

              <button type="button" data-phase717-requeue="true" data-task-id="${taskId}" data-task-title="${title}" title="Explicit operator action: requeue this task" style="cursor:pointer;border:1px solid rgba(148,163,184,.35);background:rgba(15,23,42,.8);color:#cbd5e1;border-radius:8px;padding:5px 8px;font-size:11px;">Requeue</button>

              <button type="button" data-phase717-retry-differently="true" data-task-id="${taskId}" data-task-title="${title}" title="Explicit operator action: retry this task differently" style="cursor:pointer;border:1px solid rgba(96,165,250,.45);background:rgba(30,41,59,.92);color:#dbeafe;border-radius:8px;padding:5px 8px;font-size:11px;">Retry differently</button>

            </div>

          </div>

          ${outcome ? "" : ""}

          ${explanation ? `<button type="button" data-phase717-inspect-details="true" data-phase717-inspect-title="${title} — Details" data-phase717-inspect-content="${explanation}" style="margin-top:10px;cursor:pointer;border:1px solid rgba(147,197,253,.35);background:rgba(30,64,175,.14);color:#93c5fd;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect details</button>` : ""}

          ${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect trace</button>` : ""}

          ${logContent ? `<button type="button" data-phase717-inspect-logs="true" data-phase717-inspect-title="${title} — Logs" data-phase717-inspect-content="${logContent}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(45,212,191,.38);background:rgba(20,83,45,.14);color:#5eead4;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect logs</button>` : ""}

        </article>

      `;

    }).join("");

  }


  function renderRecent(tasks) {
    const recentTasks = document.getElementById("recentTasks");
    const recentLogs = document.getElementById("recentLogs");
    const recentCard = document.getElementById("recent-tasks-card");

    if (recentCard) {
      recentCard.style.display = "block";
      recentCard.style.minHeight = "0";
      recentCard.style.height = "100%";
    }

    if (recentTasks) {
      recentTasks.style.minHeight = "0";
      recentTasks.style.height = "100%";
      recentTasks.style.overflow = "auto";
      recentTasks.style.display = "block";
    }

    if (recentLogs) {
      recentLogs.style.display = "none";
    }

    if (recentTasks) recentTasks.innerHTML = taskRows(tasks);

    if (recentLogs) recentLogs.innerHTML = "";
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



  function phase717InspectionModal(options) {

    return new Promise((resolve) => {

      const rootId = "phase717-inspection-modal-root";

      let root = document.getElementById(rootId);

      if (!root) {

        root = document.createElement("div");

        root.id = rootId;

        document.body.appendChild(root);

      }

      const title = String(options.title || "Read-only inspection");

      const content = String(options.content || "No inspection content available.");

      root.innerHTML = `

        <div data-phase717-inspection-overlay="true" style="position:fixed;inset:0;z-index:9998;display:flex;align-items:center;justify-content:center;padding:18px;background:rgba(2,6,23,.72);backdrop-filter:blur(6px);">

          <section role="dialog" aria-modal="true" aria-labelledby="phase717-inspection-modal-title" style="width:min(760px,calc(100vw - 28px));max-height:min(760px,calc(100vh - 36px));display:flex;flex-direction:column;border:1px solid rgba(148,163,184,.36);border-radius:16px;background:rgba(15,23,42,.98);box-shadow:0 24px 80px rgba(0,0,0,.45);padding:16px;color:#e5e7eb;">

            <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:10px;">

              <div>

                <div id="phase717-inspection-modal-title" style="font-size:14px;font-weight:800;color:#dbeafe;letter-spacing:.01em;"></div>

                <div style="margin-top:4px;color:#94a3b8;font-size:11px;">Read-only inspection. No execution, retry, or mutation is triggered from this view.</div>

              </div>

              <button type="button" data-phase717-inspection-close="true" style="cursor:pointer;border:1px solid rgba(148,163,184,.35);background:rgba(15,23,42,.85);color:#cbd5e1;border-radius:10px;padding:6px 9px;font-size:12px;">Close</button>

            </div>

            <pre data-phase717-inspection-content="true" style="display:block;box-sizing:border-box;width:100%;max-width:100%;min-height:140px;max-height:560px;overflow:auto;margin-top:12px;padding:10px;border-radius:10px;border:1px solid rgba(51,65,85,.7);background:#020617;color:#e5e7eb;font-size:11px;line-height:1.45;white-space:pre-wrap;overflow-wrap:anywhere;word-break:break-word;"></pre>

          </section>

        </div>

      `;

      const titleNode = root.querySelector("#phase717-inspection-modal-title");

      const contentNode = root.querySelector("[data-phase717-inspection-content]");

      const closeButton = root.querySelector("[data-phase717-inspection-close]");

      const overlay = root.querySelector("[data-phase717-inspection-overlay]");

      if (titleNode) titleNode.textContent = title;

      if (contentNode) contentNode.textContent = content;

      const close = () => {

        root.innerHTML = "";

        resolve(true);

      };

      if (closeButton) closeButton.focus();

      if (closeButton) closeButton.addEventListener("click", close, { once: true });

      if (overlay) {

        overlay.addEventListener("click", (event) => {

          if (event.target === overlay) close();

        });

      }

    });

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

      ? "This will create a new queued attempt using a fresh-context execution strategy.\n\nPlease confirm this action to continue."

      : "This will create a new queued attempt for this task.\n\nPlease confirm this action to continue.";

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

      await phase717RetryModal({ title: "Retry failed", message: `${err && (err as any).message ? (err as any).message : String(err)}`, confirmLabel: "Close", cancelLabel: null, tone: "error" });

    } finally {

      if (button) {

        button.disabled = false;

        button.textContent = originalText;

      }

    }

  }

  document.addEventListener("click", function(event) {

    const detailButton = event.target.closest("[data-phase717-inspect-details]");

    const traceButton = event.target.closest("[data-phase717-inspect-trace]");

    const logsButton = event.target.closest("[data-phase717-inspect-logs]");

    const inspectionButton = detailButton || traceButton || logsButton;

    if (!inspectionButton) return;

    event.preventDefault();

    phase717InspectionModal({

      title: inspectionButton.getAttribute("data-phase717-inspect-title") || "Read-only inspection",

      content: inspectionButton.getAttribute("data-phase717-inspect-content") || "No inspection content available."

    });

  });

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
    // Phase 719: /api/agents is retired in this runtime.
    // Stale fetch disabled to preserve console clarity.
    // Agent Pool intentionally preserved during refresh; /api/agents is retired.


    try {
      const data = await getJson("/api/tasks?limit=12");
      renderRecent(data.tasks || []);
    } catch (e) {
      console.warn("[phase530] recent tasks render failed", e);
    }

    // Phase 719: /api/activity-graph is retired in this runtime.
    // Stale fetch disabled to preserve console clarity.
    renderActivity([]);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", refresh, { once: true });
  } else {
    refresh();
  }

  setInterval(refresh, POLL_MS);


  // Phase 719 — Preview artifact modal (frontend-only, read-only)

  function phase719EnsurePreviewModal() {

    let modal = document.getElementById("phase719-preview-modal");

    if (modal) return modal;

    modal = document.createElement("div");

    modal.id = "phase719-preview-modal";

    modal.style.cssText = "display:none;position:fixed;inset:0;z-index:9999;background:rgba(2,6,23,.72);backdrop-filter:blur(5px);align-items:center;justify-content:center;padding:18px;";

    modal.innerHTML = `

      <div role="dialog" aria-modal="true" aria-labelledby="phase719-preview-title" style="width:min(760px,96vw);max-height:86vh;overflow:auto;background:#020617;border:1px solid rgba(148,163,184,.35);border-radius:16px;box-shadow:0 24px 70px rgba(0,0,0,.55);padding:16px;color:#e5e7eb;">

        <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;margin-bottom:12px;">

          <div>

            <div id="phase719-preview-title" style="font-size:14px;font-weight:800;color:#f8fafc;">Artifact Preview</div>

            <div id="phase719-preview-subtitle" style="margin-top:4px;font-size:11px;color:#94a3b8;overflow-wrap:anywhere;"></div>

          </div>

          <button type="button" data-phase719-preview-close="true" style="cursor:pointer;border:1px solid rgba(148,163,184,.35);background:rgba(15,23,42,.85);color:#cbd5e1;border-radius:999px;padding:5px 10px;font-size:12px;">Close</button>

        </div>

        <div id="phase719-preview-meta" style="font-size:12px;line-height:1.6;color:#bbf7d0;border:1px solid rgba(134,239,172,.25);background:rgba(20,83,45,.12);border-radius:12px;padding:10px;margin-bottom:12px;"></div>

        <div id="phase719-preview-body" style="overflow-wrap:anywhere;font-size:13px;line-height:1.6;color:#dbeafe;border:1px solid rgba(96,165,250,.24);background:linear-gradient(180deg, rgba(15,23,42,.92), rgba(2,6,23,.74));border-radius:16px;padding:18px;margin:0;box-shadow:inset 0 1px 0 rgba(255,255,255,.04);"></div>

      </div>

    `;

    document.body.appendChild(modal);

    modal.addEventListener("click", function (event) {

      if (event.target === modal || event.target.closest("[data-phase719-preview-close]")) {

        modal.style.display = "none";

      }

    });

    document.addEventListener("keydown", function (event) {

      if (event.key === "Escape" && modal.style.display !== "none") {

        modal.style.display = "none";

      }

    });

    return modal;

  }



  function phase719EscapePreviewHtml(value) {

    return String(value || "")

      .replace(/&/g, "&amp;")

      .replace(/</g, "&lt;")

      .replace(/>/g, "&gt;")

      .replace(/"/g, "&quot;")

      .replace(/'/g, "&#039;");

  }

  function phase733NormalizePreviewTransportText(value) {

    return String(value || "")

      .replace(/\\r\\n/g, "\n")

      .replace(/\\n/g, "\n")

      .replace(/\\t/g, "  ");

  }

  function phase733BuildPreviewThemeFromStyleIntent(styleIntent) {

    const baseTheme = {

      shell: "radial-gradient(circle at top left, rgba(59,130,246,.18), transparent 34%),linear-gradient(180deg, rgba(15,23,42,.96), rgba(2,6,23,.9))",

      border: "rgba(148,163,184,.22)",

      heading: "#f8fafc",

      body: "#e0f2fe",

      secondary: "#cbd5e1",

      card: "rgba(15,23,42,.7)",

      cardBorder: "rgba(96,165,250,.22)",

      accent: "#93c5fd",

      insight: "rgba(6,78,59,.18)",

      insightBorder: "rgba(45,212,191,.24)",

      insightText: "#ccfbf1",

      shadow: "0 24px 70px rgba(0,0,0,.42), inset 0 1px 0 rgba(255,255,255,.05)"

    };

    if (!styleIntent || typeof styleIntent !== "object") return baseTheme;

    const values = Object.values(styleIntent).map((value) => String(value || "").toLowerCase()).join(" ");

    const wantsSoftGarden = [

      "cream",

      "blush",

      "ivory",

      "plum",

      "mauve",

      "sage",

      "honey",

      "gold",

      "lavender",

      "garden",

      "cozy",

      "cute",

      "soft",

      "magical",

      "rounded"

    ].some((token) => values.includes(token));

    if (!wantsSoftGarden) return baseTheme;

    return {

      shell: "linear-gradient(135deg, #fff7ed 0%, #fdf2f8 46%, #f5f3ff 100%)",

      border: "rgba(190,128,143,.35)",

      heading: "#4a2438",

      body: "#5b3748",

      secondary: "#7b5a68",

      card: "rgba(255,252,247,.88)",

      cardBorder: "rgba(190,128,143,.28)",

      accent: "#8f5f76",

      insight: "rgba(236,253,245,.78)",

      insightBorder: "rgba(134,170,132,.32)",

      insightText: "#35523f",

      shadow: "0 22px 55px rgba(126,75,92,.16), inset 0 1px 0 rgba(255,255,255,.72)"

    };

  }

  function phase720ExtractSemanticEnvelope(markdown) {

    const source = phase733NormalizePreviewTransportText(markdown);

    const match = source.match(/<!--\s*MB_SEMANTIC_ARTIFACT_V1\s*([\s\S]*?)\s*-->/);

    if (!match || !match[1]) return null;

    try {

      const parsed = JSON.parse(match[1].trim());

      if (!parsed || typeof parsed !== "object") return null;

      return parsed;

    } catch (_e) {

      return null;

    }

  }

  function phase720StripSemanticEnvelope(markdown) {

    return phase733NormalizePreviewTransportText(markdown).replace(/<!--\s*MB_SEMANTIC_ARTIFACT_V1\s*[\s\S]*?\s*-->\s*/g, "");

  }

  function phase719ExtractArtifactSections(markdown) {

    const source = phase733NormalizePreviewTransportText(markdown);

    const withoutTrace = source.replace(/## Execution Trace[\s\S]*$/i, "").trim();

    const sections = {};

    let current = "intro";

    sections[current] = [];

    withoutTrace.split(/\r?\n/).forEach((line) => {

      const h2 = line.match(/^##\s+(.+?)\s*$/);

      if (h2) {

        current = h2[1].trim().toLowerCase();

        sections[current] = [];

        return;

      }

      if (/^#\s+/.test(line)) {

        sections.title = [line.replace(/^#\s+/, "").trim()];

        return;

      }

      if (!sections[current]) sections[current] = [];

      sections[current].push(line);

    });

    Object.keys(sections).forEach((key) => {

      sections[key] = sections[key].join("\n").trim();

    });

    return sections;

  }

  function phase719RenderArtifactVisualCard(markdown) {

    const semanticEnvelope = phase720ExtractSemanticEnvelope(markdown);

    const markdownWithoutEnvelope = phase720StripSemanticEnvelope(markdown);

    const phase733Theme = phase733BuildPreviewThemeFromStyleIntent(semanticEnvelope && semanticEnvelope.style_intent);

    const sections = phase719ExtractArtifactSections(markdownWithoutEnvelope);

    const title = sections.title || "Task Artifact";

    const task = sections.task || "";

    const status = sections.status || "";

    const summary = sections.summary || "";

    const deliverable = sections.deliverable || "";

    const details = sections.details || "";

    const recommendations = sections.recommendations || "";

    const nextSteps = sections["next steps"] || sections.nextsteps || "";

    const outcome = sections.outcome || "";

    const explanation = sections.explanation || "";

    const semanticSource = [

      title,

      task,

      summary,

      deliverable,

      details,

      recommendations,

      nextSteps,

      outcome,

      explanation

    ].join(" ").toLowerCase();

    const semanticType = semanticSource.includes("error") || semanticSource.includes("failed") || semanticSource.includes("failure")

      ? "Recovery Artifact"

      : semanticSource.includes("next steps") || semanticSource.includes("recommend")

        ? "Execution Plan"

        : semanticSource.includes("completed") || semanticSource.includes("success")

          ? "Completion Summary"

          : "Task Artifact";

    const semanticPriority = semanticSource.includes("failed") || semanticSource.includes("blocked") || semanticSource.includes("error")

      ? "Needs Review"

      : semanticSource.includes("next") || semanticSource.includes("recommend")

        ? "Actionable"

        : "Informational";



    function phase719CleanRepeatedArtifactText(value) {

      const raw = String(value || "").trim();

      const standardPrefix = "Standard execution prepared for:";

      if (raw.startsWith(standardPrefix)) {

        return raw.replace(standardPrefix, "Prepared artifact for:").trim();

      }

      return raw;

    }

    const displaySummary = phase719CleanRepeatedArtifactText(summary);

    const displayDeliverable = phase719CleanRepeatedArtifactText(deliverable);

    const displayOutcome = phase719CleanRepeatedArtifactText(outcome);

    const enrichedSections = [

      ["Summary", displaySummary],

      ["Deliverable", displayDeliverable],

      ["Details", details],

      ["Recommendations", recommendations],

      ["Next Steps", nextSteps]

    ].filter(([, value]) => String(value || "").trim());

    function phase722NormalizeSemanticText(value) {

      return String(value || "")

        .replace(/Standard execution prepared for:/gi, "")

        .replace(/Prepared artifact for:/gi, "")

        .replace(/\s+/g, " ")

        .trim()

        .toLowerCase();

    }

    function phase722IsDuplicateSemanticText(a, b) {

      const left = phase722NormalizeSemanticText(a);

      const right = phase722NormalizeSemanticText(b);

      return Boolean(left && right && (left === right || left.includes(right) || right.includes(left)));

    }

    const semanticOperatorSummary = semanticEnvelope ? [

      semanticEnvelope.task_summary && !phase722IsDuplicateSemanticText(semanticEnvelope.task_summary, displaySummary)

        ? ["Semantic Summary", semanticEnvelope.task_summary]

        : null,

      Array.isArray(semanticEnvelope.actionable_outputs) && semanticEnvelope.actionable_outputs.length

        ? ["Actionable Outputs", semanticEnvelope.actionable_outputs.filter((item) => !phase722IsDuplicateSemanticText(item, displayDeliverable)).join("\n")]

        : null,

      Array.isArray(semanticEnvelope.evidence_notes) && semanticEnvelope.evidence_notes.length

        ? ["Evidence Notes", semanticEnvelope.evidence_notes.join("\n")]

        : null,

      semanticEnvelope.operator_next_steps && !phase722IsDuplicateSemanticText(semanticEnvelope.operator_next_steps, nextSteps)

        ? ["Operator Next Steps", semanticEnvelope.operator_next_steps]

        : null

    ].filter((entry) => entry && String(entry[1] || "").trim()) : [];

    const chips = [

      status ? `<span style="display:inline-flex;align-items:center;border:1px solid rgba(134,239,172,.38);background:rgba(20,83,45,.22);color:#bbf7d0;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(status)}</span>` : "",

      `<span style="display:inline-flex;align-items:center;border:1px solid rgba(147,197,253,.34);background:rgba(30,64,175,.22);color:#bfdbfe;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(semanticType)}</span>`,

      semanticEnvelope ? `<span style="display:inline-flex;align-items:center;border:1px solid rgba(45,212,191,.34);background:rgba(20,184,166,.14);color:#99f6e4;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">semantic v${phase719EscapePreviewHtml(semanticEnvelope.semantic_version || "1")}</span>` : "",

      `<span style="display:inline-flex;align-items:center;border:1px solid rgba(251,191,36,.34);background:rgba(120,53,15,.18);color:#fde68a;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(semanticPriority)}</span>`

    ].filter(Boolean).join("");

    return `

      <div data-phase719-rendered-artifact-preview="true" style="max-width:920px;margin:0 auto;">

        <div style="border:1px solid ${phase733Theme.border};border-radius:22px;overflow:hidden;background:${phase733Theme.shell};box-shadow:${phase733Theme.shadow};">

          <div style="padding:28px 30px 22px 30px;border-bottom:1px solid rgba(148,163,184,.16);">

            <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:18px;">${chips}</div>

            <div style="font-size:30px;line-height:1.05;font-weight:900;letter-spacing:-.04em;color:${phase733Theme.heading};margin-bottom:12px;">${phase719EscapePreviewHtml(title)}</div>

            ${task ? `<div style="font-size:15px;line-height:1.55;color:${phase733Theme.secondary};max-width:760px;">${phase719EscapePreviewHtml(task)}</div>` : ""}

          </div>

          ${semanticOperatorSummary.length ? `

            <div style="display:grid;grid-template-columns:minmax(0,1fr);gap:12px;padding:22px 24px 0 24px;">

              <section style="border:1px solid ${phase733Theme.insightBorder};border-radius:18px;background:${phase733Theme.insight};padding:18px;">

                <div style="font-size:11px;text-transform:uppercase;letter-spacing:.18em;color:#5eead4;font-weight:900;margin-bottom:12px;">Semantic Insights</div>

                <div style="display:grid;gap:10px;">

                  ${semanticOperatorSummary.map(([label, value]) => `

                    <div style="border-top:1px solid rgba(45,212,191,.16);padding-top:10px;">

                      <div style="font-size:10px;text-transform:uppercase;letter-spacing:.16em;color:#99f6e4;font-weight:900;margin-bottom:5px;">${phase719EscapePreviewHtml(label)}</div>

                      <div style="font-size:14px;line-height:1.55;color:${phase733Theme.insightText};white-space:pre-wrap;">${phase719EscapePreviewHtml(value)}</div>

                    </div>

                  `).join("")}

                </div>

              </section>

            </div>

          ` : ""}

          <div style="display:grid;grid-template-columns:minmax(0,1fr);gap:14px;padding:${semanticOperatorSummary.length ? "14px" : "22px"} 24px 10px 24px;">

            ${enrichedSections.map(([label, value]) => `

              <section style="border:1px solid ${phase733Theme.cardBorder};border-radius:18px;background:${phase733Theme.card};padding:18px;">

                <div style="font-size:11px;text-transform:uppercase;letter-spacing:.18em;color:${phase733Theme.accent};font-weight:900;margin-bottom:10px;">${phase719EscapePreviewHtml(label)}</div>

                <div style="font-size:15px;line-height:1.6;color:${phase733Theme.body};white-space:pre-wrap;">${phase719EscapePreviewHtml(value)}</div>

              </section>

            `).join("")}

          </div>

          <div style="display:grid;grid-template-columns:minmax(0,1.2fr) minmax(220px,.8fr);gap:18px;padding:12px 24px 24px 24px;">

            <section style="border:1px solid ${phase733Theme.cardBorder};border-radius:18px;background:${phase733Theme.card};padding:18px;">

              <div style="font-size:11px;text-transform:uppercase;letter-spacing:.18em;color:${phase733Theme.accent};font-weight:900;margin-bottom:10px;">Outcome</div>

              <div style="font-size:17px;line-height:1.55;color:${phase733Theme.body};font-weight:650;">${phase719EscapePreviewHtml(displayOutcome || "No outcome content available.")}</div>

            </section>

            <section style="border:1px solid ${phase733Theme.insightBorder};border-radius:18px;background:${phase733Theme.insight};padding:18px;">

              <div style="font-size:11px;text-transform:uppercase;letter-spacing:.18em;color:#5eead4;font-weight:900;margin-bottom:10px;">Build Path</div>

              <div style="font-size:14px;line-height:1.55;color:${phase733Theme.insightText};white-space:pre-wrap;">${phase719EscapePreviewHtml(explanation || "No explanation available.")}</div>

            </section>

          </div>

        </div>

      </div>

    `;

  }

  function phase719RenderArtifactIframePreview(renderedHtml) {

    const srcdoc = [

      "<!DOCTYPE html>",

      "<html>",

      "<head>",

      "<meta charset=\"utf-8\">",

      "<style>",

      "html,body{margin:0;padding:0;background:#020617;color:#e5e7eb;font-family:Inter,system-ui,-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;}",

      "body{padding:18px;overflow-wrap:anywhere;}",

      "*{box-sizing:border-box;max-width:100%;}",

      "</style>",

      "</head>",

      "<body>",

      String(renderedHtml || ""),

      "</body>",

      "</html>"

    ].join("");

    return `

      <iframe

        title="Artifact rendered preview"

        sandbox=""

        srcdoc="${phase719EscapePreviewHtml(srcdoc)}"

        style="display:block;width:100%;min-height:560px;border:1px solid rgba(148,163,184,.24);border-radius:16px;background:#020617;"

      ></iframe>

    `;

  }

  // Phase 723 — minimal visual artifact sanitizer helper (non-active)

  function phase723SanitizeVisualArtifactHtml(html) {

    const source = String(html || "");

    const withoutUnsafeBlocks = source

      .replace(/<\s*script\b[\s\S]*?<\s*\/\s*script\s*>/gi, "")

      .replace(/<\s*style\b[\s\S]*?<\s*\/\s*style\s*>/gi, "")

      .replace(/<\s*iframe\b[\s\S]*?<\s*\/\s*iframe\s*>/gi, "")

      .replace(/<\s*object\b[\s\S]*?<\s*\/\s*object\s*>/gi, "")

      .replace(/<\s*embed\b[\s\S]*?>/gi, "")

      .replace(/<\s*link\b[\s\S]*?>/gi, "")

      .replace(/<\s*meta\b[\s\S]*?>/gi, "");

    return withoutUnsafeBlocks

      .replace(/\s+on[a-z]+\s*=\s*"[^"]*"/gi, "")

      .replace(/\s+on[a-z]+\s*=\s*'[^']*'/gi, "")

      .replace(/\s+on[a-z]+\s*=\s*[^\s>]+/gi, "")

      .replace(/\s+(href|src)\s*=\s*"javascript:[^"]*"/gi, "")

      .replace(/\s+(href|src)\s*=\s*'javascript:[^']*'/gi, "")

      .replace(/\s+(href|src)\s*=\s*javascript:[^\s>]+/gi, "");

  }

  // Phase 723 — visual artifact block extraction helper (non-active)

  function phase723ExtractVisualArtifactBlock(markdown) {

    const normalized = phase733NormalizePreviewTransportText(markdown);

    const source = phase720StripSemanticEnvelope(normalized);

    const startMarker = "<!-- visual-artifact:start -->";

    const endMarker = "<!-- visual-artifact:end -->";

    const startIndex = source.indexOf(startMarker);

    const endIndex = source.indexOf(endMarker);

    if (startIndex === -1 || endIndex === -1 || endIndex <= startIndex) {

      return {

        hasVisualArtifact: false,

        visualHtml: "",

        markdownWithoutVisualArtifact: source

      };

    }

    const visualStart = startIndex + startMarker.length;

    const visualHtml = source.slice(visualStart, endIndex).trim();

    const markdownWithoutVisualArtifact = (

      source.slice(0, startIndex) + source.slice(endIndex + endMarker.length)

    ).trim();

    return {

      hasVisualArtifact: Boolean(visualHtml),

      visualHtml,

      markdownWithoutVisualArtifact

    };

  }

  // Phase 723 — embedded visual artifact preview wrapper (non-active)

  function phase723RenderVisualArtifactPreviewCandidate(markdown) {

    const extracted = phase723ExtractVisualArtifactBlock(markdown);

    const fallbackMarkdown = extracted.markdownWithoutVisualArtifact || phase733NormalizePreviewTransportText(markdown);

    const fallbackPreview = phase719RenderArtifactVisualCard(fallbackMarkdown);

    if (!extracted.hasVisualArtifact) {

      return fallbackPreview;

    }

    const safeVisualHtml = phase723SanitizeVisualArtifactHtml(extracted.visualHtml);

    if (!safeVisualHtml) {

      return fallbackPreview;

    }

    return `

      <div data-phase723-visual-artifact-preview="true" style="max-width:960px;margin:0 auto 22px auto;border:1px solid rgba(45,212,191,.32);background:linear-gradient(135deg,rgba(15,23,42,.78),rgba(8,47,73,.46));border-radius:26px;padding:22px;box-shadow:0 24px 80px rgba(0,0,0,.32), inset 0 1px 0 rgba(255,255,255,.06);">

        <div style="display:flex;align-items:center;justify-content:space-between;gap:14px;margin-bottom:18px;">

          <div style="font-size:12px;text-transform:uppercase;letter-spacing:.2em;color:#ccfbf1;font-weight:950;text-shadow:0 0 22px rgba(45,212,191,.18);">Visual Artifact</div>

          <div style="font-size:10px;text-transform:uppercase;letter-spacing:.14em;color:#dbeafe;border:1px solid rgba(147,197,253,.34);border-radius:999px;padding:5px 10px;background:rgba(30,64,175,.22);box-shadow:inset 0 1px 0 rgba(255,255,255,.05);">sanitized html subset</div>

        </div>

        <div data-phase723-visual-artifact-body="true" style="overflow:auto;border-radius:20px;background:rgba(2,6,23,.46);border:1px solid rgba(148,163,184,.24);padding:18px;color:#e5e7eb;box-shadow:inset 0 1px 0 rgba(255,255,255,.04);">

          <div data-phase735-visual-html-mount="true"></div>

          <template data-phase735-visual-html-template="true">${phase719EscapePreviewHtml(safeVisualHtml)}</template>

        </div>

      </div>

    `;

  }

  function phase735DecodeVisualArtifactHtmlTransport(html) {

    const source = phase733NormalizePreviewTransportText(html || "")

      .replace(/\\\\n/g, "\n")

      .replace(/\\\\\"/g, '"')

      .replace(/\\\\'/g, "'")

      .replace(/style="\\+"/g, 'style="')

      .replace(/;\\+"/g, ';')

      .replace(/\\+"=/g, '=');

    const textarea = document.createElement("textarea");

    textarea.innerHTML = source;

    return textarea.value;

  }

  function phase719RenderMarkdownArtifactPreview(markdown) {

    const extractedVisual = phase723ExtractVisualArtifactBlock(markdown);

    if (extractedVisual.hasVisualArtifact) {

      const decodedVisualHtml = phase735DecodeVisualArtifactHtmlTransport(extractedVisual.visualHtml);

      const safeVisualHtml = phase723SanitizeVisualArtifactHtml(decodedVisualHtml);

      return `

        <div

          data-phase733-single-artifact-render="true"

          style="

            max-width:1040px;

            margin:0 auto;

            border:1px solid rgba(148,163,184,.28);

            border-radius:22px;

            padding:18px;

            background:rgba(15,23,42,.42);

            box-shadow:0 24px 80px rgba(0,0,0,.32), inset 0 1px 0 rgba(255,255,255,.05);

            overflow:auto;

          "

        >

          <div data-phase735-visual-html-mount="true"></div>

          <template data-phase735-visual-html-template="true">${phase719EscapePreviewHtml(safeVisualHtml)}</template>

        </div>

      `;

    }

    const strippedFallback = phase720StripSemanticEnvelope(markdown);

    const decodedFallback = phase735DecodeVisualArtifactHtmlTransport(strippedFallback);

    const fallbackLooksLikeHtml = /<\s*div\b|<\s*section\b|<\s*article\b/i.test(decodedFallback);

    if (fallbackLooksLikeHtml) {

      const safeFallbackHtml = phase723SanitizeVisualArtifactHtml(decodedFallback);

      return `

        <div

          data-phase733-single-artifact-render="true"

          data-phase735-fallback-html-artifact="true"

          style="

            max-width:1040px;

            margin:0 auto;

            border:1px solid rgba(148,163,184,.28);

            border-radius:22px;

            padding:18px;

            background:rgba(15,23,42,.42);

            box-shadow:0 24px 80px rgba(0,0,0,.32), inset 0 1px 0 rgba(255,255,255,.05);

            overflow:auto;

          "

        >

          <div data-phase735-visual-html-mount="true"></div>

          <template data-phase735-visual-html-template="true">${phase719EscapePreviewHtml(safeFallbackHtml)}</template>

        </div>

      `;

    }

    return `

      <div

        data-phase733-single-artifact-render-fallback="true"

        style="

          max-width:920px;

          margin:0 auto;

          border:1px solid rgba(148,163,184,.28);

          border-radius:22px;

          padding:22px;

          background:rgba(15,23,42,.72);

          color:#e5e7eb;

          white-space:pre-wrap;

          overflow-wrap:anywhere;

        "

      >${phase719EscapePreviewHtml(strippedFallback)}</div>

    `;

  }

  async function phase719OpenPreviewModal(button) {

    const modal = phase719EnsurePreviewModal();

    const title = modal.querySelector("#phase719-preview-title");

    const subtitle = modal.querySelector("#phase719-preview-subtitle");

    const meta = modal.querySelector("#phase719-preview-meta");

    const body = modal.querySelector("#phase719-preview-body");

    const taskTitle = button.getAttribute("data-task-title") || "Artifact Preview";

    const taskId = button.getAttribute("data-task-id") || "";

    const fallbackName = button.getAttribute("data-artifact-name") || "artifact";

    const fallbackType = button.getAttribute("data-artifact-type") || "artifact";

    const fallbackSize = button.getAttribute("data-artifact-size") || "";

    const fallbackPath = button.getAttribute("data-artifact-path") || "";

    const fallbackOutcome = button.getAttribute("data-artifact-outcome") || "";

    const fallbackExplanation = button.getAttribute("data-artifact-explanation") || "";

    title.textContent = "Preview: " + taskTitle;

    subtitle.textContent = taskId ? "task_id: " + taskId : "";

    meta.textContent = [

      "artifact: " + fallbackName,

      fallbackType ? "type: " + fallbackType : "",

      fallbackSize ? "size: " + fallbackSize : "",

      fallbackPath ? "path: " + fallbackPath : ""

    ].filter(Boolean).join("\n");

    body.innerHTML = `<div style="color:#93c5fd;font-size:14px;">Loading rendered artifact preview…</div>`;

    modal.style.display = "flex";

    if (!taskId) {

      body.textContent = "No task id available for artifact preview.";

      return;

    }

    try {

      const res = await fetch(`/api/tasks/${encodeURIComponent(taskId)}/artifact-preview`, { cache: "no-store" });

      const data = await res.json().catch(() => null);

      if (!res.ok || !data || data.ok !== true) {

        body.textContent = [

          "Rendered artifact content is not available.",

          data && data.error ? "Error: " + data.error : "",

          fallbackOutcome ? "\nOutcome:\n" + fallbackOutcome : "",

          fallbackExplanation ? "\nExplanation:\n" + fallbackExplanation : ""

        ].filter(Boolean).join("\n");

        return;

      }

      const artifact = data.artifact || {};

      const renderedName = artifact.filename || fallbackName;

      const renderedType = artifact.type || fallbackType;

      const renderedSize = artifact.size_bytes ? String(artifact.size_bytes) + " bytes" : fallbackSize;

      const renderedCreated = artifact.created_at || "";

      meta.textContent = [

        "artifact: " + renderedName,

        renderedType ? "type: " + renderedType : "",

        renderedSize ? "size: " + renderedSize : "",

        renderedCreated ? "created: " + renderedCreated : ""

      ].filter(Boolean).join("\n");

      body.innerHTML = phase719RenderMarkdownArtifactPreview(data.content);

      body.querySelectorAll("[data-phase735-visual-html-mount]").forEach((phase735Mount) => {

        const template = phase735Mount.parentElement

          ? phase735Mount.parentElement.querySelector("[data-phase735-visual-html-template]")

          : null;

        const templateHtml = template ? template.textContent : "";

        try {

          const decoded = phase735DecodeVisualArtifactHtmlTransport(templateHtml);

          phase735Mount.innerHTML = phase723SanitizeVisualArtifactHtml(decoded);

          if (template) template.remove();

        } catch (error) {

          phase735Mount.textContent = "Unable to render artifact preview.";

        }

      });

    } catch (error) {

      body.textContent = [

        "Preview fetch failed.",

        error && error.message ? error.message : String(error),

        fallbackOutcome ? "\nOutcome:\n" + fallbackOutcome : "",

        fallbackExplanation ? "\nExplanation:\n" + fallbackExplanation : ""

      ].filter(Boolean).join("\n");

    }

  }


  document.addEventListener("click", function (event) {

    const button = event.target.closest("[data-phase719-preview-artifact]");

    if (!button) return;

    event.preventDefault();

    phase719OpenPreviewModal(button);

  });


})();
