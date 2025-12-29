(() => {
  // public/js/sse-heartbeat-shim.js
  (function() {
    const w = window;
    const STORE_KEY = "__HB";
    if (!w[STORE_KEY]) {
      const state = { ops: null, tasks: null, reflections: null, unknown: null };
      w[STORE_KEY] = {
        record(kind, ts) {
          const k = Object.prototype.hasOwnProperty.call(state, kind) ? kind : "unknown";
          state[k] = typeof ts === "number" ? ts : Date.now();
          return state[k];
        },
        get(kind) {
          const k = Object.prototype.hasOwnProperty.call(state, kind) ? kind : "unknown";
          return state[k];
        },
        snapshot() {
          return { ...state };
        }
      };
    }
    const NativeEventSource = w.EventSource;
    if (!NativeEventSource || NativeEventSource.__hbWrapped) return;
    function classify(url) {
      const u = String(url || "");
      if (u.includes("/events/ops")) return "ops";
      if (u.includes("/events/tasks")) return "tasks";
      if (u.includes("/events/reflections")) return "reflections";
      return "unknown";
    }
    function HeartbeatEventSource(url, eventSourceInitDict) {
      const kind = classify(url);
      try {
        w[STORE_KEY].record(kind, Date.now());
      } catch (_) {
      }
      const es = new NativeEventSource(url, eventSourceInitDict);
      const update = () => {
        try {
          w[STORE_KEY].record(kind, Date.now());
        } catch (_) {
        }
      };
      try {
        es.addEventListener("open", update);
      } catch (_) {
      }
      try {
        es.addEventListener("message", update);
      } catch (_) {
      }
      let _onmessage = null;
      Object.defineProperty(es, "onmessage", {
        get() {
          return _onmessage;
        },
        set(fn) {
          _onmessage = function(ev) {
            update();
            if (typeof fn === "function") return fn.call(es, ev);
          };
        },
        configurable: true
      });
      try {
        es.addEventListener("error", update);
      } catch (_) {
      }
      return es;
    }
    HeartbeatEventSource.prototype = NativeEventSource.prototype;
    HeartbeatEventSource.__hbWrapped = true;
    w.EventSource = HeartbeatEventSource;
  })();

  // public/js/heartbeat-stale-indicator.js
  (function() {
    const w = window;
    const HB = w.__HB;
    function now() {
      return Date.now();
    }
    function ms(n) {
      return Math.max(0, Number(n) || 0);
    }
    const STALE_MS = 15e3;
    function fmtAge(ts) {
      if (!ts) return "\u2014";
      const s = Math.floor((now() - ts) / 1e3);
      return s <= 0 ? "0s" : `${s}s`;
    }
    function ensureBadge() {
      let el = document.getElementById("hb-badge");
      if (el) return el;
      el = document.createElement("div");
      el.id = "hb-badge";
      el.setAttribute("role", "status");
      el.style.position = "fixed";
      el.style.top = "12px";
      el.style.right = "12px";
      el.style.zIndex = "9999";
      el.style.fontFamily = "ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial";
      el.style.fontSize = "12px";
      el.style.padding = "6px 10px";
      el.style.borderRadius = "999px";
      el.style.border = "1px solid rgba(255,255,255,0.14)";
      el.style.background = "rgba(0,0,0,0.55)";
      el.style.backdropFilter = "blur(6px)";
      el.style.webkitBackdropFilter = "blur(6px)";
      el.style.color = "rgba(255,255,255,0.92)";
      el.style.boxShadow = "0 8px 18px rgba(0,0,0,0.35)";
      el.style.userSelect = "none";
      el.style.cursor = "default";
      document.body.appendChild(el);
      return el;
    }
    function setState(el, ok) {
      el.textContent = ok ? `HB \u2713 (ops ${fmtAge(HB && HB.get("ops"))}, tasks ${fmtAge(HB && HB.get("tasks"))})` : `HB ! (ops ${fmtAge(HB && HB.get("ops"))}, tasks ${fmtAge(HB && HB.get("tasks"))})`;
    }
    function tick() {
      const el = ensureBadge();
      if (!HB || typeof HB.get !== "function") {
        el.textContent = "HB ? (shim not loaded)";
        return;
      }
      const ops = HB.get("ops");
      const tasks = HB.get("tasks");
      const opsOk = !!ops && ms(now() - ops) <= STALE_MS;
      const tasksOk = !!tasks && ms(now() - tasks) <= STALE_MS;
      setState(el, opsOk && tasksOk);
    }
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", () => {
        tick();
        setInterval(tick, 1e3);
      });
    } else {
      tick();
      setInterval(tick, 1e3);
    }
  })();

  // public/js/dashboard-status.js
  (() => {
    "use strict";
    const OPS_SSE_URL = "/events/ops";
    const REFLECTIONS_SSE_URL = "/events/reflections";
    const NOW = () => Date.now();
    function safeJsonParse(s) {
      try {
        return JSON.parse(s);
      } catch {
        return null;
      }
    }
    function formatAge(ms) {
      if (!Number.isFinite(ms)) return "\u2014";
      const s = Math.floor(ms / 1e3);
      if (s < 60) return `${s}s`;
      const m = Math.floor(s / 60);
      if (m < 60) return `${m}m`;
      return `${Math.floor(m / 60)}h`;
    }
    function el(tag, attrs = {}, text = "") {
      const n = document.createElement(tag);
      for (const [k, v] of Object.entries(attrs)) {
        if (k === "class") n.className = v;
        else if (k === "style") n.setAttribute("style", v);
        else n.setAttribute(k, v);
      }
      if (text) n.textContent = text;
      return n;
    }
    function ensureStyles() {
      if (document.getElementById("phase16-sse-style")) return;
      const s = el("style", { id: "phase16-sse-style" });
      s.textContent = `
      .sse-indicator {
        display:inline-flex;
        align-items:center;
        gap:6px;
        font-size:11px;
        line-height:1;
        opacity:.85;
        user-select:none;
        white-space:nowrap;
      }
      .sse-indicator .dot {
        width:7px; height:7px; border-radius:999px;
        background:#555;
        box-shadow:0 0 0 1px rgba(255,255,255,.08) inset;
      }
      .sse-indicator[data-connected="true"] .dot { background:#2dd4bf; }
      .sse-indicator[data-connected="false"] .dot { background:#f97316; }
      .sse-indicator .meta { font-variant-numeric: tabular-nums; }
    `;
      document.head.appendChild(s);
    }
    function mount(anchor, id, label) {
      ensureStyles();
      if (!anchor) {
        let tray = document.getElementById("phase16-sse-tray");
        if (!tray) {
          tray = el("div", {
            id: "phase16-sse-tray",
            style: [
              "position:fixed",
              "left:10px",
              "bottom:10px",
              "display:flex",
              "flex-direction:column",
              "gap:6px",
              "z-index:9999",
              "pointer-events:none"
            ].join(";")
          });
          document.body.appendChild(tray);
        }
        anchor = tray;
      }
      let node = document.getElementById(id);
      if (node) return node;
      node = el("span", { id, class: "sse-indicator", "data-connected": "false" });
      node.append(
        el("span", { class: "dot", "aria-hidden": "true" }),
        el("span", { class: "meta" }, `${label}: disconnected \xB7 last: \u2014`)
      );
      try {
        if (anchor.matches && anchor.matches("header,h1,h2,h3,h4,strong")) {
          const wrap = el("span", { style: "margin-left:8px" });
          wrap.appendChild(node);
          anchor.appendChild(wrap);
        } else {
          const wrap = el("div", { style: "margin-top:4px" });
          wrap.appendChild(node);
          anchor.appendChild(wrap);
        }
      } catch {
        anchor.appendChild(node);
      }
      return node;
    }
    function set(ind, label, connected, lastAt) {
      if (!ind) return;
      ind.dataset.connected = connected ? "true" : "false";
      const meta = ind.querySelector(".meta");
      if (!meta) return;
      meta.textContent = `${label}: ${connected ? "connected" : "disconnected"} \xB7 last: ${lastAt ? formatAge(NOW() - lastAt) : "\u2014"}`;
    }
    function ensureGlobal() {
      window.__MB_STREAMS ||= {
        ops: { connected: false, lastAt: 0, state: {}, es: null },
        reflections: { connected: false, lastAt: 0, state: {}, es: null }
      };
      return window.__MB_STREAMS;
    }
    function shallowMerge(target, patch) {
      if (!target || typeof target !== "object") target = {};
      if (!patch || typeof patch !== "object") return target;
      return Object.assign(target, patch);
    }
    function applyDotPathPatch(state, patch) {
      if (!state || typeof state !== "object") state = {};
      const path = patch && typeof patch.path === "string" ? patch.path : "";
      if (!path) return state;
      const parts = path.split(".").filter(Boolean);
      if (!parts.length) return state;
      let cur = state;
      for (let i = 0; i < parts.length - 1; i++) {
        const k = parts[i];
        if (!cur[k] || typeof cur[k] !== "object") cur[k] = {};
        cur = cur[k];
      }
      cur[parts[parts.length - 1]] = patch.value;
      return state;
    }
    function isStateEvent(evtType, parsed) {
      if (typeof evtType === "string" && evtType.endsWith(".state")) return true;
      if (parsed && typeof parsed === "object") {
        if (parsed.state && typeof parsed.state === "object") return true;
        if (typeof parsed.type === "string" && parsed.type.includes("state")) return true;
        if (typeof parsed.event === "string" && parsed.event.includes("state")) return true;
      }
      return false;
    }
    function extractPayload(parsed) {
      if (!parsed || typeof parsed !== "object") return parsed;
      if (parsed.payload !== void 0) return parsed.payload;
      if (parsed.data !== void 0) return parsed.data;
      if (parsed.delta !== void 0) return parsed.delta;
      if (parsed.patch !== void 0) return parsed.patch;
      if (parsed.state !== void 0) return parsed.state;
      return parsed;
    }
    function connect(key, label, url, ind) {
      const g = ensureGlobal();
      try {
        g[key].es && g[key].es.close();
      } catch {
      }
      g[key].es = null;
      const es = new EventSource(url);
      g[key].es = es;
      const tick = () => set(ind, label, g[key].connected, g[key].lastAt);
      es.onopen = () => {
        g[key].connected = true;
        tick();
      };
      es.onerror = () => {
        g[key].connected = false;
        tick();
      };
      const handle = (evtType, e) => {
        g[key].lastAt = NOW();
        const parsed = safeJsonParse(e && e.data ? e.data : "");
        const payload = extractPayload(parsed);
        if (isStateEvent(evtType, parsed)) {
          g[key].state = payload && typeof payload === "object" ? payload : { value: payload };
        } else {
          if (payload && typeof payload === "object") {
            if (typeof payload.path === "string" && "value" in payload) {
              g[key].state = applyDotPathPatch(g[key].state, payload);
            } else {
              g[key].state = shallowMerge(g[key].state, payload);
            }
          } else if (payload !== null && payload !== void 0) {
            g[key].state = shallowMerge(g[key].state, { lastValue: payload });
          }
        }
        tick();
        try {
          window.dispatchEvent(new CustomEvent(`mb:${key}:update`, {
            detail: { event: evtType, state: g[key].state, raw: parsed }
          }));
        } catch {
        }
      };
      es.onmessage = (e) => handle("message", e);
      const eventNames = [
        "hello",
        `${key}.state`,
        `${key}.update`,
        `${key}.patch`,
        `${key}.delta`,
        "state",
        "update",
        "patch",
        "delta"
      ];
      for (const name of eventNames) {
        try {
          es.addEventListener(name, (e) => handle(name, e));
        } catch {
        }
      }
      tick();
    }
    function findOpsAnchor() {
      return document.getElementById("ops-pill") || document.querySelector("[data-widget='ops-pill']") || document.querySelector(".ops-pill") || document.querySelector("#ops") || null;
    }
    function findReflectionsAnchor() {
      return document.getElementById("reflections-header") || document.getElementById("reflections") || document.querySelector("[data-panel='reflections']") || document.querySelector(".reflections") || (() => {
        const heads = Array.from(document.querySelectorAll("h1,h2,h3,h4,header,strong"));
        return heads.find((h) => (h.textContent || "").toLowerCase().includes("reflections")) || null;
      })();
    }
    function boot() {
      const opsInd = mount(findOpsAnchor(), "ops-sse-indicator", "OPS SSE");
      const refInd = mount(findReflectionsAnchor(), "reflections-sse-indicator", "Reflections SSE");
      connect("ops", "OPS SSE", OPS_SSE_URL, opsInd);
      connect("reflections", "Reflections SSE", REFLECTIONS_SSE_URL, refInd);
      setInterval(() => {
        const g = ensureGlobal();
        set(opsInd, "OPS SSE", g.ops.connected, g.ops.lastAt);
        set(refInd, "Reflections SSE", g.reflections.connected, g.reflections.lastAt);
      }, 1e3);
    }
    document.readyState === "loading" ? document.addEventListener("DOMContentLoaded", boot, { once: true }) : boot();
  })();

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
    const __DISABLE_OPTIONAL_SSE = (typeof window !== "undefined" && window.__DISABLE_OPTIONAL_SSE) === true;
    if (__DISABLE_OPTIONAL_SSE) {
      console.warn("[agent-status-row] Optional SSE disabled (Phase 16 pending):", OPS_SSE_URL);
      Object.keys(indicators).forEach((key) => applyVisual(key, "unknown"));
      return;
    }
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
    const __DISABLE_OPTIONAL_SSE = (typeof window !== "undefined" && window.__DISABLE_OPTIONAL_SSE) === true;
    if (__DISABLE_OPTIONAL_SSE) {
      console.warn("[ops-globals-bridge] Optional SSE disabled (Phase 16 pending):", opsUrl);
      return;
    }
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
  (() => {
    const API = {
      list: "/api/tasks",
      complete: "/api/complete-task"
    };
    const SELECTORS = [
      "#tasks-widget",
      "#tasksWidget",
      "[data-tasks-widget]",
      "[data-widget='tasks']"
    ];
    const state = {
      tasks: [],
      loading: false,
      lastError: null,
      inflightComplete: /* @__PURE__ */ new Set()
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
      return String(s ?? "").replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;").replaceAll("'", "&#39;");
    }
    async function apiJson(url, opts = {}) {
      const res = await fetch(url, {
        method: opts.method || "GET",
        headers: { "Content-Type": "application/json" },
        body: opts.body ? JSON.stringify(opts.body) : void 0
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json?.error || "Request failed");
      return json;
    }
    async function fetchTasks() {
      state.loading = true;
      render();
      try {
        const data = await apiJson(API.list);
        state.tasks = (data.tasks || []).map((t) => ({
          id: String(t.id),
          title: t.title || "",
          status: t.status || ""
        }));
      } catch (e) {
        state.lastError = e.message;
      } finally {
        state.loading = false;
        render();
      }
    }
    async function completeTask(taskId) {
      if (state.inflightComplete.has(taskId)) return;
      state.inflightComplete.add(taskId);
      render();
      try {
        await apiJson(API.complete, {
          method: "POST",
          body: { taskId }
        });
      } catch (e) {
        state.lastError = e.message;
      } finally {
        state.inflightComplete.delete(taskId);
        await fetchTasks();
      }
    }
    function render() {
      const mount = findMount();
      if (!mount) return;
      mount.innerHTML = `
      <div>
        
        ${state.lastError ? `<div style="color:red">${esc(state.lastError)}</div>` : ""}
        <div>
          ${state.tasks.map((t) => `
            <div style="display:flex;justify-content:space-between;gap:8px">
              <span>${esc(t.title)}</span>
              ${t.status === "complete" ? `<span style="opacity:.5;font-size:12px">Completed</span>` : `<button data-id="${t.id}">Complete</button>`}
            </div>
          `).join("")}
        </div>
      </div>
    `;
      mount.querySelectorAll("button[data-id]").forEach((btn) => {
        btn.onclick = () => completeTask(btn.dataset.id);
      });
    }
    document.addEventListener("DOMContentLoaded", fetchTasks);
    setInterval(() => {
      fetchTasks();
    }, 5e3);
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

  // public/js/dashboard-bundle-entry.js
  if (typeof window !== "undefined" && typeof window.__DISABLE_OPTIONAL_SSE === "undefined") {
    window.__DISABLE_OPTIONAL_SSE = false;
  }
})();
//# sourceMappingURL=bundle.js.map
