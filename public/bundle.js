(() => {
  // public/js/dashboard-status.js
  function initDashboardStatus() {
    if (typeof window === "undefined" || typeof document === "undefined") return;
    if (window.__dashboardStatusInited) return;
    window.__dashboardStatusInited = true;
    const OPS_SSE_URL = `/events/ops`;
    const REFLECTIONS_SSE_URL = `/events/reflections`;
    const uptimeDisplay = document.getElementById("uptime-display");
    const healthIndicator = document.getElementById("system-health-indicator");
    const healthStatus = document.getElementById("health-status");
    const metricAgents = document.getElementById("metric-agents");
    const metricTasks = document.getElementById("metric-tasks");
    const metricSuccessRate = document.getElementById("metric-success-rate");
    const metricLatency = document.getElementById("metric-latency");
    const reflectionsContainer = document.getElementById("recentLogs");
    const opsAlertsList = document.getElementById("ops-alerts-list");
    const pageStart = Date.now();
    const agentStatusMap = {};
    let totalOpsEvents = 0;
    let successfulOpsEvents = 0;
    let errorOpsEvents = 0;
    function formatDuration(seconds) {
      const s = seconds % 60;
      const m = Math.floor(seconds / 60) % 60;
      const h = Math.floor(seconds / 3600);
      if (h > 0) return `${h}h ${m}m ${s}s`;
      if (m > 0) return `${m}m ${s}s`;
      return `${s}s`;
    }
    function tickUptime() {
      if (!uptimeDisplay) return;
      const diffSec = Math.floor((Date.now() - pageStart) / 1e3);
      uptimeDisplay.textContent = formatDuration(diffSec);
    }
    tickUptime();
    setInterval(tickUptime, 1e3);
    function classifyHealthFromStatus(statusString) {
      const s = (statusString || "").toLowerCase();
      if (!s) return "degraded";
      if (s.includes("error") || s.includes("failed") || s.includes("critical")) {
        return "critical";
      }
      if (s.includes("warn") || s.includes("degraded")) {
        return "degraded";
      }
      if (s.includes("ok") || s.includes("online") || s.includes("ready") || s.includes("healthy")) {
        return "healthy";
      }
      return "degraded";
    }
    function applyHealthVisual(healthState) {
      if (!healthIndicator || !healthStatus) return;
      healthIndicator.classList.remove("bg-red-500", "bg-yellow-400", "bg-green-400");
      healthIndicator.classList.remove("animate-pulse");
      switch (healthState) {
        case "healthy":
          healthIndicator.classList.add("bg-green-400");
          healthStatus.textContent = "Stable";
          break;
        case "critical":
          healthIndicator.classList.add("bg-red-500", "animate-pulse");
          healthStatus.textContent = "Critical";
          break;
        case "degraded":
        default:
          healthIndicator.classList.add("bg-yellow-400");
          healthStatus.textContent = "Degraded";
          break;
      }
    }
    applyHealthVisual("degraded");
    let opsSource;
    try {
      opsSource = new EventSource(OPS_SSE_URL);
    } catch (err) {
      console.error("dashboard-status.js: Failed to open OPS SSE connection:", err);
      return;
    }
    opsSource.onmessage = (event) => {
      let payloadRaw = event.data;
      let data = null;
      try {
        data = JSON.parse(payloadRaw);
      } catch {
        data = { message: payloadRaw };
      }
      totalOpsEvents++;
      const agentName = (data.agent || data.actor || data.source || data.worker || "").toString();
      const statusString = (data.status || data.state || data.level || "").toString();
      const message = data.message || data.event || data.description || data.type || payloadRaw;
      if (agentName) {
        agentStatusMap[agentName] = statusString || "unknown";
      }
      if (metricAgents) {
        const uniqueAgents = Object.keys(agentStatusMap).length;
        metricAgents.textContent = String(uniqueAgents || "--");
      }
      if (metricTasks) {
        metricTasks.textContent = String(totalOpsEvents);
      }
      if (metricLatency && typeof data.latency_ms === "number") {
        metricLatency.textContent = String(Math.round(data.latency_ms));
      }
      const statusLower = statusString.toLowerCase();
      if (statusLower.includes("success") || statusLower.includes("completed") || statusLower.includes("ok")) {
        successfulOpsEvents++;
      } else if (statusLower.includes("error") || statusLower.includes("failed")) {
        errorOpsEvents++;
      }
      if (metricSuccessRate) {
        const denom = successfulOpsEvents + errorOpsEvents;
        if (denom > 0) {
          const pct = Math.round(successfulOpsEvents / denom * 100);
          metricSuccessRate.textContent = `${pct}%`;
        } else {
          metricSuccessRate.textContent = "--";
        }
      }
      const healthState = classifyHealthFromStatus(statusString);
      applyHealthVisual(healthState);
      if (opsAlertsList) {
        const li = document.createElement("li");
        li.className = "text-sm";
        const now = /* @__PURE__ */ new Date();
        const ts = now.toLocaleTimeString([], {
          hour: "2-digit",
          minute: "2-digit",
          second: "2-digit"
        });
        const safeAgent = agentName || "System";
        const labelParts = [`[${ts}]`, safeAgent];
        if (statusString) labelParts.push(`\u2013 ${statusString}`);
        if (message && message !== statusString) {
          labelParts.push(`\u2013 ${String(message).slice(0, 160)}`);
        }
        li.textContent = labelParts.join(" ");
        opsAlertsList.prepend(li);
        while (opsAlertsList.children.length > 50) {
          opsAlertsList.removeChild(opsAlertsList.lastChild);
        }
      }
    };
    opsSource.onerror = (err) => {
      console.warn("dashboard-status.js: OPS SSE error:", err);
      applyHealthVisual("degraded");
      if (opsAlertsList) {
        const li = document.createElement("li");
        li.className = "text-sm text-red-400";
        li.textContent = "[OPS] SSE connection error \u2013 attempting to recover\u2026";
        opsAlertsList.prepend(li);
        while (opsAlertsList.children.length > 50) {
          opsAlertsList.removeChild(opsAlertsList.lastChild);
        }
      }
    };
    let reflectionsSource;
    try {
      console.log("[dashboard-status] opening Reflections SSE:", REFLECTIONS_SSE_URL);
      reflectionsSource = new EventSource(REFLECTIONS_SSE_URL);
    } catch (err) {
      console.error("dashboard-status.js: Failed to open Reflections SSE connection:", err);
      return;
    }
    reflectionsSource.onmessage = (event) => {
      console.log("[dashboard-status] reflections onmessage:", event.data);
      if (!reflectionsContainer) return;
      const raw = event.data;
      let text = raw;
      try {
        const parsed = JSON.parse(raw);
        text = parsed.message || parsed.reflection || parsed.text || parsed.log || raw;
      } catch {
      }
      const entry = document.createElement("div");
      entry.className = "text-sm text-gray-200 border-b border-gray-700 pb-2 mb-2 whitespace-pre-line";
      entry.textContent = text;
      reflectionsContainer.prepend(entry);
      while (reflectionsContainer.children.length > 50) {
        reflectionsContainer.removeChild(reflectionsContainer.lastChild);
      }
    };
    reflectionsSource.onerror = (err) => {
      console.warn("dashboard-status.js: Reflections SSE error:", err);
      if (!reflectionsContainer) return;
      const entry = document.createElement("div");
      entry.className = "text-xs text-red-400 italic";
      entry.textContent = "[Reflections] SSE connection error \u2013 check Python reflections_stream on port 3200.";
      reflectionsContainer.prepend(entry);
      while (reflectionsContainer.children.length > 50) {
        reflectionsContainer.removeChild(reflectionsContainer.lastChild);
      }
    };
  }
  if (typeof window !== "undefined") {
    window.initDashboardStatus = initDashboardStatus;
    if (typeof window !== "undefined" && typeof document !== "undefined") {
      if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", () => initDashboardStatus());
      } else {
        initDashboardStatus();
      }
    }
  }

  // public/js/agent-status-row.js
  (() => {
    const container = document.getElementById("agent-status-container");
    if (!container) {
      console.warn("agent-status-row.js: #agent-status-container not found.");
      return;
    }
    container.innerHTML = "";
    const AGENTS = ["Matilda", "Cade", "Effie", "Atlas"];
    const indicators = {};
    const row = document.createElement("div");
    row.className = "flex flex-wrap gap-4 items-center";
    container.appendChild(row);
    AGENTS.forEach((name) => {
      const pill = document.createElement("div");
      pill.className = "px-3 py-1 rounded-full bg-gray-700 text-sm flex items-center gap-2 shadow";
      const dot = document.createElement("span");
      dot.className = "w-2 h-2 rounded-full bg-yellow-400";
      const label = document.createElement("span");
      label.textContent = `${name}: \u23F3`;
      pill.dataset.agent = name.toLowerCase();
      pill.append(dot, label);
      row.appendChild(pill);
      indicators[name.toLowerCase()] = { pill, dot, label };
    });
    const OPS_SSE_URL = `/events/ops`;
    let source;
    try {
      source = new EventSource(OPS_SSE_URL);
    } catch (err) {
      console.error("agent-status-row.js: Failed to open OPS SSE connection:", err);
      return;
    }
    function classifyStatus(statusString) {
      const s = (statusString || "").toLowerCase();
      if (!s) return "unknown";
      if (s.includes("error") || s.includes("failed") || s.includes("offline")) {
        return "error";
      }
      if (s.includes("online") || s.includes("ready") || s.includes("ok")) {
        return "online";
      }
      if (s.includes("queued") || s.includes("pending") || s.includes("init")) {
        return "pending";
      }
      return "unknown";
    }
    function applyVisual(agentKey, statusString) {
      const indicator = indicators[agentKey];
      if (!indicator) return;
      const kind = classifyStatus(statusString);
      const { pill, dot, label } = indicator;
      dot.className = "w-2 h-2 rounded-full";
      pill.classList.remove("border", "border-red-400", "border-green-400", "border-yellow-300");
      switch (kind) {
        case "online":
          dot.classList.add("bg-green-400");
          pill.classList.add("border", "border-green-400");
          break;
        case "error":
          dot.classList.add("bg-red-400");
          pill.classList.add("border", "border-red-400");
          break;
        case "pending":
          dot.classList.add("bg-yellow-300");
          pill.classList.add("border", "border-yellow-300");
          break;
        case "unknown":
        default:
          dot.classList.add("bg-gray-500");
          break;
      }
      const prettyName = agentKey.charAt(0).toUpperCase() + agentKey.slice(1);
      const finalStatus = statusString || "unknown";
      label.textContent = `${prettyName}: ${finalStatus}`;
    }
    source.onmessage = (event) => {
      let payloadRaw = event.data;
      let data;
      try {
        data = JSON.parse(payloadRaw);
      } catch {
        return;
      }
      const agentName = (data.agent || data.actor || data.source || data.worker || "").toString();
      if (!agentName) return;
      const key = agentName.toLowerCase();
      if (!indicators[key]) {
        return;
      }
      const status = (data.status || data.state || data.level || "").toString() || "unknown";
      applyVisual(key, status);
    };
    source.onerror = (err) => {
      console.warn("agent-status-row.js: OPS SSE error:", err);
      Object.keys(indicators).forEach((key) => applyVisual(key, "unknown"));
    };
  })();

  // public/js/dashboard-broadcast.js
  var BROADCAST_GUARD_KEY = "__broadcastVisualizationInited";
  var nodes = ["Matilda", "Cade", "Effie"];
  function renderBroadcastNodes() {
    const container = document.getElementById("broadcast-visual");
    if (!container) return;
    const parts = [];
    for (let i = 0; i < nodes.length; i++) {
      const n = nodes[i];
      parts.push('<div class="node" id="node-' + n + '">' + n + "</div>");
      if (i < nodes.length - 1) {
        parts.push('<div class="arrow">\u279C</div>');
      }
    }
    container.innerHTML = parts.join("");
  }
  function startBroadcastCycle() {
    let idx = 0;
    setInterval(() => {
      const allNodes = document.querySelectorAll(".node");
      allNodes.forEach((n) => n.classList.remove("active"));
      const activeId = "node-" + nodes[idx];
      const active = document.getElementById(activeId);
      if (active) active.classList.add("active");
      idx = (idx + 1) % nodes.length;
    }, 1500);
  }
  function initBroadcastVisualization() {
    if (typeof window === "undefined" || typeof document === "undefined") {
      return;
    }
    if (window[BROADCAST_GUARD_KEY]) {
      return;
    }
    window[BROADCAST_GUARD_KEY] = true;
    const run = () => {
      renderBroadcastNodes();
      startBroadcastCycle();
    };
    if (document.readyState === "loading") {
      window.addEventListener("DOMContentLoaded", run);
    } else {
      run();
    }
  }
  if (typeof window !== "undefined") {
    window.initBroadcastVisualization = initBroadcastVisualization;
  }

  // public/js/ops-status-widget.js
  (function() {
    if (typeof document === "undefined") return;
    var existing = document.getElementById("ops-dashboard-pill");
    if (existing) return;
    var pill = document.querySelector("[data-ops-pill]");
    if (!pill) return;
    pill.id = "ops-dashboard-pill";
  })();

  // public/js/ops-globals-bridge.js
  (() => {
    if (typeof window === "undefined" || typeof EventSource === "undefined") return;
    if (window.__opsGlobalsBridgeInitialized) return;
    window.__opsGlobalsBridgeInitialized = true;
    if (typeof window.lastOpsHeartbeat === "undefined") {
      window.lastOpsHeartbeat = null;
    }
    if (typeof window.lastOpsStatusSnapshot === "undefined") {
      window.lastOpsStatusSnapshot = null;
    }
    const opsUrl = `/events/ops`;
    const handleEvent = (event) => {
      try {
        const data = JSON.parse(event.data || "null");
        if (!data) return;
        window.lastOpsHeartbeat = Math.floor(Date.now() / 1e3);
        window.lastOpsStatusSnapshot = data;
      } catch (err) {
        console.warn("[ops-globals-bridge] Failed to parse OPS event:", err);
      }
    };
    try {
      const es = new EventSource(opsUrl);
      es.onmessage = handleEvent;
      es.addEventListener("hello", handleEvent);
      es.onerror = (err) => {
        console.warn("[ops-globals-bridge] EventSource error:", err);
      };
    } catch (err) {
      console.warn("[ops-globals-bridge] Failed to init EventSource:", err);
    }
  })();

  // public/js/ops-pill-state.js
  (function() {
    if (typeof window === "undefined" || typeof document === "undefined") return;
    if (window.location.pathname !== "/dashboard") return;
    var POLL_INTERVAL_MS = 5e3;
    var PILL_ID = "ops-dashboard-pill";
    function ensurePill() {
      var pill = document.getElementById(PILL_ID);
      if (pill) return pill;
      pill = document.createElement("span");
      pill.id = PILL_ID;
      pill.className = "ops-pill ops-pill-unknown";
      pill.textContent = "OPS: Unknown";
      pill.style.display = "inline-block";
      if (document.body.firstChild) {
        document.body.insertBefore(pill, document.body.firstChild);
      } else {
        document.body.appendChild(pill);
      }
      return pill;
    }
    function applyState() {
      var overlay = document.getElementById("ops-status-pill");
      if (overlay) {
        overlay.style.display = "none";
      }
      var pill = ensurePill();
      if (!pill) return;
      var hasHeartbeat = typeof window.lastOpsHeartbeat === "number";
      var label = hasHeartbeat ? "OPS: Online" : "OPS: Unknown";
      var cls = hasHeartbeat ? "ops-pill-online" : "ops-pill-unknown";
      pill.classList.remove(
        "ops-pill-unknown",
        "ops-pill-online",
        "ops-pill-stale",
        "ops-pill-error"
      );
      pill.classList.add(cls);
      pill.textContent = label;
    }
    applyState();
    setInterval(applyState, POLL_INTERVAL_MS);
  })();

  // public/js/dashboard-tasks-widget.js
  (function() {
    if (typeof window === "undefined" || typeof document === "undefined") return;
    if (window.__dashboardTasksWidgetInited) return;
    window.__dashboardTasksWidgetInited = true;
    const TASKS_SSE_URL = "/events/tasks";
    const MAX_ITEMS = 8;
    const STALE_MS = 15e3;
    const STALE_TICK_MS = 5e3;
    function el(id) {
      return document.getElementById(id);
    }
    function ensureContainer() {
      const delegationCard = el("delegation-card");
      if (!delegationCard) return null;
      let box = el("recent-tasks-box");
      if (box) return box;
      box = document.createElement("div");
      box.id = "recent-tasks-box";
      box.className = "mt-3 bg-gray-900 border border-gray-700 rounded-lg p-3";
      const title = document.createElement("div");
      title.className = "text-xs uppercase tracking-wide text-gray-400 mb-2";
      title.textContent = "Recent Tasks";
      const list = document.createElement("div");
      list.id = "recent-tasks-list";
      list.className = "space-y-2";
      const hint = document.createElement("div");
      hint.id = "recent-tasks-hint";
      hint.className = "text-xs text-gray-500 italic";
      hint.textContent = "Loading tasks\u2026";
      box.appendChild(title);
      box.appendChild(list);
      box.appendChild(hint);
      const anchor = el("delegation-response");
      if (anchor && anchor.parentNode === delegationCard) {
        anchor.insertAdjacentElement("afterend", box);
      } else {
        delegationCard.appendChild(box);
      }
      return box;
    }
    function selfHealHintContainer() {
      const __hint = el("recent-tasks-hint");
      let __container = el("recent-tasks-container");
      let __list = el("recent-tasks-list");
      if (__hint && (!__container || !__list)) {
        const __mount = __hint.parentElement;
        if (!__container) {
          __container = document.createElement("div");
          __container.id = "recent-tasks-container";
          __container.appendChild(__hint);
          __mount.appendChild(__container);
        } else if (__hint.parentElement !== __container) {
          __container.appendChild(__hint);
        }
        if (!__list) {
          __list = document.createElement("div");
          __list.id = "recent-tasks-list";
          __container.appendChild(__list);
        }
      }
    }
    function setHint(text) {
      const hint = el("recent-tasks-hint");
      if (!hint) return;
      hint.style.display = "block";
      hint.textContent = text;
    }
    function clearHint() {
      const hint = el("recent-tasks-hint");
      if (!hint) return;
      hint.style.display = "none";
      hint.textContent = "";
    }
    function fmtTime(s) {
      if (!s) return "";
      const d = new Date(String(s));
      if (isNaN(d.getTime())) return "";
      return d.toLocaleString();
    }
    function dedupeTasks(tasks) {
      const safe = Array.isArray(tasks) ? tasks : [];
      const seen = /* @__PURE__ */ new Set();
      const out = [];
      for (const t of safe) {
        const id = t && t.id != null ? String(t.id) : "";
        const key = id || JSON.stringify(t || {});
        if (seen.has(key)) continue;
        seen.add(key);
        out.push(t);
      }
      return out;
    }
    function renderTasks(tasks) {
      const box = ensureContainer();
      selfHealHintContainer();
      if (!box) return;
      const list = el("recent-tasks-list");
      if (!list) return;
      const items = dedupeTasks(tasks).slice(0, MAX_ITEMS);
      list.innerHTML = "";
      if (!items.length) {
        setHint("No recent tasks yet.");
        return;
      }
      clearHint();
      items.forEach((t) => {
        const row = document.createElement("div");
        row.className = "flex items-start justify-between gap-3 text-sm";
        const left = document.createElement("div");
        left.className = "min-w-0 flex-1";
        const title = document.createElement("div");
        title.className = "text-gray-200 truncate";
        title.textContent = t && (t.title || t.task || t.name) ? String(t.title || t.task || t.name) : "(untitled)";
        const sub = document.createElement("div");
        sub.className = "text-xs text-gray-500 mt-0.5 truncate";
        const created = fmtTime(t && (t.created_at || t.createdAt));
        const updated = fmtTime(t && (t.updated_at || t.updatedAt));
        const when = updated || created;
        sub.textContent = when ? `Updated: ${when}` : "";
        left.appendChild(title);
        if (sub.textContent) left.appendChild(sub);
        const right = document.createElement("div");
        right.className = "text-xs text-gray-400 flex items-center gap-2 shrink-0";
        const agent = t && t.agent ? String(t.agent) : "\u2014";
        const status = t && t.status ? String(t.status) : "unknown";
        const pill = document.createElement("span");
        pill.className = "px-2 py-0.5 rounded-full bg-gray-800 border border-gray-700";
        pill.textContent = status;
        const meta = document.createElement("span");
        meta.textContent = agent;
        right.appendChild(pill);
        right.appendChild(meta);
        row.appendChild(left);
        row.appendChild(right);
        list.appendChild(row);
      });
    }
    function start() {
      ensureContainer();
      selfHealHintContainer();
      setHint("Loading tasks\u2026");
      try {
        if (window.__dashboardTasksWidgetES && typeof window.__dashboardTasksWidgetES.close === "function") {
          window.__dashboardTasksWidgetES.close();
        }
      } catch (e) {
      }
      let es;
      try {
        es = new EventSource(TASKS_SSE_URL);
        window.__dashboardTasksWidgetES = es;
      } catch (err) {
        console.warn("[tasks-widget] Failed to open SSE:", err);
        setHint("Tasks stream unavailable \u2014 check /events/tasks.");
        return;
      }
      window.__dashboardTasksWidgetLastEventAt = Date.now();
      window.__dashboardTasksWidgetDisconnected = false;
      es.onmessage = (event) => {
        window.__dashboardTasksWidgetLastEventAt = Date.now();
        window.__dashboardTasksWidgetDisconnected = false;
        let data;
        try {
          data = JSON.parse(event.data || "null");
        } catch {
          return;
        }
        if (!data) return;
        const tasks = data.tasks || data.items || [];
        window.__latestTasksSnapshot = data;
        renderTasks(tasks);
      };
      es.onerror = () => {
        window.__dashboardTasksWidgetDisconnected = true;
        setHint("Tasks stream disconnected \u2014 check /events/tasks.");
      };
      if (!window.__dashboardTasksWidgetStaleTimer) {
        window.__dashboardTasksWidgetStaleTimer = setInterval(() => {
          const last = window.__dashboardTasksWidgetLastEventAt || 0;
          const disconnected = !!window.__dashboardTasksWidgetDisconnected;
          if (disconnected) return;
          if (!last) return;
          const age = Date.now() - last;
          if (age > STALE_MS) {
            setHint("Tasks stream quiet (stale) \u2014 waiting for updates\u2026");
          }
        }, STALE_TICK_MS);
      }
    }
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", start);
    } else {
      start();
    }
  })();

  // public/js/matilda-chat-console.js
  (function() {
    function log(msg) {
      console.log("[matilda-chat]", msg);
    }
    function appendMessage(transcriptEl, sender, text) {
      if (!transcriptEl) return;
      var line = document.createElement("p");
      line.className = "mb-1 text-sm";
      var label = sender ? sender + ": " : "";
      line.textContent = label + text;
      transcriptEl.appendChild(line);
      transcriptEl.scrollTop = transcriptEl.scrollHeight;
    }
    function setSendingState(sendBtn, input, isSending) {
      if (sendBtn) {
        sendBtn.disabled = isSending;
        sendBtn.classList.toggle("opacity-60", isSending);
        sendBtn.textContent = isSending ? "Sending..." : "Send";
      }
      if (input) {
        input.disabled = isSending;
      }
    }
    async function wireChat() {
      var root = document.getElementById("matilda-chat-root");
      if (!root) {
        log("No #matilda-chat-root found; skipping wiring.");
        return;
      }
      var transcript = document.getElementById("matilda-chat-transcript");
      var input = document.getElementById("matilda-chat-input");
      var sendBtn = document.getElementById("matilda-chat-send");
      if (!transcript || !input || !sendBtn) {
        log("Missing one or more Matilda chat elements; aborting wiring.");
        return;
      }
      function safeTrim(value) {
        return (value || "").toString().trim();
      }
      async function handleSend() {
        var message = safeTrim(input.value);
        if (!message) return;
        appendMessage(transcript, "You", message);
        input.value = "";
        setSendingState(sendBtn, input, true);
        try {
          var res = await fetch("/api/chat", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ message, agent: "matilda" })
          });
          if (!res.ok) {
            appendMessage(
              transcript,
              "Matilda",
              "(error talking to /api/chat)"
            );
            return;
          }
          var data = await res.json();
          var reply = data && (data.reply || data.message || data.response) || "(no reply)";
          appendMessage(transcript, "Matilda", reply);
        } catch (err) {
          console.error(err);
          appendMessage(transcript, "Matilda", "(network error)");
        } finally {
          setSendingState(sendBtn, input, false);
        }
      }
      sendBtn.addEventListener("click", handleSend);
      var quickBtn = document.getElementById("matilda-chat-quick-check");
      if (quickBtn) {
        quickBtn.addEventListener("click", function() {
          input.value = "Quick systems check from dashboard Phase 11.4.";
          handleSend();
        });
      }
      input.addEventListener("keydown", function(e) {
        if (e.key === "Enter" && !e.shiftKey) {
          e.preventDefault();
          handleSend();
        }
      });
      log("Matilda chat wiring complete.");
    }
    document.addEventListener("DOMContentLoaded", wireChat);
  })();
})();
//# sourceMappingURL=bundle.js.map
