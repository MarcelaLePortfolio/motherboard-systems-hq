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
      if (u.includes("/events/task-events") || u.includes("/events/tasks")) return "tasks";
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
      if (typeof window !== "undefined" && window.__PHASE16_SSE_OWNER_STARTED) {
        return null;
      }
      const g = ensureGlobal();
      try {
        g[key].es && g[key].es.close();
      } catch {
      }
      g[key].es = null;
      const es = window.__PHASE16_SSE_OWNER_STARTED ? null : new EventSource(url);
      g[key].es = es;
      if (!es) return null;
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
    const title = container.querySelector("h2");
    container.innerHTML = "";
    if (title) container.appendChild(title);
    const AGENTS = ["Matilda", "Cade", "Effie", "Atlas"];
    const indicators = {};
    const stack = document.createElement("div");
    stack.className = "w-full flex flex-col gap-0.5";
    container.appendChild(stack);
    AGENTS.forEach((name) => {
      const row = document.createElement("div");
      row.className = "w-full min-h-0 rounded-md bg-slate-600/55 border border-slate-500/35 px-3 py-1.5 flex items-center justify-between shadow-sm";
      const left = document.createElement("div");
      left.className = "flex items-center gap-3 min-w-0";
      const bar = document.createElement("span");
      bar.className = "inline-block w-2 h-2 rounded-full bg-amber-300 shrink-0";
      const label = document.createElement("span");
      label.className = "text-[13px] font-semibold tracking-tight text-slate-100/95 truncate";
      label.textContent = name;
      const status = document.createElement("span");
      status.className = "text-[12px] font-medium text-slate-200/90 truncate";
      status.textContent = "unknown";
      left.append(bar, label);
      row.append(left, status);
      stack.appendChild(row);
      indicators[name.toLowerCase()] = { row, bar, label, status };
    });
    const OPS_SSE_URL = `/events/ops`;
    const __DISABLE_OPTIONAL_SSE = (typeof window !== "undefined" && window.__DISABLE_OPTIONAL_SSE) === true;
    function classifyStatus(statusString) {
      if (typeof window !== "undefined" && window.__PHASE16_SSE_OWNER_STARTED) {
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
      indicator.row.className = "w-full min-h-0 rounded-md border px-3 py-1.5 flex items-center justify-between shadow-sm";
      indicator.bar.className = "inline-block shrink-0";
      indicator.bar.style.display = "inline-block";
      indicator.bar.style.width = "8px";
      indicator.bar.style.height = "8px";
      indicator.bar.style.minWidth = "8px";
      indicator.bar.style.minHeight = "8px";
      indicator.bar.style.borderRadius = "999px";
      indicator.bar.style.marginRight = "8px";
      indicator.bar.style.boxShadow = "0 0 0 2px rgba(255,255,255,0.08) inset";
      indicator.bar.style.background = "rgba(148,163,184,0.8)";
      indicator.bar.style.width = "8px";
      indicator.bar.style.height = "8px";
      indicator.bar.style.minWidth = "8px";
      indicator.bar.style.minHeight = "8px";
      indicator.bar.style.borderRadius = "999px";
      indicator.bar.style.marginRight = "8px";
      indicator.label.className = "text-[13px] font-semibold tracking-tight truncate";
      indicator.status.className = "text-[11px] font-medium truncate";
      switch (kind) {
        case "online":
          indicator.row.classList.add("bg-gray-900", "border-gray-700");
          indicator.bar.style.background = "rgba(52,211,153,0.95)";
          indicator.label.classList.add("text-slate-100");
          indicator.status.classList.add("text-emerald-300/90");
          break;
        case "error":
          indicator.row.classList.add("bg-gray-900", "border-gray-700");
          indicator.bar.style.background = "rgba(251,113,133,0.95)";
          indicator.label.classList.add("text-slate-100");
          indicator.status.classList.add("text-rose-300/90");
          break;
        case "pending":
          indicator.row.classList.add("bg-gray-900", "border-gray-700");
          indicator.bar.style.background = "rgba(252,211,77,0.95)";
          indicator.label.classList.add("text-slate-100");
          indicator.status.classList.add("text-amber-200/90");
          break;
        case "unknown":
        default:
          indicator.row.classList.add("bg-gray-900", "border-gray-700");
          indicator.bar.style.background = "rgba(148,163,184,0.8)";
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
    let source;
    try {
      source = window.__PHASE16_SSE_OWNER_STARTED ? null : new EventSource(OPS_SSE_URL);
    } catch (err) {
      console.error("agent-status-row.js: Failed to open OPS SSE connection:", err);
      return;
    }
    if (!source) return;
    source.onmessage = (event) => {
      let data;
      try {
        data = JSON.parse(event.data);
      } catch {
        return;
      }
      const agentName = (data.agent || data.actor || data.source || data.worker || "").toString().toLowerCase();
      if (!agentName || !indicators[agentName]) return;
      const status = (data.status || data.state || data.level || "").toString() || "unknown";
      applyVisual(agentName, status);
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
    if (typeof window !== "undefined" && window.__PHASE16_SSE_OWNER_STARTED) return;
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
      try {
        window.dispatchEvent(new CustomEvent("mb:ops:update", {
          detail: { event: "message", state: window.lastOpsStatusSnapshot }
        }));
      } catch {
      }
    };
    try {
      const es = window.__PHASE16_SSE_OWNER_STARTED ? null : new EventSource(opsUrl);
      if (!es) return null;
      es.onmessage = handleEvent;
      es.addEventListener("hello", handleEvent);
      if (!es) return;
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
      window.appendMessage = window.appendMessage || function(msg) {
        try {
          var role = msg && msg.role ? String(msg.role) : "system";
          var content = msg && (msg.content ?? msg.text ?? msg.message) ? String(msg.content ?? msg.text ?? msg.message) : "";
          var sender = role === "user" ? "You" : role === "matilda" ? "Matilda" : "System";
          appendMessage(transcript, sender, content);
        } catch (_) {
        }
      };
      window.__appendMessage = window.__appendMessage || window.appendMessage;
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

  // public/js/dashboard-delegation.js
  (function() {
    console.log("[dashboard-delegation] module loaded");
    function $(id) {
      return document.getElementById(id);
    }
    function getSafeFetch() {
      var f = window.fetch;
      var t = typeof f;
      console.log("[dashboard-delegation] detected fetch type:", t);
      if (t !== "function") {
        console.error("[dashboard-delegation] fetch is not a function; value:", f);
        return null;
      }
      return f.bind(window);
    }
    function escapeHtml(value) {
      return String(value == null ? "" : value).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;");
    }
    function formatJsonBlock(obj) {
      return '<pre class="mt-3 overflow-x-auto whitespace-pre-wrap break-words rounded-lg bg-black/20 p-3 text-xs text-gray-300">' + escapeHtml(JSON.stringify(obj, null, 2)) + "</pre>";
    }
    function setResponseState(kind, html) {
      var response = $("delegation-response");
      var panel = $("delegation-status-panel");
      if (!response) return;
      response.innerHTML = html;
      if (!panel) return;
      panel.classList.remove("border-gray-700", "border-teal-600", "border-green-600", "border-red-600", "border-amber-500");
      if (kind === "sending") panel.classList.add("border-teal-600");
      else if (kind === "success") panel.classList.add("border-green-600");
      else if (kind === "error") panel.classList.add("border-red-600");
      else if (kind === "waiting") panel.classList.add("border-amber-500");
      else panel.classList.add("border-gray-700");
    }
    function setIdle() {
      setResponseState(
        "idle",
        "Awaiting operator input.<br>Results from delegation requests will appear here."
      );
    }
    function setSending(text) {
      setResponseState(
        "sending",
        '<div class="text-teal-300 font-medium">Sending delegation\u2026</div><div class="mt-2 text-gray-400">Preparing request for the orchestration layer.</div>' + (text ? '<div class="mt-3 rounded-lg bg-black/20 p-3 text-xs text-gray-300 break-words">' + escapeHtml(text) + "</div>" : "")
      );
    }
    function setWaiting() {
      setResponseState(
        "waiting",
        '<div class="text-amber-300 font-medium">Still waiting on delegation response\u2026</div><div class="mt-2 text-gray-400">The request may still be processing.</div>'
      );
    }
    function setSuccess(data) {
      var summary = "Delegation accepted.";
      if (data && typeof data === "object") {
        summary = data.message || data.status || data.result || data.reply || data.ok && "Delegation accepted." || summary;
      }
      setResponseState(
        "success",
        '<div class="text-green-300 font-medium">' + escapeHtml(summary) + '</div><div class="mt-2 text-gray-400">Request completed successfully.</div>' + (data && typeof data === "object" ? formatJsonBlock(data) : "")
      );
    }
    function setError(message, extra) {
      setResponseState(
        "error",
        '<div class="text-red-300 font-medium">Delegation failed.</div><div class="mt-2 text-gray-300">' + escapeHtml(message || "Unknown error") + "</div>" + (extra ? '<div class="mt-3 text-xs text-gray-400 break-words">' + escapeHtml(extra) + "</div>" : "")
      );
    }
    async function onDelegationClick() {
      var input = $("delegation-input");
      var btn = $("delegation-submit");
      if (!input) {
        console.warn("[dashboard-delegation] delegation input not found at click time");
        setError("Delegation input field was not found.");
        return;
      }
      var value = String(input.value || "").trim();
      if (!value) {
        console.warn("[dashboard-delegation] empty delegation input; skipping");
        setError("Please enter a delegation request before submitting.");
        return;
      }
      console.log("[dashboard-delegation] sending delegation:", value);
      var safeFetch = getSafeFetch();
      if (!safeFetch) {
        console.error("[dashboard-delegation] aborting delegation because fetch is unavailable or invalid");
        setError("Browser fetch is unavailable.");
        return;
      }
      var oldText = btn ? btn.textContent || "Submit Delegation" : "Submit Delegation";
      var waitingTimer = null;
      try {
        if (btn) {
          btn.disabled = true;
          btn.textContent = "Sending...";
          btn.classList.add("opacity-70", "cursor-not-allowed");
        }
        setSending(value);
        waitingTimer = window.setTimeout(setWaiting, 4e3);
        var res;
        try {
          res = await safeFetch("/api/delegate-task", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json"
            },
            body: JSON.stringify({ prompt: value, message: value, text: value, task: value })
          });
        } catch (err) {
          console.error("[dashboard-delegation] fetch threw before response:", err);
          throw err;
        }
        console.log("[dashboard-delegation] fetch returned:", {
          ok: res && res.ok,
          status: res && res.status,
          statusText: res && res.statusText
        });
        var data = null;
        var rawText = "";
        try {
          rawText = await res.text();
          data = rawText ? JSON.parse(rawText) : {};
        } catch (err) {
          console.error("[dashboard-delegation] error parsing JSON response:", err);
          data = { error: "Non-JSON response from /api/delegate-task", raw: rawText || "" };
        }
        console.log("[dashboard-delegation] delegation response:", data);
        if (!res.ok) {
          setError(
            data && (data.error || data.message || data.statusText) || "HTTP " + res.status + " " + (res.statusText || ""),
            rawText
          );
          return;
        }
        setSuccess(data);
      } catch (err) {
        setError(err && err.message ? err.message : String(err));
      } finally {
        if (waitingTimer) window.clearTimeout(waitingTimer);
        if (btn) {
          btn.disabled = false;
          btn.textContent = oldText;
          btn.classList.remove("opacity-70", "cursor-not-allowed");
        }
      }
    }
    function init() {
      var btn = $("delegation-submit");
      var input = $("delegation-input");
      if (!btn || !input) {
        console.warn("[dashboard-delegation] delegation button or input not found in init");
        return;
      }
      setIdle();
      if (btn.dataset.delegationWired === "true") {
        console.log("[dashboard-delegation] Task Delegation wiring already active");
        return;
      }
      btn.dataset.delegationWired = "true";
      btn.addEventListener("click", onDelegationClick);
      input.addEventListener("keydown", function(e) {
        if ((e.metaKey || e.ctrlKey) && e.key === "Enter") {
          e.preventDefault();
          onDelegationClick();
        }
      });
      console.log("[dashboard-delegation] Task Delegation wiring active");
    }
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", init, { once: true });
    } else {
      init();
    }
  })();

  // public/js/task-events-sse-client.js
  (() => {
    const SSE_URL = "/events/task-events";
    const PANEL_ID = "mb-task-events-panel";
    const FEED_ID = "mb-task-events-feed";
    const COUNTS_ID = "mb-task-events-counts";
    const ANCHOR_ID = "mb-task-events-panel-anchor";
    function mountRoot() {
      const anchor = document.getElementById(ANCHOR_ID);
      if (anchor) return anchor;
      return document.body;
    }
    function ensurePanel() {
      if (document.getElementById(PANEL_ID)) return;
      const root = mountRoot();
      const panel = document.createElement("div");
      panel.id = PANEL_ID;
      const anchored = root && root.id === ANCHOR_ID;
      panel.style.width = anchored ? "100%" : "360px";
      panel.style.maxWidth = anchored ? "100%" : "calc(100vw - 24px)";
      panel.style.maxHeight = anchored ? "260px" : "40vh";
      panel.style.overflow = "hidden";
      panel.style.zIndex = "9999";
      panel.style.border = "1px solid rgba(255,255,255,0.12)";
      panel.style.borderRadius = "14px";
      panel.style.background = "rgba(10,10,14,0.92)";
      panel.style.backdropFilter = "blur(10px)";
      panel.style.boxShadow = "0 10px 30px rgba(0,0,0,0.35)";
      panel.style.color = "rgba(255,255,255,0.92)";
      panel.style.fontFamily = "ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial";
      if (!anchored) {
        panel.style.position = "fixed";
        panel.style.right = "12px";
        panel.style.bottom = "12px";
      } else {
        panel.style.marginTop = "12px";
      }
      const header = document.createElement("div");
      header.style.display = "flex";
      header.style.alignItems = "center";
      header.style.justifyContent = "space-between";
      header.style.gap = "8px";
      header.style.padding = "10px 12px";
      header.style.borderBottom = "1px solid rgba(255,255,255,0.10)";
      const title = document.createElement("div");
      title.textContent = "Task Events";
      title.style.fontSize = "12px";
      title.style.letterSpacing = "0.06em";
      title.style.opacity = "0.9";
      const right = document.createElement("div");
      right.style.display = "flex";
      right.style.alignItems = "center";
      right.style.gap = "10px";
      const counts = document.createElement("div");
      counts.id = COUNTS_ID;
      counts.textContent = "created:0  completed:0  failed:0";
      counts.style.fontSize = "11px";
      counts.style.opacity = "0.85";
      counts.style.fontVariantNumeric = "tabular-nums";
      const dot = document.createElement("span");
      dot.setAttribute("aria-label", "task-events connection");
      dot.title = "task-events connection";
      dot.style.display = "inline-block";
      dot.style.width = "10px";
      dot.style.height = "10px";
      dot.style.borderRadius = "999px";
      dot.style.background = "rgba(255,255,255,0.25)";
      dot.style.boxShadow = "0 0 0 2px rgba(255,255,255,0.08) inset";
      const btn = document.createElement("button");
      btn.type = "button";
      btn.textContent = "\xD7";
      btn.title = "hide";
      btn.style.cursor = "pointer";
      btn.style.border = "1px solid rgba(255,255,255,0.14)";
      btn.style.background = "transparent";
      btn.style.color = "rgba(255,255,255,0.85)";
      btn.style.borderRadius = "10px";
      btn.style.width = "28px";
      btn.style.height = "24px";
      btn.style.lineHeight = "22px";
      btn.style.fontSize = "14px";
      btn.onclick = () => panel.remove();
      right.appendChild(dot);
      right.appendChild(counts);
      right.appendChild(btn);
      header.appendChild(title);
      header.appendChild(right);
      const feed = document.createElement("div");
      feed.id = FEED_ID;
      feed.style.padding = "10px 12px";
      feed.style.overflow = "auto";
      feed.style.maxHeight = anchored ? "200px" : "calc(40vh - 46px)";
      panel.appendChild(header);
      panel.appendChild(feed);
      root.appendChild(panel);
      window.__MB_TASK_EVENTS_PANEL = { dot, feed, counts };
      console.log("[phase22] task-events panel mounted (anchored=%s)", anchored);
    }
    function setDot(state) {
      ensurePanel();
      const dot = window.__MB_TASK_EVENTS_PANEL?.dot;
      if (!dot) return;
      if (state === "open") dot.style.background = "rgba(80,200,120,0.85)";
      else if (state === "error") dot.style.background = "rgba(240,90,90,0.85)";
      else dot.style.background = "rgba(255,255,255,0.25)";
    }
    const seen = /* @__PURE__ */ new Set();
    const tally = { created: 0, completed: 0, failed: 0 };
    function bumpCounts(kind) {
      if (kind === "task.created") tally.created += 1;
      if (kind === "task.completed") tally.completed += 1;
      if (kind === "task.failed") tally.failed += 1;
      const el = document.getElementById(COUNTS_ID);
      if (el) el.textContent = `created:${tally.created}  completed:${tally.completed}  failed:${tally.failed}`;
    }
    function isoText(ts) {
      if (typeof ts === "number") return new Date(ts).toISOString();
      if (typeof ts === "string" && ts.trim()) {
        const d = new Date(ts);
        if (!Number.isNaN(d.getTime())) return d.toISOString();
        return ts.trim();
      }
      return (/* @__PURE__ */ new Date()).toISOString();
    }
    function classifyKind(kind, message, status) {
      const text = `${kind || ""} ${message || ""} ${status || ""}`.toLowerCase();
      if (/fail|error|cancel|timeout/.test(text)) return "terminal-error";
      if (/complete|done|success/.test(text)) return "terminal-success";
      if (/queue|pending|retry|wait|hold|sleep/.test(text)) return "waiting";
      if (/open|start|run|resume|lease|dispatch|ack|progress|update|active|heartbeat/.test(text)) return "active";
      return "neutral";
    }
    function accentColor(tone) {
      if (tone === "terminal-error") return "rgba(240,90,90,0.95)";
      if (tone === "terminal-success") return "rgba(80,200,120,0.95)";
      if (tone === "waiting") return "rgba(250,204,21,0.95)";
      if (tone === "active") return "rgba(96,165,250,0.95)";
      return "rgba(255,255,255,0.18)";
    }
    function buildEventRecord(ev, fallbackKind) {
      const ts = isoText(ev.ts);
      const kind = String(ev.kind ?? fallbackKind ?? "event");
      const taskId = ev.task_id ?? ev.taskId ?? "unknown";
      const runId = ev.run_id ?? ev.runId ?? "";
      const actor = ev.actor ?? ev.meta?.actor ?? ev.meta?.owner ?? "";
      const status = ev.status ?? ev.meta?.status ?? "";
      const cursor = typeof ev.cursor === "number" || typeof ev.cursor === "string" ? String(ev.cursor) : "";
      const message = String(ev.msg ?? ev.message ?? "").trim();
      const detailParts = [];
      detailParts.push(`task=${taskId}`);
      if (runId) detailParts.push(`run=${runId}`);
      if (actor) detailParts.push(`actor=${actor}`);
      if (status) detailParts.push(`status=${status}`);
      if (cursor) detailParts.push(`cursor=${cursor}`);
      if (message) detailParts.push(message);
      const detail = detailParts.join(" \u2022 ");
      const tone = classifyKind(kind, message, status);
      return { ts, kind, detail, tone };
    }
    function appendEvent(ev, fallbackKind) {
      ensurePanel();
      const feed = document.getElementById(FEED_ID);
      if (!feed) return;
      const record = buildEventRecord(ev, fallbackKind);
      const row = document.createElement("div");
      row.className = `phase61-task-event phase61-task-event-${record.tone}`;
      row.dataset.eventKind = record.kind;
      row.dataset.eventTone = record.tone;
      row.style.position = "relative";
      row.style.display = "grid";
      row.style.gridTemplateColumns = "minmax(112px, 132px) minmax(150px, 170px) 1fr";
      row.style.gap = "10px";
      row.style.alignItems = "start";
      row.style.padding = "10px 12px 10px 14px";
      row.style.marginBottom = "8px";
      row.style.border = "1px solid rgba(255,255,255,0.10)";
      row.style.borderRadius = "12px";
      row.style.background = "rgba(255,255,255,0.03)";
      row.style.lineHeight = "1.35";
      row.style.fontSize = "12px";
      const accent = document.createElement("span");
      accent.setAttribute("aria-hidden", "true");
      accent.style.position = "absolute";
      accent.style.left = "0";
      accent.style.top = "10px";
      accent.style.bottom = "10px";
      accent.style.width = "3px";
      accent.style.borderRadius = "999px";
      accent.style.background = accentColor(record.tone);
      const time = document.createElement("div");
      time.textContent = record.ts;
      time.style.color = "rgba(255,255,255,0.68)";
      time.style.fontVariantNumeric = "tabular-nums";
      time.style.whiteSpace = "nowrap";
      const kind = document.createElement("div");
      kind.textContent = record.kind;
      kind.style.color = "rgba(255,255,255,0.92)";
      kind.style.fontWeight = "600";
      kind.style.letterSpacing = "0.01em";
      kind.style.wordBreak = "break-word";
      const detail = document.createElement("div");
      detail.textContent = record.detail || "\u2014";
      detail.style.color = "rgba(255,255,255,0.78)";
      detail.style.wordBreak = "break-word";
      row.appendChild(accent);
      row.appendChild(time);
      row.appendChild(kind);
      row.appendChild(detail);
      feed.prepend(row);
      const children = Array.from(feed.children);
      if (children.length > 60) {
        for (let i = 60; i < children.length; i++) children[i].remove();
      }
    }
    function dispatchWindowEvent(ev) {
      try {
        window.dispatchEvent(new CustomEvent("mb.task.event", { detail: ev }));
      } catch {
      }
    }
    function parseMaybeJSON(raw) {
      try {
        return JSON.parse(raw);
      } catch {
        return null;
      }
    }
    function handleFrame(eventName, rawData) {
      const data = typeof rawData === "string" ? parseMaybeJSON(rawData) : rawData;
      const ev = data && typeof data === "object" ? data : { kind: eventName, raw: rawData };
      if (eventName === "task.event") {
        if (ev.actor == null && ev.meta && typeof ev.meta === "object") ev.actor = ev.meta.actor ?? ev.meta.owner ?? null;
        if (!ev.kind && ev.type) ev.kind = ev.type;
        if (ev.kind === "task.event" && ev.type) ev.kind = ev.type;
        if (ev.task_id == null && ev.taskId != null) ev.task_id = ev.taskId;
        if (ev.run_id == null && ev.runId != null) ev.run_id = ev.runId;
        if (ev && ev.meta && typeof ev.meta === "object") {
          if (ev.task_id == null && ev.meta.task_id != null) ev.task_id = ev.meta.task_id;
          if (ev.run_id == null && ev.meta.run_id != null) ev.run_id = ev.meta.run_id;
          if (ev.actor == null && ev.meta.actor != null) ev.actor = ev.meta.actor;
          if (ev.actor == null && ev.meta.owner != null) ev.actor = ev.meta.owner;
          if (ev.status == null && ev.meta.status != null) ev.status = ev.meta.status;
        }
      }
      if (!ev.kind) ev.kind = eventName;
      const key = `${eventName}|${ev.kind}|${ev.ts ?? ""}|${ev.task_id ?? ""}|${ev.run_id ?? ""}|${ev.cursor ?? ""}`;
      if (seen.has(key)) return;
      seen.add(key);
      if (ev.kind === "task.created" || ev.kind === "task.completed" || ev.kind === "task.failed") {
        bumpCounts(String(ev.kind));
      }
      appendEvent(ev, eventName);
      if (window.__UI_DEBUG) try {
        console.log("[task-events] mb.task.event", ev);
      } catch {
      }
      dispatchWindowEvent(ev);
    }
    let es = null;
    let attempt = 0;
    function connect() {
      ensurePanel();
      if (es) {
        try {
          es.close();
        } catch {
        }
        es = null;
      }
      const url = SSE_URL;
      es = new EventSource(url);
      es.onopen = () => {
        attempt = 0;
        setDot("open");
        appendEvent({ ts: Date.now(), kind: "sse.open", message: `url=${url}` }, "sse.open");
        console.log("[phase22] task-events SSE open", url);
      };
      es.onerror = () => {
        setDot("error");
        try {
          es.close();
        } catch {
        }
        es = null;
        attempt += 1;
        const delay = Math.min(15e3, 500 * Math.pow(2, Math.min(6, attempt)));
        appendEvent({ ts: Date.now(), kind: "sse.error", message: `reconnect_in=${delay}ms` }, "sse.error");
        console.log("[phase22] task-events SSE error; reconnect in", delay);
        setTimeout(connect, delay);
      };
      es.onmessage = (msg) => handleFrame("message", msg.data);
      const names = [
        "hello",
        "heartbeat",
        "task.event",
        "task.created",
        "task.completed",
        "task.failed",
        "task.updated",
        "task.status"
      ];
      for (const name of names) {
        es.addEventListener(name, (e) => handleFrame(name, e.data));
      }
    }
    function boot() {
      connect();
      setInterval(() => {
        if (!document.getElementById(PANEL_ID)) {
          try {
            connect();
          } catch {
          }
        }
      }, 2e3);
    }
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", boot, { once: true });
    } else {
      boot();
    }
    window.__MB_TASK_EVENTS = { url: SSE_URL, reconnect: () => connect() };
  })();

  // public/js/phase22_task_delegation_live_bindings.js
  (() => {
    const TASK_EVENT_NAME = "mb.task.event";
    const tasks = /* @__PURE__ */ new Map();
    const STATUS_CLASS = {
      queued: "task-status-queued",
      done: "task-status-done",
      failed: "task-status-failed"
    };
    function normStatus(s) {
      const v = String(s ?? "").toLowerCase();
      if (v === "queued" || v === "pending") return "queued";
      if (v === "done" || v === "complete" || v === "completed") return "done";
      if (v === "failed" || v === "error") return "failed";
      return v || "unknown";
    }
    function pluckId(ev) {
      return ev?.task_id ?? ev?.taskId ?? ev?.task?.id ?? null;
    }
    function pluckTask(ev) {
      const t = ev?.task && typeof ev.task === "object" ? ev.task : null;
      const id = pluckId(ev);
      const status = ev?.status ?? ev?.payload?.status ?? t?.status ?? (ev?.kind === "task.created" ? "queued" : null);
      return {
        id: id != null ? String(id) : null,
        status: status != null ? normStatus(status) : null,
        title: t?.title ?? ev?.title ?? null,
        agent: t?.agent ?? ev?.agent ?? null,
        error: ev?.error ?? ev?.payload?.error ?? t?.error ?? null,
        updated_at: t?.updated_at ?? ev?.ts ?? Date.now()
      };
    }
    function setStatusOnNode(node, status) {
      if (!node) return;
      const s = normStatus(status);
      node.setAttribute("data-task-status", s);
      node.classList?.remove(...Object.values(STATUS_CLASS));
      if (STATUS_CLASS[s]) node.classList?.add(STATUS_CLASS[s]);
      const sub = node.querySelector?.("[data-task-field='status']") || node.querySelector?.(".task-status") || node.querySelector?.(".status") || null;
      if (sub) sub.textContent = s;
    }
    function updateTaskRowUI(task) {
      if (!task?.id) return;
      const id = String(task.id);
      const nodes2 = [
        document.getElementById(`task-${id}`),
        document.getElementById(`task_${id}`),
        document.querySelector?.(`[data-task-id="${CSS.escape(id)}"]`),
        document.querySelector?.(`[data-taskid="${CSS.escape(id)}"]`)
      ].filter(Boolean);
      for (const n of nodes2) setStatusOnNode(n, task.status);
    }
    function updateCountersUI() {
      let queued = 0, done = 0, failed = 0;
      for (const t of tasks.values()) {
        const s = normStatus(t.status);
        if (s === "queued") queued++;
        else if (s === "done") done++;
        else if (s === "failed") failed++;
      }
      const map = [
        ["queued", queued],
        ["done", done],
        ["failed", failed]
      ];
      for (const [k, v] of map) {
        const el = document.getElementById(`task-count-${k}`) || document.getElementById(`tasks-${k}-count`) || document.querySelector?.(`[data-task-count="${k}"]`) || null;
        if (el) el.textContent = String(v);
      }
    }
    function ingestTask(task) {
      if (!task?.id) return;
      const id = String(task.id);
      const prev = tasks.get(id) || {};
      const next = { ...prev, ...task, id, status: task.status ?? prev.status };
      tasks.set(id, next);
      updateTaskRowUI(next);
      updateCountersUI();
    }
    function onTaskEvent(ev) {
      const t = pluckTask(ev);
      if (!t.id && ev?.kind) {
        if (ev.kind === "task.completed") t.status = "done";
        if (ev.kind === "task.failed") t.status = "failed";
      }
      if (t.id) ingestTask(t);
    }
    function attach() {
      if (window.__PHASE22_TASK_UI_BOUND) return;
      window.__PHASE22_TASK_UI_BOUND = true;
      window.addEventListener(TASK_EVENT_NAME, (e) => {
        try {
          if (window.__UI_DEBUG || window.__PHASE22_DEBUG) {
            if (window.__UI_DEBUG || window.__PHASE22_DEBUG) console.log("[phase22] mb.task.event", e.detail);
          }
          onTaskEvent(e.detail);
        } catch {
        }
      });
      window.__PHASE22_TASK_UI = { tasks };
      console.log("[phase22] bindings attached");
    }
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", attach, { once: true });
    } else {
      attach();
    }
  })();

  // public/js/dashboard-bundle-entry.js
  if (typeof window !== "undefined" && typeof window.__DISABLE_OPTIONAL_SSE === "undefined") {
    window.__DISABLE_OPTIONAL_SSE = false;
  }
})();
//# sourceMappingURL=bundle.js.map
