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

  // public/js/task-events-sse-listener.js
  (function() {
    const URL = "/events/task-events";
    const MAX_ITEMS = 200;
    if (typeof window === "undefined" || typeof document === "undefined") return;
    if (window.__TASK_EVENTS_SSE_INITED) return;
    window.__TASK_EVENTS_SSE_INITED = true;
    function nowIso() {
      try {
        return (/* @__PURE__ */ new Date()).toISOString();
      } catch {
        return String(Date.now());
      }
    }
    function ensureBuffer() {
      if (!window.__TASK_EVENTS_FEED) window.__TASK_EVENTS_FEED = [];
      return window.__TASK_EVENTS_FEED;
    }
    function ensureSnapshot() {
      if (!window.__TASK_EVENTS) {
        window.__TASK_EVENTS = {
          url: URL,
          connected: false,
          lastAt: 0,
          lastEvent: null,
          cursor: null,
          readyState: null
        };
      }
      return window.__TASK_EVENTS;
    }
    function pushItem(item) {
      const buf = ensureBuffer();
      buf.push(item);
      if (buf.length > MAX_ITEMS) buf.splice(0, buf.length - MAX_ITEMS);
      const snap = ensureSnapshot();
      snap.lastAt = item.ts || Date.now();
      snap.lastEvent = item.event || item.kind || null;
      if (item?.data && typeof item.data === "object" && "cursor" in item.data) {
        snap.cursor = item.data.cursor ?? snap.cursor;
      }
      try {
        snap.readyState = window.__taskEventsES?.readyState ?? null;
      } catch {
      }
      try {
        window.dispatchEvent(new CustomEvent("task-events:append", { detail: item }));
      } catch {
      }
    }
    function safeJson(s) {
      try {
        return JSON.parse(s);
      } catch {
        return null;
      }
    }
    function ensureMiniPanel() {
      if (document.getElementById("task-events-log")) return;
      const wrap = document.createElement("div");
      wrap.id = "task-events-log";
      wrap.style.position = "fixed";
      wrap.style.right = "14px";
      wrap.style.bottom = "14px";
      wrap.style.width = "440px";
      wrap.style.maxHeight = "240px";
      wrap.style.overflow = "hidden";
      wrap.style.padding = "10px 12px";
      wrap.style.borderRadius = "12px";
      wrap.style.fontFamily = "ui-monospace, Menlo, Monaco, Consolas, monospace";
      wrap.style.fontSize = "12px";
      wrap.style.lineHeight = "1.35";
      wrap.style.zIndex = "99999";
      wrap.style.background = "rgba(10,10,14,0.72)";
      wrap.style.border = "1px solid rgba(255,255,255,0.12)";
      wrap.style.boxShadow = "0 10px 24px rgba(0,0,0,0.35)";
      wrap.style.backdropFilter = "blur(6px)";
      wrap.style.display = "block";
      const hdr = document.createElement("div");
      hdr.style.display = "flex";
      hdr.style.alignItems = "center";
      hdr.style.justifyContent = "space-between";
      hdr.style.gap = "10px";
      hdr.style.marginBottom = "8px";
      const title = document.createElement("div");
      title.id = "task-events-log-title";
      title.textContent = "TASK EVENTS \xB7 disconnected";
      title.style.letterSpacing = "0.12em";
      title.style.fontWeight = "700";
      title.style.opacity = "0.9";
      const btn = document.createElement("button");
      btn.type = "button";
      btn.textContent = "expand";
      btn.style.cursor = "pointer";
      btn.style.border = "1px solid rgba(255,255,255,0.15)";
      btn.style.background = "rgba(255,255,255,0.08)";
      btn.style.color = "rgba(255,255,255,0.9)";
      btn.style.borderRadius = "10px";
      btn.style.padding = "4px 8px";
      btn.style.fontSize = "12px";
      const body = document.createElement("div");
      body.id = "task-events-log-body";
      body.style.maxHeight = "190px";
      body.style.overflow = "auto";
      body.style.display = "none";
      btn.onclick = () => {
        const on = body.style.display === "none";
        body.style.display = on ? "block" : "none";
        btn.textContent = on ? "collapse" : "expand";
      };
      hdr.appendChild(title);
      hdr.appendChild(btn);
      wrap.appendChild(hdr);
      wrap.appendChild(body);
      document.body.appendChild(wrap);
      if (window.__UI_DEBUG || window.__PHASE21_SHOW_TASK_EVENTS) {
        body.style.display = "block";
        btn.textContent = "collapse";
      }
    }
    function appendLine(text) {
      const body = document.getElementById("task-events-log-body");
      if (!body) return;
      const div = document.createElement("div");
      div.style.whiteSpace = "pre-wrap";
      div.style.wordBreak = "break-word";
      div.textContent = text;
      body.appendChild(div);
      while (body.childNodes.length > 140) body.removeChild(body.firstChild);
      body.scrollTop = body.scrollHeight;
    }
    function setHeaderStatus(text) {
      const t = document.getElementById("task-events-log-title");
      if (t) t.textContent = text;
    }
    function start() {
      ensureMiniPanel();
      ensureSnapshot();
      const es = new EventSource(URL);
      window.__taskEventsES = es;
      es.onopen = () => {
        const snap = ensureSnapshot();
        snap.connected = true;
        snap.readyState = es.readyState;
        const item = { ts: Date.now(), iso: nowIso(), kind: "sse.open", event: "open", url: URL };
        pushItem(item);
        setHeaderStatus("TASK EVENTS \xB7 connected");
        appendLine(`[${item.iso}] open ${URL}`);
      };
      es.onerror = () => {
        const snap = ensureSnapshot();
        snap.connected = false;
        snap.readyState = es.readyState;
        const item = { ts: Date.now(), iso: nowIso(), kind: "sse.error", event: "error", url: URL, readyState: es.readyState };
        pushItem(item);
        setHeaderStatus(`TASK EVENTS \xB7 error (readyState=${es.readyState})`);
        appendLine(`[${item.iso}] error readyState=${es.readyState}`);
      };
      es.onmessage = (ev) => {
        const payload = safeJson(ev.data);
        const item = { ts: Date.now(), iso: nowIso(), kind: "message", event: "message", data: payload ?? ev.data };
        pushItem(item);
        appendLine(`[${item.iso}] message :: ${payload ? JSON.stringify(payload) : String(ev.data)}`);
      };
      const names = [
        "hello",
        "heartbeat",
        "task.event",
        "task.lifecycle",
        "task.created",
        "task.updated",
        "task.completed",
        "task.failed",
        "error"
      ];
      for (const name of names) {
        try {
          es.addEventListener(name, (ev) => {
            const payload = safeJson(ev.data);
            const item = { ts: Date.now(), iso: nowIso(), kind: "event", event: name, data: payload ?? ev.data };
            pushItem(item);
            appendLine(`[${item.iso}] ${name} :: ${payload ? JSON.stringify(payload) : String(ev.data)}`);
          });
        } catch {
        }
      }
    }
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", start, { once: true });
    } else {
      start();
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
              ${["complete", "completed", "done"].includes(String(t.status || "").toLowerCase()) ? `<span style="opacity:.5;font-size:12px">Completed</span>` : `<button data-id="${t.id}">Complete</button>`}
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
      panel.style.fontFamily = "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace";
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
      title.textContent = "TASK EVENTS (live)";
      title.style.fontSize = "12px";
      title.style.letterSpacing = "0.08em";
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
    function formatLine(ev, fallbackKind) {
      const ts = typeof ev.ts === "number" ? new Date(ev.ts).toISOString() : (/* @__PURE__ */ new Date()).toISOString();
      const tid = ev.task_id ?? ev.id ?? ev.taskId ?? "unknown";
      const run = ev.run_id ?? ev.runId ?? "";
      const msg = ev.msg ?? ev.message ?? "";
      const extras = [];
      if (run) extras.push(`run=${run}`);
      if (ev.actor) extras.push(`actor=${ev.actor}`);
      if (ev.status) extras.push(`status=${ev.status}`);
      if (typeof ev.cursor === "number") extras.push(`cursor=${ev.cursor}`);
      const extraStr = extras.length ? ` (${extras.join(" ")})` : "";
      return `${ts}  ${ev.kind ?? fallbackKind ?? "event"}  task=${tid}${extraStr}${msg ? " \u2014 " + msg : ""}`;
    }
    function appendLine(text, kind) {
      ensurePanel();
      const feed = document.getElementById(FEED_ID);
      if (!feed) return;
      const row = document.createElement("div");
      row.style.whiteSpace = "pre-wrap";
      row.style.wordBreak = "break-word";
      row.style.fontSize = "11px";
      row.style.lineHeight = "1.35";
      row.style.padding = "6px 8px";
      row.style.border = "1px solid rgba(255,255,255,0.10)";
      row.style.borderRadius = "12px";
      row.style.marginBottom = "8px";
      row.style.background = "rgba(255,255,255,0.03)";
      if (kind === "task.completed") row.style.borderColor = "rgba(80,200,120,0.35)";
      if (kind === "task.failed") row.style.borderColor = "rgba(240,90,90,0.35)";
      if (kind === "heartbeat") row.style.opacity = "0.65";
      row.textContent = text;
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
      if (!ev.kind) ev.kind = eventName;
      const key = `${eventName}|${ev.kind}|${ev.ts ?? ""}|${ev.task_id ?? ev.id ?? ""}|${ev.run_id ?? ""}|${ev.cursor ?? ""}`;
      if (seen.has(key)) return;
      seen.add(key);
      if (ev.kind === "task.created" || ev.kind === "task.completed" || ev.kind === "task.failed") {
        bumpCounts(String(ev.kind));
      }
      appendLine(formatLine(ev, eventName), String(ev.kind ?? eventName));
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
        appendLine(`${(/* @__PURE__ */ new Date()).toISOString()}  sse.open  url=${url}`, "sse.open");
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
        appendLine(`${(/* @__PURE__ */ new Date()).toISOString()}  sse.error  reconnect_in=${delay}ms`, "sse.error");
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
      return ev?.task_id ?? ev?.taskId ?? ev?.id ?? ev?.task?.id ?? null;
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
          console.log("[phase22] mb.task.event", e.detail);
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
