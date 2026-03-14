// Phase 60 — Agent Pool compact console rows
// Cosmetic renderer only.
// Keeps the existing OPS SSE behavior, but restores the intended
// dense operator-console row appearance with role emojis.

(() => {
  const container = document.getElementById("agent-status-container");
  if (!container) {
    console.warn("agent-status-row.js: #agent-status-container not found.");
    return;
  }

  const title = container.querySelector("h2");
  container.innerHTML = "";
  if (title) container.appendChild(title);

  const AGENTS = ["Matilda", "Atlas", "Cade", "Effie"];

  const AGENT_EMOJI = {
    matilda: "🗣️",
    atlas: "🧭",
    cade: "💻",
    effie: "📊",
  };

  const indicators = {};
  const agentActivityAt = Object.create(null);
  const agentReportedState = Object.create(null);
  const ACTIVE_WINDOW_MS = 60 * 1000;
  const activeAgentsMetricEl = document.getElementById("metric-agents");

  function setMetricText(el, value) {
    if (!el) return;
    el.textContent = value;
  }

  function parseTimestamp(value) {
    if (typeof value === "number" && Number.isFinite(value)) return value;
    if (typeof value === "string" && value.trim()) {
      const n = Number(value);
      if (Number.isFinite(n)) return n;
      const parsed = Date.parse(value);
      if (Number.isFinite(parsed)) return parsed;
    }
    return null;
  }

  function formatAge(ms) {
    if (!Number.isFinite(ms) || ms < 0) return "0s";
    const totalSeconds = Math.floor(ms / 1000);
    if (totalSeconds < 60) return `${totalSeconds}s`;
    const totalMinutes = Math.floor(totalSeconds / 60);
    if (totalMinutes < 60) return `${totalMinutes}m`;
    return `${Math.floor(totalMinutes / 60)}h`;
  }

  function refreshActiveAgentsMetric() {
    if (!activeAgentsMetricEl) return;

    const now = Date.now();
    let count = 0;

    for (const name of AGENTS) {
      const key = name.toLowerCase();
      const at = parseTimestamp(agentActivityAt[key]);
      if (at != null && now - at <= ACTIVE_WINDOW_MS) count += 1;
    }

    setMetricText(activeAgentsMetricEl, String(count));
  }

  function getAgentPresentation(agentKey, reportedStatus) {
    const reported = String(reportedStatus || "").trim();
    const normalized = reported.toLowerCase();
    const at = parseTimestamp(agentActivityAt[agentKey]);

    if (at == null) {
      return {
        kind: "unknown",
        label: reported || "unknown",
      };
    }

    const ageMs = Math.max(0, Date.now() - at);
    const ageLabel = formatAge(ageMs);

    if (ageMs > ACTIVE_WINDOW_MS) {
      return {
        kind: "stale",
        label: `stale · ${ageLabel} ago`,
      };
    }

    if (
      normalized.includes("error") ||
      normalized.includes("failed") ||
      normalized.includes("offline")
    ) {
      return {
        kind: "error",
        label: `${reported || "error"} · ${ageLabel} ago`,
      };
    }

    if (normalized && normalized !== "unknown") {
      return {
        kind: "active",
        label: `${reported} · ${ageLabel} ago`,
      };
    }

    return {
      kind: "active",
      label: `active · ${ageLabel} ago`,
    };
  }

  setMetricText(activeAgentsMetricEl, "—");

  const stack = document.createElement("div");
  stack.className = "w-full flex flex-col gap-0.5";
  container.appendChild(stack);

  AGENTS.forEach((name) => {
    const key = name.toLowerCase();

    const row = document.createElement("div");
    row.className =
      "w-full min-h-0 rounded-md bg-slate-600/55 border border-slate-500/35 px-3 py-1.5 flex items-center justify-between shadow-sm";

    const left = document.createElement("div");
    left.className = "flex items-center gap-3 min-w-0 h-[18px]";

    const emoji = document.createElement("span");
    emoji.className = "inline-flex items-center justify-center shrink-0";
    emoji.textContent = AGENT_EMOJI[key] || "•";
    emoji.style.width = "18px";
    emoji.style.minWidth = "18px";
    emoji.style.height = "18px";
    emoji.style.minHeight = "18px";
    emoji.style.fontSize = "14px";
    emoji.style.lineHeight = "1";
    emoji.style.background = "transparent";
    emoji.style.borderRadius = "0";
    emoji.style.boxShadow = "none";
    emoji.style.marginRight = "0";

    const label = document.createElement("span");
    label.className = "text-[13px] font-semibold tracking-tight text-slate-100/95 truncate";
    label.textContent = name;

    const status = document.createElement("span");
    status.className = "text-[12px] font-medium text-slate-200/90 truncate";
    status.textContent = "unknown";

    left.append(emoji, label);
    row.append(left, status);
    stack.appendChild(row);

    indicators[key] = { row, emoji, label, status };
  });

  const OPS_SSE_URL = `/events/ops`;
  const __DISABLE_OPTIONAL_SSE =
    (typeof window !== "undefined" && window.__DISABLE_OPTIONAL_SSE) === true;

  function applyVisual(agentKey, statusString) {
    const indicator = indicators[agentKey];
    if (!indicator) return;

    agentReportedState[agentKey] = String(statusString || agentReportedState[agentKey] || "unknown");

    const presentation = getAgentPresentation(agentKey, agentReportedState[agentKey]);
    const kind = presentation.kind;
    indicator.status.textContent = presentation.label;

    indicator.row.className =
      "w-full min-h-0 rounded-md border px-3 py-1.5 flex items-center justify-between shadow-sm";

    indicator.emoji.className = "inline-flex items-center justify-center shrink-0";
    indicator.emoji.textContent = AGENT_EMOJI[agentKey] || "•";
    indicator.emoji.style.display = "inline-flex";
    indicator.emoji.style.width = "18px";
    indicator.emoji.style.minWidth = "18px";
    indicator.emoji.style.height = "18px";
    indicator.emoji.style.minHeight = "18px";
    indicator.emoji.style.fontSize = "14px";
    indicator.emoji.style.lineHeight = "1";
    indicator.emoji.style.background = "transparent";
    indicator.emoji.style.borderRadius = "0";
    indicator.emoji.style.boxShadow = "none";
    indicator.emoji.style.marginRight = "0";

    indicator.label.className = "text-[13px] font-semibold tracking-tight truncate";
    indicator.status.className = "text-[11px] font-medium truncate";

    switch (kind) {
      case "active":
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-emerald-300/90");
        break;
      case "error":
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-rose-300/90");
        break;
      case "stale":
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-amber-200/90");
        break;
      case "unknown":
      default:
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-slate-300/75");
        break;
    }
  }

  function refreshAgentRows() {
    Object.keys(indicators).forEach((key) => {
      applyVisual(key, agentReportedState[key] || "unknown");
    });
  }

  Object.keys(indicators).forEach((key) => applyVisual(key, "unknown"));

  if (__DISABLE_OPTIONAL_SSE) {
    console.warn("[agent-status-row] Optional SSE disabled:", OPS_SSE_URL);
    return;
  }

  function parseJson(raw) {
    try {
      return JSON.parse(raw);
    } catch {
      return null;
    }
  }

  function extractPayload(data) {
    if (!data || typeof data !== "object") return null;
    if (data.payload && typeof data.payload === "object") return data.payload;
    if (data.data && typeof data.data === "object") return data.data;
    if (data.state && typeof data.state === "object") return data.state;
    return data;
  }

  function applyAgentMap(payload) {
    if (!payload || typeof payload !== "object") return false;
    const agents = payload.agents;
    if (!agents || typeof agents !== "object") return false;

    let applied = false;
    for (const [name, value] of Object.entries(agents)) {
      const key = String(name || "").toLowerCase();
      if (!indicators[key]) continue;

      let status = "unknown";
      if (typeof value === "string") {
        status = value;
      } else if (value && typeof value === "object") {
        status =
          value.status ??
          value.state ??
          value.level ??
          value.health ??
          value.mode ??
          "unknown";

        const at =
          value.at ??
          value.ts ??
          value.last_activity ??
          value.lastActivity ??
          value.last_seen ??
          value.lastSeen ??
          null;
        if (at != null) agentActivityAt[key] = at;
      }

      applyVisual(key, String(status || "unknown"));
      applied = true;
    }

    refreshActiveAgentsMetric();
    return applied;
  }

  function applySingleAgent(data) {
    if (!data || typeof data !== "object") return false;

    const agentName =
      (data.agent || data.actor || data.source || data.worker || data.name || "").toString().toLowerCase();
    if (!agentName || !indicators[agentName]) return false;

    const status =
      data.status ??
      data.state ??
      data.level ??
      data.health ??
      data.mode ??
      "unknown";

    const at =
      data.at ??
      data.ts ??
      data.last_activity ??
      data.lastActivity ??
      data.last_seen ??
      data.lastSeen ??
      null;
    if (at != null) agentActivityAt[agentName] = at;

    applyVisual(agentName, String(status || "unknown"));
    refreshActiveAgentsMetric();
    return true;
  }

  function handleOpsEvent(eventName, event) {
    const data = parseJson(event.data);
    if (!data) return;

    const payload = extractPayload(data);

    if (eventName === "ops.state") {
      if (applyAgentMap(payload)) return;
    }

    if (applyAgentMap(data)) return;
    if (applyAgentMap(payload)) return;
    applySingleAgent(payload);
    applySingleAgent(data);
  }

  let source;
  try {
    source = (window.__PHASE16_SSE_OWNER_STARTED ? null : new EventSource(OPS_SSE_URL));
  } catch (err) {
    console.error("agent-status-row.js: Failed to open OPS SSE connection:", err);
    return;
  }

  if (!source) return;

  source.onmessage = (event) => handleOpsEvent("message", event);
  source.addEventListener("hello", (event) => handleOpsEvent("hello", event));
  source.addEventListener("ops.state", (event) => handleOpsEvent("ops.state", event));
  source.addEventListener("state", (event) => handleOpsEvent("state", event));
  source.addEventListener("update", (event) => handleOpsEvent("update", event));

  source.onerror = (err) => {
    console.warn("agent-status-row.js: OPS SSE error:", err);
    Object.keys(indicators).forEach((key) => applyVisual(key, "unknown"));
    setMetricText(activeAgentsMetricEl, "—");
  };
})();
;/* PHASE63_SHARED_TASK_EVENTS_METRICS */
(() => {
  if (typeof window === 'undefined') return;
  if (window.__PHASE63_SHARED_TASK_EVENTS_METRICS__) return;
  window.__PHASE63_SHARED_TASK_EVENTS_METRICS__ = true;

  const tasksNode = document.getElementById('metric-tasks');
  const successNode = document.getElementById('metric-success') || document.getElementById('metric-success-rate');
  const latencyNode = document.getElementById('metric-latency');

  const runningTaskIds = new Set();
  const taskStartTimes = new Map();
  const seenTerminalEvents = new Set();
  const recentDurationsMs = [];
  const maxSamples = 50;

  let completedCount = 0;
  let failedCount = 0;

  const runningTypes = new Set([
    'created',
    'queued',
    'leased',
    'started',
    'running',
    'in_progress',
    'delegated',
    'retrying'
  ]);

  const terminalSuccessTypes = new Set([
    'completed',
    'complete',
    'done',
    'success'
  ]);

  const terminalFailureTypes = new Set([
    'failed',
    'error',
    'cancelled',
    'canceled',
    'timed_out',
    'timeout',
    'terminated',
    'aborted'
  ]);

  const terminalTypes = new Set([
    ...terminalSuccessTypes,
    ...terminalFailureTypes
  ]);

  const normalize = (value) =>
    String(value || '')
      .trim()
      .toLowerCase()
      .replace(/\s+/g, '_');

  const safeJsonParse = (value) => {
    try {
      return JSON.parse(value);
    } catch {
      return null;
    }
  };

  const getTaskId = (payload) =>
    payload?.task_id ??
    payload?.taskId ??
    payload?.id ??
    payload?.data?.task_id ??
    payload?.data?.taskId ??
    null;

  const getEventType = (eventName, payload) =>
    normalize(
      payload?.type ??
      payload?.event ??
      payload?.status ??
      payload?.state ??
      eventName
    );

  const toMs = (value) => {
    if (typeof value === 'number' && Number.isFinite(value)) {
      return value > 1e12 ? value : value * 1000;
    }

    if (typeof value === 'string' && value.trim()) {
      const asNum = Number(value);
      if (Number.isFinite(asNum)) {
        return asNum > 1e12 ? asNum : asNum * 1000;
      }

      const parsed = Date.parse(value);
      if (Number.isFinite(parsed)) return parsed;
    }

    return Date.now();
  };

  const getEventTs = (payload) =>
    toMs(
      payload?.ts ??
      payload?.timestamp ??
      payload?.at ??
      payload?.time ??
      payload?.created_at ??
      payload?.updated_at ??
      Date.now()
    );

  const formatLatency = (ms) => {
    if (!Number.isFinite(ms) || ms <= 0) return '—';
    if (ms < 1000) return `${Math.round(ms)}ms`;
    const seconds = ms / 1000;
    if (seconds < 60) return `${seconds.toFixed(seconds >= 10 ? 0 : 1)}s`;
    const minutes = seconds / 60;
    return `${minutes.toFixed(minutes >= 10 ? 0 : 1)}m`;
  };

  const render = () => {
    if (tasksNode) {
      tasksNode.textContent = String(runningTaskIds.size);
    }

    if (successNode) {
      const total = completedCount + failedCount;
      successNode.textContent = total > 0
        ? `${Math.round((completedCount / total) * 100)}%`
        : '—';
    }

    if (latencyNode) {
      if (!recentDurationsMs.length) {
        latencyNode.textContent = '—';
      } else {
        const avg =
          recentDurationsMs.reduce((sum, value) => sum + value, 0) /
          recentDurationsMs.length;
        latencyNode.textContent = formatLatency(avg);
      }
    }
  };

  const ingestEvent = (eventName, payload) => {
    const taskId = getTaskId(payload);
    const eventType = getEventType(eventName, payload);
    const eventTs = getEventTs(payload);

    if (!taskId) {
      render();
      return;
    }

    if (runningTypes.has(eventType)) {
      runningTaskIds.add(taskId);
      if (!taskStartTimes.has(taskId)) {
        taskStartTimes.set(taskId, eventTs);
      }
    }

    if (terminalTypes.has(eventType)) {
      runningTaskIds.delete(taskId);

      const dedupeKey = `${taskId}|${eventType}|${eventTs}`;
      if (!seenTerminalEvents.has(dedupeKey)) {
        seenTerminalEvents.add(dedupeKey);

        if (terminalSuccessTypes.has(eventType)) completedCount += 1;
        if (terminalFailureTypes.has(eventType)) failedCount += 1;

        const startTs = taskStartTimes.get(taskId);
        if (Number.isFinite(startTs)) {
          const duration = Math.max(0, eventTs - startTs);
          recentDurationsMs.push(duration);
          if (recentDurationsMs.length > maxSamples) {
            recentDurationsMs.splice(0, recentDurationsMs.length - maxSamples);
          }
        }
      }

      taskStartTimes.delete(taskId);
    }

    render();
  };

  const ingestMessage = (raw, forcedEventName = null) => {
    const parsed = typeof raw === 'string' ? safeJsonParse(raw) : raw;
    if (!parsed) return;

    if (Array.isArray(parsed)) {
      parsed.forEach((item) => ingestEvent(forcedEventName, item));
      return;
    }

    const candidateLists = [
      parsed?.events,
      parsed?.payload?.events,
      parsed?.task_events,
      parsed?.items
    ];

    for (const list of candidateLists) {
      if (Array.isArray(list)) {
        list.forEach((item) => ingestEvent(forcedEventName, item));
        return;
      }
    }

    ingestEvent(
      forcedEventName ?? parsed?.event ?? parsed?.type ?? parsed?.status,
      parsed?.payload ?? parsed?.data ?? parsed
    );
  };

  const attachTypedListener = (es, eventName) => {
    es.addEventListener(eventName, (evt) => {
      const parsed = safeJsonParse(evt.data);
      if (parsed !== null) {
        ingestMessage({ event: eventName, payload: parsed }, eventName);
      } else {
        ingestMessage({ event: eventName, payload: { type: eventName } }, eventName);
      }
    });
  };

    const bootstrapFromTasks = async () => {
      try {
        const res = await fetch('/api/tasks?limit=200', {
          headers: { Accept: 'application/json' },
          cache: 'no-store'
        });

        if (!res.ok) {
          render();
          return;
        }

        const parsed = await res.json().catch(() => null);
        const rows = Array.isArray(parsed)
          ? parsed
          : Array.isArray(parsed?.tasks)
            ? parsed.tasks
            : Array.isArray(parsed?.rows)
              ? parsed.rows
              : [];

        rows.forEach((row) => {
          const taskId = getTaskId(row);
          const status = normalize(
            row?.status ??
            row?.task_status ??
            row?.state ??
            row?.payload?.status
          );

          if (!taskId || !status) return;

          if (runningTypes.has(status)) {
            runningTaskIds.add(taskId);
            if (!taskStartTimes.has(taskId)) {
              taskStartTimes.set(taskId, getEventTs(row));
            }
            return;
          }

          if (terminalSuccessTypes.has(status)) {
            completedCount += 1;
            return;
          }

          if (terminalFailureTypes.has(status)) {
            failedCount += 1;
          }
        });
      } catch {
        // fail closed to live SSE only
      }

      render();
    };

    const connect = () => {
      let es;
      try {
        es = new EventSource('/events/task-events');
      } catch {
        render();
        return;
      }

      es.onmessage = (evt) => ingestMessage(evt.data);

      [
        ...runningTypes,
        ...terminalSuccessTypes,
        ...terminalFailureTypes
      ].forEach((eventName) => attachTypedListener(es, eventName));

      es.onerror = () => render();
      window.addEventListener('beforeunload', () => es.close(), { once: true });
    };

    render();
    bootstrapFromTasks().finally(() => connect());
    window.setInterval(render, 10000);
})();
