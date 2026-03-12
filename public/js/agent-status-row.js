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

  function classifyStatus(statusString) {
    if (
      typeof window !== "undefined" &&
      window.__PHASE16_SSE_OWNER_STARTED
    ) {
      return "unknown";
    }

    const s = (statusString || "").toLowerCase();
    if (!s) return "unknown";
    if (s.includes("error") || s.includes("failed") || s.includes("offline")) return "error";
    if (s.includes("online") || s.includes("ready") || s.includes("ok")) return "online";
    if (s.includes("queued") || s.includes("pending") || s.includes("init") || s.includes("running")) return "pending";
    return "unknown";
  }

  function applyVisual(agentKey, statusString) {
    const indicator = indicators[agentKey];
    if (!indicator) return;

    const kind = classifyStatus(statusString);
    const finalStatus = statusString || "unknown";
    indicator.status.textContent = finalStatus;

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
      case "online":
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-emerald-300/90");
        break;
      case "error":
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-rose-300/90");
        break;
      case "pending":
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
;/* PHASE62B_TASKS_RUNNING_HYDRATION */
(() => {
  if (typeof window === 'undefined') return;
  if (window.__PHASE62B_TASKS_RUNNING_HYDRATION__) return;
  window.__PHASE62B_TASKS_RUNNING_HYDRATION__ = true;

  const runningTaskIds = new Set();
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
  const terminalTypes = new Set([
    'completed',
    'failed',
    'cancelled',
    'canceled',
    'timed_out',
    'timeout',
    'terminated',
    'aborted'
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

  const metricValueSelectors = [
    '[data-metric-value]',
    '[data-value]',
    '.metric-value',
    '.telemetry-value',
    '.stat-value',
    '.value'
  ].join(',');

  const containerSelectors = [
    '.metric-card',
    '.telemetry-tile',
    '.metric-tile',
    '.metrics-tile',
    '[data-metric-label]',
    '[data-metric-key]',
    '.metrics-row > *',
    '.metrics-row .card',
    '.metrics-row .tile'
  ].join(',');

  const findTasksRunningValueNode = () => {
    const containers = Array.from(document.querySelectorAll(containerSelectors));

    for (const el of containers) {
      const labelSource = [
        el.getAttribute?.('data-metric-label') || '',
        el.getAttribute?.('data-metric-key') || '',
        el.textContent || ''
      ].join(' ').toLowerCase();

      if (!labelSource.includes('tasks running')) continue;

      const explicitValue = el.querySelector?.(metricValueSelectors);
      if (explicitValue) return explicitValue;
      return el;
    }

    const textNodes = Array.from(document.querySelectorAll('div,span,p,strong,h2,h3,h4'));
    for (const node of textNodes) {
      if ((node.textContent || '').trim().toLowerCase() !== 'tasks running') continue;

      const valueNode =
        node.parentElement?.querySelector?.(metricValueSelectors) ||
        node.nextElementSibling ||
        node.parentElement;

      if (valueNode) return valueNode;
    }

    return null;
  };

  const render = () => {
    const node = findTasksRunningValueNode();
    if (!node) return;
    node.textContent = String(runningTaskIds.size);
  };

  const ingestEvent = (eventName, payload) => {
    const taskId = getTaskId(payload);
    const eventType = getEventType(eventName, payload);

    if (!taskId) {
      render();
      return;
    }

    if (terminalTypes.has(eventType)) {
      runningTaskIds.delete(taskId);
      render();
      return;
    }

    if (runningTypes.has(eventType)) {
      runningTaskIds.add(taskId);
      render();
      return;
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
      'created',
      'queued',
      'leased',
      'started',
      'running',
      'in_progress',
      'delegated',
      'retrying',
      'completed',
      'failed',
      'cancelled',
      'canceled',
      'timed_out',
      'timeout',
      'terminated',
      'aborted'
    ].forEach((eventName) => attachTypedListener(es, eventName));

    es.onerror = () => render();
    window.addEventListener('beforeunload', () => es.close(), { once: true });
  };

  render();
  connect();
  window.setInterval(render, 10000);
})();
