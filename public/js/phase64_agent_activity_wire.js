/*
PHASE 64 — AGENT ACTIVITY WIRING
Behavior-only population of the existing Agent Pool container.
NO layout restructuring outside the protected container.
*/

(function () {
  const AGENTS = ["Matilda", "Atlas", "Cade", "Effie"];
  const POLL_MS = 15000;
  const RECENT_ACTIVE_MS = 5 * 60 * 1000;

  const state = Object.fromEntries(
    AGENTS.map((name) => [
      name,
      {
        name,
        status: "idle",
        taskId: null,
        runId: null,
        lastEvent: "idle",
        updatedAt: 0,
        source: "bootstrap",
      },
    ])
  );

  let pollTimer = null;
  let ownedTaskEventsStream = null;

  function nowTs() {
    return Date.now();
  }

  function escapeHtml(value) {
    return String(value ?? "")
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;");
  }

  function normalizeAgentName(value) {
    const s = String(value ?? "").trim().toLowerCase();
    if (!s) return null;
    if (s.includes("matilda")) return "Matilda";
    if (s.includes("atlas")) return "Atlas";
    if (s.includes("cade")) return "Cade";
    if (s.includes("effie")) return "Effie";
    return null;
  }

  function humanizeAge(ts) {
    if (!ts) return "No recent activity";
    const delta = Math.max(0, nowTs() - ts);
    const sec = Math.floor(delta / 1000);
    if (sec < 5) return "Updated just now";
    if (sec < 60) return `Updated ${sec}s ago`;
    const min = Math.floor(sec / 60);
    if (min < 60) return `Updated ${min}m ago`;
    const hr = Math.floor(min / 60);
    return `Updated ${hr}h ago`;
  }

  function computeVisualStatus(agent) {
    const entry = state[agent];
    if (!entry) return "idle";
    if (entry.status === "busy") return "busy";
    if (entry.updatedAt && nowTs() - entry.updatedAt < RECENT_ACTIVE_MS) return "recent";
    return "idle";
  }

  function computeSummary(agent) {
    const entry = state[agent];
    if (!entry) return "Awaiting runtime signal";
    if (entry.status === "busy" && entry.taskId) {
      return `Working on ${entry.taskId}`;
    }
    if (entry.status === "busy") {
      return "Working";
    }
    if (entry.lastEvent && entry.lastEvent !== "idle") {
      return `Last event: ${entry.lastEvent}`;
    }
    return "Awaiting runtime signal";
  }

  function statusBadge(status) {
    if (status === "busy") {
      return {
        label: "ACTIVE",
        className: "bg-emerald-500/20 text-emerald-300 border border-emerald-500/40",
      };
    }
    if (status === "recent") {
      return {
        label: "RECENT",
        className: "bg-amber-500/20 text-amber-300 border border-amber-500/40",
      };
    }
    return {
      label: "IDLE",
      className: "bg-slate-700/60 text-slate-300 border border-slate-600/60",
    };
  }

  function ensureContainer() {
    return document.getElementById("agent-status-container");
  }

  function getActiveAgentCount() {
    return AGENTS.filter((agent) => computeVisualStatus(agent) === "busy").length;
  }

  function renderMetricAgents() {
    const el = document.getElementById("metric-agents");
    if (!el) return;
    el.textContent = String(getActiveAgentCount());
  }

  function renderAgentPool() {
    const container = ensureContainer();
    if (!container) return;

    container.innerHTML = `
      <h2 class="text-lg font-semibold text-gray-200 w-full">Agent Pool</h2>
      <div class="w-full grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-3" data-phase64-agent-grid="true">
        ${AGENTS.map((agent) => {
          const entry = state[agent];
          const visual = computeVisualStatus(agent);
          const badge = statusBadge(visual);
          const summary = computeSummary(agent);
          const age = humanizeAge(entry.updatedAt);
          return `
            <article
              data-agent="${escapeHtml(agent)}"
              data-agent-visual-state="${escapeHtml(visual)}"
              class="rounded-xl border border-gray-700 bg-gray-900/70 px-3 py-3 shadow-lg"
            >
              <div class="flex items-start justify-between gap-3">
                <div>
                  <h3 class="text-sm font-semibold text-gray-100">${escapeHtml(agent)}</h3>
                  <p class="text-xs text-gray-400 mt-1" data-agent-summary="true">${escapeHtml(summary)}</p>
                </div>
                <span class="agent-state inline-flex items-center rounded-full px-2 py-1 text-[10px] font-semibold tracking-wide ${badge.className}">
                  ${badge.label}
                </span>
              </div>
              <div class="mt-3 text-[11px] text-gray-500" data-agent-updated="true">${escapeHtml(age)}</div>
            </article>
          `;
        }).join("")}
      </div>
    `;

    renderMetricAgents();

    window.__PHASE64_AGENT_ACTIVITY_STATE__ = {
      activeAgents: getActiveAgentCount(),
      agents: AGENTS.map((agent) => ({
        agent,
        visualState: computeVisualStatus(agent),
        ...state[agent],
      })),
    };
  }

  function updateAgent(agent, patch) {
    if (!state[agent]) return;
    state[agent] = {
      ...state[agent],
      ...patch,
      updatedAt: patch.updatedAt ?? nowTs(),
    };
    renderAgentPool();
  }

  function markBusy(agent, meta = {}) {
    updateAgent(agent, {
      status: "busy",
      taskId: meta.taskId ?? state[agent].taskId ?? null,
      runId: meta.runId ?? state[agent].runId ?? null,
      lastEvent: meta.lastEvent ?? "running",
      source: meta.source ?? "event",
      updatedAt: meta.updatedAt ?? nowTs(),
    });
  }

  function markIdle(agent, meta = {}) {
    updateAgent(agent, {
      status: "idle",
      taskId: meta.clearTask ? null : (meta.taskId ?? state[agent].taskId ?? null),
      runId: meta.clearRun ? null : (meta.runId ?? state[agent].runId ?? null),
      lastEvent: meta.lastEvent ?? "idle",
      source: meta.source ?? "event",
      updatedAt: meta.updatedAt ?? nowTs(),
    });
  }

  function ingestTaskEvent(payload) {
    const agent = normalizeAgentName(payload?.actor ?? payload?.agent ?? payload?.owner);
    if (!agent) return;

    const eventState = String(payload?.state ?? payload?.status ?? payload?.kind ?? "").toLowerCase();
      const eventToken = eventState.split(".").pop();
    const taskId = payload?.task_id ?? payload?.taskId ?? null;
    const runId = payload?.run_id ?? payload?.runId ?? null;
    const ts = Number(payload?.ts ?? payload?.timestamp ?? Date.now()) || Date.now();

    if (
        eventToken === "started" ||
        eventToken === "running" ||
        eventToken === "created" ||
        eventToken === "dispatch" ||
        eventToken === "assigned"
      ) {
      markBusy(agent, {
        taskId,
        runId,
        lastEvent: eventToken || eventState || "running",
        source: "task-events",
        updatedAt: ts,
      });
      return;
    }

    if (
        eventToken === "completed" ||
        eventToken === "failed" ||
        eventToken === "cancelled" ||
        eventToken === "canceled" ||
        eventToken === "timeout" ||
        eventToken === "terminal"
      ) {
      markIdle(agent, {
        clearTask: true,
        clearRun: true,
        lastEvent: eventToken || eventState || "idle",
        source: "task-events",
        updatedAt: ts,
      });
    }
  }

  async function reconcileFromRuns() {
    try {
      const res = await fetch("/api/runs?limit=50", {
        headers: { Accept: "application/json" },
        cache: "no-store",
      });

      if (!res.ok) return;

      const payload = await res.json();
      const rows = Array.isArray(payload?.rows) ? payload.rows : [];

      const busyByAgent = new Map();

      for (const row of rows) {
        const agent = normalizeAgentName(row?.actor);
        if (!agent) continue;

        const isTerminal = Boolean(row?.is_terminal);
        const taskStatus = String(row?.task_status ?? "").toLowerCase();

        if (
          !isTerminal &&
          taskStatus &&
          taskStatus !== "completed" &&
          taskStatus !== "failed" &&
          taskStatus !== "cancelled" &&
          taskStatus !== "canceled"
        ) {
          busyByAgent.set(agent, row);
        }
      }

      for (const agent of AGENTS) {
        const row = busyByAgent.get(agent);
        if (row) {
          markBusy(agent, {
            taskId: row?.task_id ?? null,
            runId: row?.run_id ?? null,
            lastEvent: row?.last_event_kind ?? "running",
            source: "runs",
            updatedAt: Number(row?.last_event_ts) || nowTs(),
          });
        } else if (state[agent].status === "busy") {
          markIdle(agent, {
            clearTask: true,
            clearRun: true,
            lastEvent: "idle",
            source: "runs",
            updatedAt: nowTs(),
          });
        }
      }

      renderMetricAgents();
    } catch (_) {
      // Preserve last known state on reconcile failure.
    }
  }

  function attachToTaskEventsStream(stream) {
    if (!stream || stream.__PHASE64_ATTACHED__) return;
    stream.__PHASE64_ATTACHED__ = true;

    stream.addEventListener("message", (event) => {
      try {
        const payload = JSON.parse(event.data);
        ingestTaskEvent(payload);
      } catch (_) {
        // Ignore malformed events.
      }
    });
  }

  function wireTaskEvents() {
    if (window.taskEventsStream) {
      attachToTaskEventsStream(window.taskEventsStream);
      return;
    }

    try {
      ownedTaskEventsStream = new EventSource("/events/task-events");
      window.taskEventsStream = ownedTaskEventsStream;
      attachToTaskEventsStream(ownedTaskEventsStream);
    } catch (_) {
      // Polling reconciliation remains active even if SSE attach fails.
    }
  }

  function startPolling() {
    if (pollTimer) return;
    reconcileFromRuns();
    pollTimer = window.setInterval(reconcileFromRuns, POLL_MS);
  }

  function bootstrap() {
    const container = ensureContainer();
    if (!container) return;

    renderAgentPool();
    renderMetricAgents();
    wireTaskEvents();
    startPolling();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", bootstrap, { once: true });
  } else {
    bootstrap();
  }
})();
