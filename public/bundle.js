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
      source = window.__PHASE16_SSE_OWNER_STARTED ? null : new EventSource(OPS_SSE_URL);
    } catch (err) {
      console.error("agent-status-row.js: Failed to open OPS SSE connection:", err);
      return;
    }
    function classifyStatus(statusString) {
      if (typeof window !== "undefined" && window.__PHASE16_SSE_OWNER_STARTED) {
        return null;
      }
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
    if (!source) return null;
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

  // public/js/task-events-sse-client.js
  (() => {
    const SSE_URL = "/events/task-events";
    const PANEL_ID = "mb-task-events-panel";
    const FEED_ID = "mb-task-events-feed";
    const COUNTS_ID = "mb-task-events-counts";
    const STATUS_ID = "mb-task-events-status";
    const ANCHOR_ID = "mb-task-events-panel-anchor";
    const MAX_ROWS = 24;
    const FLUSH_INTERVAL_MS = 700;
    const HEARTBEAT_COLLAPSE_MS = 4e3;
    const PROBE_COLLAPSE_MS = 2500;
    const seen = /* @__PURE__ */ new Set();
    const tally = { created: 0, completed: 0, failed: 0 };
    const queue = [];
    let flushTimer = null;
    let panelReady = false;
    let heartbeatBucket = null;
    let probeBucket = null;
    let connectionState = "connecting";
    let lastFrameAt = null;
    function mountRoot() {
      const anchor = document.getElementById(ANCHOR_ID);
      if (anchor) return anchor;
      return document.body;
    }
    function ensurePanel() {
      if (panelReady && document.getElementById(PANEL_ID)) return;
      const root = mountRoot();
      const anchored = root && root.id === ANCHOR_ID;
      const existing = document.getElementById(PANEL_ID);
      if (existing) {
        panelReady = true;
        return;
      }
      const panel = document.createElement("section");
      panel.id = PANEL_ID;
      panel.setAttribute("aria-live", "polite");
      panel.style.width = "100%";
      panel.style.maxWidth = "100%";
      panel.style.overflow = "hidden";
      panel.style.border = "1px solid rgba(148,163,184,0.18)";
      panel.style.borderRadius = "18px";
      panel.style.background = "rgba(15,23,42,0.72)";
      panel.style.backdropFilter = "blur(10px)";
      panel.style.boxShadow = "0 18px 36px rgba(2,6,23,0.38)";
      panel.style.color = "rgba(255,255,255,0.94)";
      panel.style.fontFamily = "ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif";
      if (!anchored) {
        panel.style.position = "fixed";
        panel.style.right = "12px";
        panel.style.bottom = "12px";
        panel.style.width = "min(560px, calc(100vw - 24px))";
        panel.style.zIndex = "9999";
      }
      const header = document.createElement("div");
      header.style.display = "flex";
      header.style.alignItems = "flex-start";
      header.style.justifyContent = "space-between";
      header.style.gap = "12px";
      header.style.padding = "14px 16px 12px";
      header.style.borderBottom = "1px solid rgba(148,163,184,0.14)";
      const left = document.createElement("div");
      left.style.minWidth = "0";
      const title = document.createElement("div");
      title.textContent = "Probe Event Stream";
      title.style.fontSize = "15px";
      title.style.fontWeight = "700";
      title.style.letterSpacing = "0.01em";
      const subtitle = document.createElement("div");
      subtitle.textContent = "Contained live feed for probe lifecycle and task events";
      subtitle.style.fontSize = "12px";
      subtitle.style.opacity = "0.72";
      subtitle.style.marginTop = "4px";
      const status = document.createElement("div");
      status.id = STATUS_ID;
      status.style.fontSize = "12px";
      status.style.opacity = "0.85";
      status.style.marginTop = "8px";
      status.textContent = "Connecting\u2026";
      left.appendChild(title);
      left.appendChild(subtitle);
      left.appendChild(status);
      const right = document.createElement("div");
      right.style.display = "flex";
      right.style.alignItems = "center";
      right.style.gap = "10px";
      right.style.flexShrink = "0";
      const counts = document.createElement("div");
      counts.id = COUNTS_ID;
      counts.style.fontSize = "11px";
      counts.style.opacity = "0.8";
      counts.style.textAlign = "right";
      counts.style.whiteSpace = "nowrap";
      counts.textContent = "created 0 \xB7 completed 0 \xB7 failed 0";
      const dot = document.createElement("span");
      dot.setAttribute("aria-label", "task-events connection");
      dot.title = "task-events connection";
      dot.style.display = "inline-block";
      dot.style.width = "10px";
      dot.style.height = "10px";
      dot.style.borderRadius = "999px";
      dot.style.background = "rgba(148,163,184,0.55)";
      dot.style.boxShadow = "0 0 0 2px rgba(255,255,255,0.08) inset";
      right.appendChild(counts);
      right.appendChild(dot);
      header.appendChild(left);
      header.appendChild(right);
      const feed = document.createElement("div");
      feed.id = FEED_ID;
      feed.style.padding = "12px 16px 16px";
      feed.style.display = "flex";
      feed.style.flexDirection = "column";
      feed.style.gap = "10px";
      feed.style.maxHeight = anchored ? "340px" : "45vh";
      feed.style.overflow = "auto";
      const empty = document.createElement("div");
      empty.id = "mb-task-events-empty";
      empty.style.border = "1px dashed rgba(148,163,184,0.20)";
      empty.style.borderRadius = "14px";
      empty.style.padding = "12px 14px";
      empty.style.background = "rgba(255,255,255,0.03)";
      empty.style.fontSize = "12px";
      empty.style.lineHeight = "1.45";
      empty.style.opacity = "0.86";
      empty.textContent = "Waiting for probe lifecycle activity. Heartbeats will be grouped automatically so the panel stays readable.";
      feed.appendChild(empty);
      panel.appendChild(header);
      panel.appendChild(feed);
      root.appendChild(panel);
      window.__MB_TASK_EVENTS_PANEL = { dot, feed, counts, status };
      panelReady = true;
      syncStatus();
    }
    function syncStatus() {
      ensurePanel();
      const statusEl = document.getElementById(STATUS_ID);
      const dot = window.__MB_TASK_EVENTS_PANEL?.dot;
      if (!statusEl || !dot) return;
      if (connectionState === "open") {
        dot.style.background = "rgba(34,197,94,0.95)";
        statusEl.textContent = lastFrameAt ? `Connected \xB7 last event ${new Date(lastFrameAt).toLocaleTimeString()}` : "Connected";
        return;
      }
      if (connectionState === "error") {
        dot.style.background = "rgba(239,68,68,0.95)";
        statusEl.textContent = "Reconnecting after stream error\u2026";
        return;
      }
      dot.style.background = "rgba(148,163,184,0.60)";
      statusEl.textContent = "Connecting\u2026";
    }
    function updateCounts() {
      const countsEl = document.getElementById(COUNTS_ID);
      if (!countsEl) return;
      countsEl.textContent = `created ${tally.created} \xB7 completed ${tally.completed} \xB7 failed ${tally.failed}`;
    }
    function iso(ts) {
      return typeof ts === "number" ? new Date(ts).toISOString() : (/* @__PURE__ */ new Date()).toISOString();
    }
    function shortTime(ts) {
      return typeof ts === "number" ? new Date(ts).toLocaleTimeString() : (/* @__PURE__ */ new Date()).toLocaleTimeString();
    }
    function removeEmptyState() {
      const empty = document.getElementById("mb-task-events-empty");
      if (empty) empty.remove();
    }
    function makeRow(kind, title, meta, tone) {
      const row = document.createElement("div");
      row.style.border = "1px solid rgba(148,163,184,0.16)";
      row.style.borderRadius = "14px";
      row.style.padding = "10px 12px";
      row.style.background = "rgba(255,255,255,0.03)";
      row.style.boxShadow = "inset 0 1px 0 rgba(255,255,255,0.03)";
      if (tone === "probe") {
        row.style.borderColor = "rgba(99,102,241,0.34)";
        row.style.background = "rgba(79,70,229,0.12)";
      } else if (tone === "success") {
        row.style.borderColor = "rgba(34,197,94,0.30)";
        row.style.background = "rgba(34,197,94,0.08)";
      } else if (tone === "error") {
        row.style.borderColor = "rgba(239,68,68,0.32)";
        row.style.background = "rgba(239,68,68,0.08)";
      } else if (tone === "heartbeat") {
        row.style.opacity = "0.78";
      }
      const top = document.createElement("div");
      top.style.display = "flex";
      top.style.alignItems = "center";
      top.style.justifyContent = "space-between";
      top.style.gap = "10px";
      const label = document.createElement("div");
      label.style.fontSize = "12px";
      label.style.fontWeight = "700";
      label.style.letterSpacing = "0.02em";
      label.textContent = title;
      const time = document.createElement("div");
      time.style.fontSize = "11px";
      time.style.opacity = "0.62";
      time.style.whiteSpace = "nowrap";
      time.textContent = shortTime(meta.ts);
      const body = document.createElement("div");
      body.style.marginTop = "6px";
      body.style.fontSize = "12px";
      body.style.lineHeight = "1.45";
      body.style.opacity = "0.88";
      body.textContent = meta.text;
      const foot = document.createElement("div");
      foot.style.marginTop = "6px";
      foot.style.fontSize = "11px";
      foot.style.opacity = "0.64";
      foot.textContent = kind;
      top.appendChild(label);
      top.appendChild(time);
      row.appendChild(top);
      row.appendChild(body);
      row.appendChild(foot);
      return row;
    }
    function prependRow(row) {
      ensurePanel();
      const feed = document.getElementById(FEED_ID);
      if (!feed) return;
      removeEmptyState();
      feed.prepend(row);
      const rows = Array.from(feed.children);
      if (rows.length > MAX_ROWS) {
        for (let i = MAX_ROWS; i < rows.length; i += 1) rows[i].remove();
      }
    }
    function flushQueue() {
      flushTimer = null;
      if (queue.length === 0) return;
      while (queue.length > 0) {
        const item = queue.shift();
        prependRow(item);
      }
    }
    function scheduleFlush() {
      if (flushTimer != null) return;
      flushTimer = setTimeout(flushQueue, FLUSH_INTERVAL_MS);
    }
    function enqueueRow(row) {
      queue.push(row);
      scheduleFlush();
    }
    function formatEventText(ev, fallbackKind) {
      const kind = String(ev.kind ?? fallbackKind ?? "event");
      const parts = [];
      if (ev.task_id ?? ev.taskId) parts.push(`task ${ev.task_id ?? ev.taskId}`);
      if (ev.run_id ?? ev.runId) parts.push(`run ${ev.run_id ?? ev.runId}`);
      if (ev.actor) parts.push(`actor ${ev.actor}`);
      if (ev.status) parts.push(`status ${ev.status}`);
      if (typeof ev.cursor === "number") parts.push(`cursor ${ev.cursor}`);
      const base = parts.join(" \xB7 ");
      const msg = ev.msg ?? ev.message ?? "";
      return msg ? `${base}${base ? " \xB7 " : ""}${msg}` : base || kind;
    }
    function collapseHeartbeat(ev) {
      const now = Date.now();
      if (!heartbeatBucket || now - heartbeatBucket.startedAt > HEARTBEAT_COLLAPSE_MS) {
        heartbeatBucket = {
          startedAt: now,
          count: 0,
          lastTs: typeof ev.ts === "number" ? ev.ts : now,
          lastCursor: ev.cursor ?? null
        };
      }
      heartbeatBucket.count += 1;
      heartbeatBucket.lastTs = typeof ev.ts === "number" ? ev.ts : now;
      heartbeatBucket.lastCursor = ev.cursor ?? heartbeatBucket.lastCursor;
      if (heartbeatBucket.count < 3 && now - heartbeatBucket.startedAt < HEARTBEAT_COLLAPSE_MS) return;
      const text = [
        `${heartbeatBucket.count} heartbeat frames grouped`,
        heartbeatBucket.lastCursor != null ? `latest cursor ${heartbeatBucket.lastCursor}` : null
      ].filter(Boolean).join(" \xB7 ");
      enqueueRow(
        makeRow(
          "heartbeat",
          "Heartbeat activity",
          { ts: heartbeatBucket.lastTs, text },
          "heartbeat"
        )
      );
      heartbeatBucket = null;
    }
    function collapseProbe(ev) {
      const now = Date.now();
      const kind = String(ev.kind ?? "");
      const runId = ev.run_id ?? ev.runId ?? "policy.probe.run";
      if (!probeBucket || probeBucket.kind !== kind || now - probeBucket.startedAt > PROBE_COLLAPSE_MS) {
        if (probeBucket && probeBucket.count > 0) {
          enqueueRow(
            makeRow(
              probeBucket.kind,
              "Probe lifecycle activity",
              {
                ts: probeBucket.lastTs,
                text: `${probeBucket.count} ${probeBucket.kind} events \xB7 run ${probeBucket.runId}`
              },
              "probe"
            )
          );
        }
        probeBucket = {
          kind,
          runId,
          startedAt: now,
          count: 0,
          lastTs: typeof ev.ts === "number" ? ev.ts : now
        };
      }
      probeBucket.count += 1;
      probeBucket.lastTs = typeof ev.ts === "number" ? ev.ts : now;
      if (probeBucket.count < 2 && now - probeBucket.startedAt < PROBE_COLLAPSE_MS) return;
      enqueueRow(
        makeRow(
          probeBucket.kind,
          "Probe lifecycle activity",
          {
            ts: probeBucket.lastTs,
            text: `${probeBucket.count} ${probeBucket.kind} events \xB7 run ${probeBucket.runId}`
          },
          "probe"
        )
      );
      probeBucket = null;
    }
    function flushBuckets() {
      if (probeBucket && probeBucket.count > 0) {
        enqueueRow(
          makeRow(
            probeBucket.kind,
            "Probe lifecycle activity",
            {
              ts: probeBucket.lastTs,
              text: `${probeBucket.count} ${probeBucket.kind} events \xB7 run ${probeBucket.runId}`
            },
            "probe"
          )
        );
        probeBucket = null;
      }
      if (heartbeatBucket && heartbeatBucket.count > 0) {
        const text = [
          `${heartbeatBucket.count} heartbeat frames grouped`,
          heartbeatBucket.lastCursor != null ? `latest cursor ${heartbeatBucket.lastCursor}` : null
        ].filter(Boolean).join(" \xB7 ");
        enqueueRow(
          makeRow(
            "heartbeat",
            "Heartbeat activity",
            { ts: heartbeatBucket.lastTs, text },
            "heartbeat"
          )
        );
        heartbeatBucket = null;
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
      lastFrameAt = Date.now();
      syncStatus();
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
        }
      }
      if (!ev.kind) ev.kind = eventName;
      const key = `${eventName}|${ev.kind}|${ev.ts ?? ""}|${ev.task_id ?? ""}|${ev.run_id ?? ""}|${ev.cursor ?? ""}|${ev.message ?? ""}`;
      if (seen.has(key)) return;
      seen.add(key);
      if (ev.kind === "task.created") tally.created += 1;
      if (ev.kind === "task.completed") tally.completed += 1;
      if (ev.kind === "task.failed") tally.failed += 1;
      updateCounts();
      const kind = String(ev.kind ?? eventName);
      const runId = String(ev.run_id ?? ev.runId ?? "");
      const text = formatEventText(ev, eventName);
      if (kind === "heartbeat" || kind === "hello") {
        collapseHeartbeat(ev);
        dispatchWindowEvent(ev);
        return;
      }
      if (runId === "policy.probe.run" || kind.startsWith("policy.probe")) {
        collapseProbe(ev);
        dispatchWindowEvent(ev);
        return;
      }
      flushBuckets();
      const tone = kind === "task.completed" ? "success" : kind === "task.failed" ? "error" : runId === "policy.probe.run" ? "probe" : "normal";
      enqueueRow(
        makeRow(
          kind,
          kind === "task.completed" ? "Task completed" : kind === "task.failed" ? "Task failed" : "Task event",
          { ts: typeof ev.ts === "number" ? ev.ts : Date.now(), text },
          tone
        )
      );
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
      connectionState = "connecting";
      syncStatus();
      es = new EventSource(SSE_URL);
      es.onopen = () => {
        attempt = 0;
        connectionState = "open";
        syncStatus();
        enqueueRow(
          makeRow(
            "sse.open",
            "Stream connected",
            { ts: Date.now(), text: `Listening on ${SSE_URL}` },
            "normal"
          )
        );
      };
      es.onerror = () => {
        connectionState = "error";
        syncStatus();
        try {
          es.close();
        } catch {
        }
        es = null;
        flushBuckets();
        attempt += 1;
        const delay = Math.min(15e3, 500 * Math.pow(2, Math.min(6, attempt)));
        enqueueRow(
          makeRow(
            "sse.error",
            "Stream reconnecting",
            { ts: Date.now(), text: `Retrying in ${delay}ms` },
            "error"
          )
        );
        setTimeout(connect, delay);
      };
      es.onmessage = (msg) => handleFrame("message", msg.data);
      for (const name of [
        "hello",
        "heartbeat",
        "task.event",
        "task.created",
        "task.completed",
        "task.failed",
        "task.updated",
        "task.status"
      ]) {
        es.addEventListener(name, (e) => handleFrame(name, e.data));
      }
    }
    function boot() {
      ensurePanel();
      connect();
      setInterval(() => {
        if (!document.getElementById(PANEL_ID)) {
          panelReady = false;
          try {
            connect();
          } catch {
          }
        }
      }, 2e3);
      setInterval(() => {
        flushBuckets();
        flushQueue();
      }, 3e3);
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

  // public/js/probe-lifecycle-card.js
  (() => {
    const PANEL_ID = "mb-task-events-panel";
    const FEED_ID = "mb-task-events-feed";
    const CARD_ID = "mb-probe-lifecycle-card";
    const STATE_ID = "mb-probe-lifecycle-state";
    const META_ID = "mb-probe-lifecycle-meta";
    const STEPS_ID = "mb-probe-lifecycle-steps";
    const RUNS_API = "/api/runs";
    const PROBE_RUN_ID = "policy.probe.run";
    const state = {
      runId: PROBE_RUN_ID,
      status: "idle",
      eventCount: 0,
      lastTs: null,
      lastKind: null,
      started: false,
      running: false,
      completed: false,
      failed: false
    };
    function fmtFull(ts) {
      return typeof ts === "number" && Number.isFinite(ts) ? new Date(ts).toLocaleString() : "\u2014";
    }
    function getVisual(status) {
      if (status === "completed") {
        return {
          label: "Completed",
          border: "rgba(34,197,94,0.34)",
          background: "rgba(34,197,94,0.10)",
          badge: "rgba(34,197,94,0.16)"
        };
      }
      if (status === "failed") {
        return {
          label: "Failed",
          border: "rgba(239,68,68,0.34)",
          background: "rgba(239,68,68,0.10)",
          badge: "rgba(239,68,68,0.16)"
        };
      }
      if (status === "running") {
        return {
          label: "Running",
          border: "rgba(99,102,241,0.34)",
          background: "rgba(79,70,229,0.12)",
          badge: "rgba(99,102,241,0.16)"
        };
      }
      if (status === "started") {
        return {
          label: "Started",
          border: "rgba(59,130,246,0.34)",
          background: "rgba(59,130,246,0.10)",
          badge: "rgba(59,130,246,0.16)"
        };
      }
      return {
        label: "Idle",
        border: "rgba(148,163,184,0.24)",
        background: "rgba(255,255,255,0.03)",
        badge: "rgba(148,163,184,0.16)"
      };
    }
    function inferStatusFromKind(kind, currentStatus) {
      const k = String(kind || "");
      if (k === "task.failed" || k === "policy.probe.denied" || k === "policy.probe.blocked" || k === "policy.probe.failed") {
        return "failed";
      }
      if (k === "task.completed" || k === "policy.probe.completed") {
        return "completed";
      }
      if (k === "task.running" || k === "policy.probe.allowed" || k === "policy.probe.running" || k === "policy.probe.visible") {
        return "running";
      }
      if (k === "task.created" || k === "task.started" || k === "policy.probe.started") {
        return "started";
      }
      return currentStatus === "idle" ? "started" : currentStatus;
    }
    function ensureCard() {
      const panel = document.getElementById(PANEL_ID);
      const feed = document.getElementById(FEED_ID);
      if (!panel || !feed) return null;
      let card = document.getElementById(CARD_ID);
      if (card) return card;
      card = document.createElement("section");
      card.id = CARD_ID;
      card.style.margin = "14px 16px 0";
      card.style.border = "1px solid rgba(148,163,184,0.24)";
      card.style.borderRadius = "16px";
      card.style.padding = "12px 14px";
      card.style.background = "rgba(255,255,255,0.03)";
      card.style.boxShadow = "inset 0 1px 0 rgba(255,255,255,0.03)";
      const top = document.createElement("div");
      top.style.display = "flex";
      top.style.alignItems = "center";
      top.style.justifyContent = "space-between";
      top.style.gap = "12px";
      const titleWrap = document.createElement("div");
      titleWrap.style.minWidth = "0";
      const title = document.createElement("div");
      title.textContent = "Probe lifecycle";
      title.style.fontSize = "13px";
      title.style.fontWeight = "700";
      title.style.letterSpacing = "0.02em";
      const badge = document.createElement("div");
      badge.id = STATE_ID;
      badge.style.marginTop = "6px";
      badge.style.display = "inline-flex";
      badge.style.alignItems = "center";
      badge.style.gap = "6px";
      badge.style.padding = "4px 8px";
      badge.style.borderRadius = "999px";
      badge.style.fontSize = "11px";
      badge.style.fontWeight = "700";
      badge.style.letterSpacing = "0.03em";
      badge.textContent = "Idle";
      titleWrap.appendChild(title);
      titleWrap.appendChild(badge);
      const meta = document.createElement("div");
      meta.id = META_ID;
      meta.style.fontSize = "11px";
      meta.style.lineHeight = "1.5";
      meta.style.opacity = "0.78";
      meta.style.textAlign = "right";
      meta.style.whiteSpace = "pre-line";
      meta.textContent = "run policy.probe.run\n0 events \xB7 last activity \u2014\nlast kind \u2014";
      top.appendChild(titleWrap);
      top.appendChild(meta);
      const steps = document.createElement("div");
      steps.id = STEPS_ID;
      steps.style.display = "flex";
      steps.style.flexWrap = "wrap";
      steps.style.gap = "8px";
      steps.style.marginTop = "10px";
      card.appendChild(top);
      card.appendChild(steps);
      panel.insertBefore(card, feed);
      return card;
    }
    function render() {
      const card = ensureCard();
      const badge = document.getElementById(STATE_ID);
      const meta = document.getElementById(META_ID);
      const steps = document.getElementById(STEPS_ID);
      if (!card || !badge || !meta || !steps) return;
      const visual = getVisual(state.status);
      card.style.borderColor = visual.border;
      card.style.background = visual.background;
      badge.textContent = visual.label;
      badge.style.background = visual.badge;
      badge.style.border = `1px solid ${visual.border}`;
      badge.style.color = "rgba(255,255,255,0.95)";
      meta.textContent = `run ${state.runId}
${state.eventCount} events \xB7 last activity ${fmtFull(state.lastTs)}
last kind ${state.lastKind || "\u2014"}`;
      const chips = [
        { label: "Started", done: state.started, active: state.status === "started" },
        { label: "Running", done: state.running, active: state.status === "running" },
        {
          label: state.failed ? "Failed" : "Completed",
          done: state.completed || state.failed,
          active: state.status === "completed" || state.status === "failed"
        }
      ];
      steps.innerHTML = "";
      for (const chip of chips) {
        const el = document.createElement("div");
        el.style.display = "inline-flex";
        el.style.alignItems = "center";
        el.style.gap = "6px";
        el.style.padding = "6px 10px";
        el.style.borderRadius = "999px";
        el.style.fontSize = "11px";
        el.style.fontWeight = "600";
        el.style.letterSpacing = "0.02em";
        el.style.border = "1px solid rgba(148,163,184,0.22)";
        el.style.background = "rgba(255,255,255,0.03)";
        el.style.opacity = chip.done || chip.active ? "1" : "0.72";
        if (chip.active) {
          el.style.borderColor = visual.border;
          el.style.background = visual.badge;
        } else if (chip.done) {
          el.style.borderColor = "rgba(148,163,184,0.30)";
          el.style.background = "rgba(255,255,255,0.06)";
        }
        const dot = document.createElement("span");
        dot.style.display = "inline-block";
        dot.style.width = "8px";
        dot.style.height = "8px";
        dot.style.borderRadius = "999px";
        dot.style.background = chip.done || chip.active ? "rgba(255,255,255,0.92)" : "rgba(148,163,184,0.68)";
        const text = document.createElement("span");
        text.textContent = chip.label;
        el.appendChild(dot);
        el.appendChild(text);
        steps.appendChild(el);
      }
    }
    function updateFromProbeEvent(detail) {
      const runId = String(detail?.run_id ?? detail?.runId ?? "");
      const kind = String(detail?.kind ?? "");
      const isProbe = runId === PROBE_RUN_ID || kind.startsWith("policy.probe");
      if (!isProbe) return;
      state.runId = runId || PROBE_RUN_ID;
      state.eventCount += 1;
      state.lastTs = typeof detail?.ts === "number" ? detail.ts : Date.now();
      state.lastKind = kind || "event";
      state.status = inferStatusFromKind(kind, state.status);
      if (state.status === "started") {
        state.started = true;
      } else if (state.status === "running") {
        state.started = true;
        state.running = true;
      } else if (state.status === "completed") {
        state.started = true;
        state.running = true;
        state.completed = true;
        state.failed = false;
      } else if (state.status === "failed") {
        state.started = true;
        state.running = true;
        state.failed = true;
        state.completed = false;
      }
      render();
    }
    async function hydrateFromRuns() {
      try {
        const res = await fetch(RUNS_API, { credentials: "same-origin" });
        if (!res.ok) return;
        const data = await res.json();
        const rows = Array.isArray(data?.rows) ? data.rows : [];
        const probeRow = rows.find((row) => String(row?.run_id || "") === PROBE_RUN_ID);
        if (!probeRow) {
          render();
          return;
        }
        state.runId = String(probeRow.run_id || PROBE_RUN_ID);
        state.lastTs = Number(probeRow.last_event_ts || Date.now());
        state.lastKind = String(probeRow.last_event_kind || "\u2014");
        state.status = inferStatusFromKind(state.lastKind, state.status);
        if (state.status === "started") {
          state.started = true;
        } else if (state.status === "running") {
          state.started = true;
          state.running = true;
        } else if (state.status === "completed") {
          state.started = true;
          state.running = true;
          state.completed = true;
        } else if (state.status === "failed") {
          state.started = true;
          state.running = true;
          state.failed = true;
        }
        render();
      } catch (_) {
        render();
      }
    }
    function boot() {
      render();
      hydrateFromRuns();
      window.addEventListener("mb.task.event", (event) => updateFromProbeEvent(event.detail));
      const observer = new MutationObserver(() => {
        if (document.getElementById(PANEL_ID) && !document.getElementById(CARD_ID)) {
          render();
        }
      });
      observer.observe(document.documentElement, { childList: true, subtree: true });
      setInterval(() => {
        if (document.getElementById(PANEL_ID)) {
          render();
        }
      }, 3e3);
    }
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", boot, { once: true });
    } else {
      boot();
    }
  })();

  // public/js/phase58c_idle_states.js
  (() => {
    "use strict";
    const REFLECTIONS_TEXT = "Waiting for first reflection";
    const OPS_TEXT = "No agent signals yet";
    const TASKS_TEXT = "Waiting for first task event beyond heartbeat";
    function q(sel, root = document) {
      try {
        return root.querySelector(sel);
      } catch {
        return null;
      }
    }
    function qa(sel, root = document) {
      try {
        return Array.from(root.querySelectorAll(sel));
      } catch {
        return [];
      }
    }
    function ensureInlineStyle() {
      if (document.getElementById("phase58c-idle-style")) return;
      const style = document.createElement("style");
      style.id = "phase58c-idle-style";
      style.textContent = `
      .phase58c-idle-state {
        list-style: none;
        border: 1px solid rgba(255,255,255,0.10);
        background: rgba(255,255,255,0.03);
        border-radius: 12px;
        padding: 12px 14px;
        color: rgba(255,255,255,0.78);
        font-size: 12px;
        line-height: 1.45;
      }
      .phase58c-idle-state strong {
        display: block;
        color: rgba(255,255,255,0.92);
        font-weight: 600;
        margin-bottom: 4px;
      }
      .phase58c-idle-state span {
        display: block;
        color: rgba(255,255,255,0.60);
      }
    `;
      document.head.appendChild(style);
    }
    function buildIdleNode(title, detail, tagName = "li") {
      const el = document.createElement(tagName);
      el.className = "phase58c-idle-state";
      el.setAttribute("data-phase58c-idle", "true");
      const strong = document.createElement("strong");
      strong.textContent = title;
      el.appendChild(strong);
      if (detail) {
        const span = document.createElement("span");
        span.textContent = detail;
        el.appendChild(span);
      }
      return el;
    }
    function listHasRealItems(list) {
      const children = Array.from(list.children || []);
      return children.some((child) => {
        if (!(child instanceof HTMLElement)) return false;
        if (child.dataset.phase58cIdle === "true") return false;
        const text = (child.textContent || "").trim();
        return text.length > 0;
      });
    }
    function ensureIdleList(list, title, detail) {
      if (!list) return;
      ensureInlineStyle();
      const existing = q('[data-phase58c-idle="true"]', list);
      const hasReal = listHasRealItems(list);
      if (hasReal) {
        if (existing) existing.remove();
        return;
      }
      if (existing) {
        existing.querySelector("strong")?.replaceChildren(title);
        const detailNode = existing.querySelector("span");
        if (detailNode) detailNode.textContent = detail;
        return;
      }
      const tagName = list.tagName && /^(UL|OL)$/i.test(list.tagName) ? "li" : "div";
      list.appendChild(buildIdleNode(title, detail, tagName));
    }
    function normalizeSSEIndicatorText() {
      const indicators = [
        q("#ops-sse-indicator .meta"),
        q("#reflections-sse-indicator .meta"),
        q("#phase16-sse-indicator-text"),
        q("#phase16_reflections_status")
      ].filter(Boolean);
      indicators.forEach((node) => {
        const text = (node.textContent || "").trim();
        if (!text) return;
        if (text.includes("disconnected") && text.includes("last: \u2014")) {
          node.textContent = text.replace("disconnected", "idle");
        }
        if (text === "SSE: \u2026") {
          node.textContent = "SSE: idle";
        }
        if (text.toLowerCase().includes("waiting for js")) {
          node.textContent = "reflections: idle";
        }
      });
    }
    function patchReflections() {
      const list = q("#reflections-list") || q('[data-role="reflections-list"]') || q('[data-panel="reflections"] ul') || q("#reflections");
      if (!list) return;
      const empty = q("#reflections-empty") || q('[data-role="reflections-empty"]');
      if (empty) empty.style.display = "none";
      ensureIdleList(
        list,
        REFLECTIONS_TEXT,
        "This panel will populate automatically once the first reflection arrives."
      );
    }
    function patchOps() {
      const list = q("#ops-alerts-list") || q('[data-role="ops-alerts-list"]');
      if (!list) return;
      ensureIdleList(
        list,
        OPS_TEXT,
        "Agent activity will appear here when the operator console receives its first signal."
      );
    }
    function patchRecentTasks() {
      const empty = q('[data-empty="recent-tasks"]');
      if (!empty) return;
      const body = q(".text-xs, .text-sm, p, div", empty);
      if (body && (body.textContent || "").includes("heartbeats")) {
        body.textContent = TASKS_TEXT;
      }
    }
    function applyIdleUX() {
      patchReflections();
      patchOps();
      patchRecentTasks();
      normalizeSSEIndicatorText();
    }
    function boot() {
      applyIdleUX();
      const root = document.body || document.documentElement;
      if (!root) return;
      const observer = new MutationObserver(() => {
        applyIdleUX();
      });
      observer.observe(root, {
        childList: true,
        subtree: true,
        characterData: true
      });
      window.addEventListener("ops.state", applyIdleUX);
      window.addEventListener("reflections.state", applyIdleUX);
      window.addEventListener("mb:ops:update", applyIdleUX);
      window.addEventListener("mb:reflections:update", applyIdleUX);
      window.addEventListener("mb.task.event", applyIdleUX);
    }
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", boot, { once: true });
    } else {
      boot();
    }
  })();

  // public/js/phase58d_operator_console.js
  (() => {
    "use strict";
    const LEGACY_TITLES = /* @__PURE__ */ new Set([
      "System Reflections",
      "Critical Ops Alerts",
      "Task Activity Over Time"
    ]);
    function q(sel, root = document) {
      try {
        return root.querySelector(sel);
      } catch {
        return null;
      }
    }
    function qa(sel, root = document) {
      try {
        return Array.from(root.querySelectorAll(sel));
      } catch {
        return [];
      }
    }
    function text(el) {
      return (el?.textContent || "").replace(/\s+/g, " ").trim();
    }
    function ensureStyles() {
      if (document.getElementById("phase58d-operator-console-style")) return;
      const style = document.createElement("style");
      style.id = "phase58d-operator-console-style";
      style.textContent = `
      body.phase58d-operator-console {
        background:
          radial-gradient(circle at top left, rgba(30,64,175,0.10), transparent 34%),
          linear-gradient(180deg, rgba(2,6,23,0.98), rgba(2,6,23,1));
      }

      body.phase58d-operator-console [data-phase58d-primary="true"] {
        border: 1px solid rgba(96,165,250,0.22) !important;
        box-shadow: 0 14px 40px rgba(2,6,23,0.42);
      }

      body.phase58d-operator-console [data-phase58d-secondary="true"] {
        border: 1px solid rgba(255,255,255,0.08) !important;
      }

      body.phase58d-operator-console [data-phase58d-muted="true"] {
        opacity: 0.72;
      }

      body.phase58d-operator-console [data-phase58d-hidden="true"] {
        display: none !important;
      }

      #phase58d-operator-banner {
        margin: 0 0 18px 0;
        padding: 14px 16px;
        border-radius: 14px;
        border: 1px solid rgba(96,165,250,0.20);
        background: linear-gradient(180deg, rgba(15,23,42,0.92), rgba(15,23,42,0.78));
        box-shadow: 0 12px 30px rgba(2,6,23,0.32);
      }

      #phase58d-operator-banner .eyebrow {
        display: block;
        margin-bottom: 6px;
        font-size: 11px;
        letter-spacing: 0.16em;
        text-transform: uppercase;
        color: rgba(148,163,184,0.92);
      }

      #phase58d-operator-banner .title {
        display: block;
        font-size: 18px;
        font-weight: 700;
        color: rgba(248,250,252,0.98);
      }

      #phase58d-operator-banner .subtitle {
        display: block;
        margin-top: 6px;
        font-size: 13px;
        color: rgba(191,219,254,0.82);
      }

      #phase58d-signal-strip {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-top: 10px;
      }

      #phase58d-signal-strip .chip {
        padding: 6px 10px;
        border-radius: 999px;
        border: 1px solid rgba(255,255,255,0.10);
        background: rgba(255,255,255,0.04);
        font-size: 12px;
        color: rgba(226,232,240,0.92);
      }

      #phase58d-signal-strip .chip strong {
        color: rgba(255,255,255,0.96);
        font-weight: 600;
      }

      #phase16_reflections_panel[data-phase58d-docked="true"] {
        right: 16px !important;
        bottom: 16px !important;
        width: min(420px, 42vw) !important;
        max-height: 28vh !important;
        opacity: 0.78;
      }

      #phase16_reflections_panel[data-phase58d-docked="true"] #phase16_reflections_log {
        max-height: calc(28vh - 44px) !important;
      }
    `;
      document.head.appendChild(style);
    }
    function findMainColumn() {
      const candidates = qa("main, #dashboard, .dashboard, .container, .grid, .layout");
      if (candidates.length) return candidates[0];
      return document.body;
    }
    function findCards() {
      return qa("section, article, .card, .panel, .rounded-lg, .rounded-xl, .rounded-2xl").filter((el) => {
        if (!(el instanceof HTMLElement)) return false;
        const t = text(el);
        return t.length > 0;
      });
    }
    function findCardByTitle(regex) {
      const headings = qa("h1, h2, h3, h4, h5, strong");
      for (const heading of headings) {
        if (regex.test(text(heading))) {
          const card = heading.closest("section, article, .card, .panel, .rounded-lg, .rounded-xl, .rounded-2xl");
          if (card) return card;
        }
      }
      return null;
    }
    function hideLegacyCards() {
      const cards = findCards();
      for (const card of cards) {
        const heading = q("h1, h2, h3, h4, h5, strong", card);
        const title = text(heading);
        if (LEGACY_TITLES.has(title)) {
          card.setAttribute("data-phase58d-hidden", "true");
        }
      }
    }
    function buildBanner() {
      if (document.getElementById("phase58d-operator-banner")) return;
      const host = findCardByTitle(/probe lifecycle|probe event stream|recent tasks|runs/i) || findMainColumn();
      if (!host || !host.parentNode) return;
      const banner = document.createElement("div");
      banner.id = "phase58d-operator-banner";
      banner.innerHTML = `
      <span class="eyebrow">Operator Console</span>
      <span class="title">Probe lifecycle is the primary signal.</span>
      <span class="subtitle">Empty panels are intentional, cold-start safe, and should read as idle rather than broken.</span>
      <div id="phase58d-signal-strip">
        <span class="chip"><strong>Primary:</strong> Probe lifecycle</span>
        <span class="chip"><strong>Secondary:</strong> Event stream</span>
        <span class="chip"><strong>Idle:</strong> Reflections / agent signals</span>
      </div>
    `;
      host.parentNode.insertBefore(banner, host);
    }
    function promotePrimaryCards() {
      const primaryMatchers = [
        /probe lifecycle/i,
        /probe event stream/i,
        /recent tasks/i,
        /^runs$/i
      ];
      const secondaryMatchers = [
        /reflections/i,
        /ops/i,
        /matilda/i,
        /chat/i
      ];
      for (const card of findCards()) {
        const heading = q("h1, h2, h3, h4, h5, strong", card);
        const title = text(heading);
        if (primaryMatchers.some((re) => re.test(title))) {
          card.setAttribute("data-phase58d-primary", "true");
        } else if (secondaryMatchers.some((re) => re.test(title))) {
          card.setAttribute("data-phase58d-secondary", "true");
        }
      }
    }
    function softenIndicators() {
      const ids = [
        "#ops-sse-indicator",
        "#reflections-sse-indicator",
        "#phase16-sse-indicator-text"
      ];
      for (const sel of ids) {
        const el = q(sel);
        if (el) el.setAttribute("data-phase58d-muted", "true");
      }
    }
    function dockReflectionOverlay() {
      const panel = q("#phase16_reflections_panel");
      if (!panel) return;
      panel.setAttribute("data-phase58d-docked", "true");
      const status = q("#phase16_reflections_status", panel);
      if (status) {
        const current = text(status);
        if (!current || /waiting for owner\/consumer|waiting for js|HTML loaded/i.test(current)) {
          status.textContent = "reflections: idle";
        }
      }
    }
    function relabelCoreEngine() {
      const labels = qa("div, span, p");
      for (const el of labels) {
        const t = text(el);
        if (/^Core Engine:/i.test(t) && /Initializing/i.test(t)) {
          el.textContent = "Core Engine: Idle";
          return;
        }
      }
    }
    function apply() {
      ensureStyles();
      document.body.classList.add("phase58d-operator-console");
      buildBanner();
      hideLegacyCards();
      promotePrimaryCards();
      softenIndicators();
      dockReflectionOverlay();
      relabelCoreEngine();
    }
    function boot() {
      apply();
      const observer = new MutationObserver(() => apply());
      observer.observe(document.body || document.documentElement, {
        childList: true,
        subtree: true,
        characterData: true
      });
      window.addEventListener("ops.state", apply);
      window.addEventListener("reflections.state", apply);
      window.addEventListener("mb:ops:update", apply);
      window.addEventListener("mb:reflections:update", apply);
      window.addEventListener("mb.task.event", apply);
    }
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", boot, { once: true });
    } else {
      boot();
    }
  })();

  // public/js/dashboard-bundle-entry.js
  if (typeof window !== "undefined" && typeof window.__DISABLE_OPTIONAL_SSE === "undefined") {
    window.__DISABLE_OPTIONAL_SSE = false;
  }
})();
//# sourceMappingURL=bundle.js.map
