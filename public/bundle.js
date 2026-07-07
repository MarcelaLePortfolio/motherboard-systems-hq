(() => {
  // public/js/sse-heartbeat-shim.js
  (function() {
    const w = window;
    if (w.__PHASE16_SSE_OWNER_STARTED) return;
    w.__PHASE16_SSE_OWNER_STARTED = true;
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
    "use strict";
    const container = document.getElementById("agent-status-container");
    if (!container) {
      console.warn("agent-status-row.js: #agent-status-container not found.");
      return;
    }
    const AGENTS = ["Matilda", "Atlas", "Cade", "Effie"];
    const AGENT_EMOJI = {
      Matilda: "\u{1F5E3}\uFE0F",
      Atlas: "\u{1F9ED}",
      Cade: "\u{1F4BB}",
      Effie: "\u{1F4CA}"
    };
    function normalizeStatus(value) {
      return String(value || "unknown").trim().toLowerCase();
    }
    function statusClass(status) {
      const s = normalizeStatus(status);
      if (s === "online" || s === "active" || s === "running") return "text-emerald-300/90";
      if (s === "offline" || s === "stopped") return "text-slate-300/75";
      if (s === "error" || s === "failed") return "text-rose-300/90";
      return "text-amber-200/90";
    }
    function render(data = {}) {
      const agents = Object.keys(data || {});
      const healthy = agents.length > 0;
      window.__AGENT_POOL_HEALTH = healthy;
      window.__AGENT_POOL_LAST_CHECK = Date.now();
      const time = (/* @__PURE__ */ new Date()).toLocaleTimeString();
      const healthDot = healthy ? `<span title="Live \u2022 Last check: ${time}" style="margin-left:8px;color:#34d399;font-size:12px;">\u25CF</span>` : `<span title="No data \u2022 Last check: ${time}" style="margin-left:8px;color:#f87171;font-size:12px;">\u25CB</span>`;
      const rows = AGENTS.map((name) => {
        const raw = data[name] || {};
        const status = typeof raw === "string" ? raw : raw.status || "unknown";
        return `
        <div class="w-full min-h-0 rounded-md bg-gray-900 border border-gray-700 px-3 py-1.5 flex items-center justify-between shadow-sm">
          <div class="flex items-center gap-3 min-w-0 h-[18px]">
            <span style="width:18px;min-width:18px;height:18px;font-size:14px;">${AGENT_EMOJI[name] || "\u2022"}</span>
            <span class="text-[13px] font-semibold text-slate-100 truncate">${name}</span>
          </div>
          <span class="text-[11px] font-medium ${statusClass(status)}">${status}</span>
        </div>
      `;
      }).join("");
      container.innerHTML = `
      <h2 class="text-xl font-semibold border-b border-gray-700 pb-2 mb-4">
        Agent Pool ${healthDot}
      </h2>
      <div class="w-full flex flex-col gap-1">
        ${rows}
      </div>
    `;
    }
    async function refresh() {
      try {
        const res = await fetch("/api/agent-status", { cache: "no-store" });
        const data = await res.json();
        render(data);
      } catch (err) {
        console.warn("agent-status-row.js: failed to fetch /api/agent-status", err);
        render({});
      }
    }
    render({});
    refresh();
    window.setInterval(refresh, 15e3);
    window.addEventListener("mb.agent.status", (e) => {
      if (!e?.detail) return;
      render(e.detail);
    });
    window.__AGENT_POOL_RENDERER_LOCKED = true;
    console.log("[agent-status-row] live health indicator with timestamp active");
  })();

  // public/js/dashboard-broadcast.js
  (function() {
    console.log("[broadcast] disabled in UI stabilization mode");
  })();

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
    let inFlight = false;
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
        sendBtn.textContent = isSending ? "Sending..." : "Send";
      }
      if (input) input.disabled = isSending;
    }
    async function fetchWithTimeout(url, options, timeoutMs) {
      const controller = new AbortController();
      const id = setTimeout(() => controller.abort(), timeoutMs);
      try {
        console.log("[PHASE488_TIMEOUT] starting fetch");
        const res = await fetch(url, { ...options, signal: controller.signal });
        console.log("[PHASE488_TIMEOUT] resolved", res.status);
        return res;
      } finally {
        clearTimeout(id);
      }
    }
    async function wireChat() {
      var transcript = document.getElementById("matilda-chat-transcript");
      var input = document.getElementById("matilda-chat-input");
      var sendBtn = document.getElementById("matilda-chat-send");
      if (!transcript || !input || !sendBtn) return;
      async function handleSend() {
        console.log("[PHASE488_TRACE] handleSend invoked");
        if (inFlight) {
          console.warn("[PHASE488_GUARD] blocked duplicate send");
          return;
        }
        var message = (input.value || "").trim();
        if (!message) return;
        inFlight = true;
        appendMessage(transcript, "You", message);
        input.value = "";
        setSendingState(sendBtn, input, true);
        try {
          const res = await fetchWithTimeout("/api/chat", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ message, agent: "matilda" })
          }, 5e3);
          const data = await res.json();
          console.log("[PHASE488_TRACE] parsed json", data);
          const reply = data && (data.reply || data.message || data.response) || "(no reply)";
          appendMessage(transcript, "Matilda", reply);
        } catch (err) {
          appendMessage(transcript, "Matilda", "I could not reach the chat service from this browser request, but no execution was attempted. You can retry, or use the visible dashboard/context state for advisory interpretation.");
        } finally {
          inFlight = false;
          setSendingState(sendBtn, input, false);
        }
      }
      sendBtn.onclick = handleSend;
      var quickBtn = document.getElementById("matilda-chat-quick-check");
      if (quickBtn) {
        quickBtn.onclick = function() {
          input.value = "Quick systems check from dashboard.";
          handleSend();
        };
      }
      input.onkeydown = function(e) {
        if (e.key === "Enter" && !e.shiftKey) {
          e.preventDefault();
          handleSend();
        }
      };
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
        setError(err && (err as any).message ? (err as any).message : String(err));
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
  (function() {
    const STREAM_URL = "/events/task-events?cursor=0";
    const ROOT_ID = "mb-task-events-panel-anchor";
    if (window.__TASK_EVENTS_SSE_CLIENT_ACTIVE__) return;
    window.__TASK_EVENTS_SSE_CLIENT_ACTIVE__ = true;
    const events = [];
    const seen = /* @__PURE__ */ new Set();
    const titlesByTaskId = /* @__PURE__ */ new Map();
    const maxEvents = 80;
    function root() {
      return document.getElementById(ROOT_ID);
    }
    function escapeHtml(v) {
      return String(v ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;");
    }
    function parse(raw) {
      try {
        return JSON.parse(raw);
      } catch {
        return null;
      }
    }
    function payload(e) {
      return e && e.payload && typeof e.payload === "object" ? e.payload : {};
    }
    function shortId(v) {
      const s = String(v || "");
      return s.length > 18 ? s.slice(0, 10) + "\u2026" + s.slice(-6) : s;
    }
    function formatTime(v) {
      const d = new Date(Number(v) || v);
      return Number.isNaN(d.getTime()) ? String(v || "") : d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
    }
    function resolveTitle(e) {
      const taskId = e.task_id || e.taskId || "";
      const p = payload(e);
      const t = e.title || p.title || e.message || p.message || e.detail || p.detail || "";
      if (t && !String(t).startsWith("{")) {
        titlesByTaskId.set(taskId, t);
        return t;
      }
      return titlesByTaskId.get(taskId) || "Untitled task";
    }
    function contextText(e) {
      const kind = e.kind || "task.event";
      const p = payload(e);
      const retryMode = p.retry_mode || "";
      const executionMode = p.execution_mode || "";
      const isFresh = retryMode === "fresh-context" || executionMode === "rebuild_context";
      const isRetry = retryMode || p.retry_of_task_id;
      if (kind === "task.completed" && isFresh) return "Retry executed with fresh context and completed successfully.";
      if (kind === "task.completed" && isRetry) return "Retry executed and completed successfully.";
      if (kind === "task.completed") return "Task completed successfully.";
      if (kind === "task.created" && isFresh) return "Retry entered the pipeline with fresh-context routing.";
      if (kind === "task.created" && isRetry) return "Retry entered the execution pipeline.";
      if (kind === "task.created") return "Task entered the execution pipeline.";
      if (kind === "task.failed" && isRetry) return "Retry failed during execution.";
      if (kind === "task.failed") return "Task failed during execution.";
      if (kind === "task.started") return "Worker started processing this task.";
      return "System event recorded.";
    }
    async function delegateTask(body) {
      try {
        const res = await fetch("/api/delegate-task", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(body)
        });
        return await res.json();
      } catch (err) {
        console.error("delegateTask failed", err);
      }
    }
    function wireActions(container, e) {
      const taskId = e.task_id || e.taskId;
      const title = resolveTitle(e);
      container.querySelector('[data-action="copy-id"]')?.addEventListener("click", (event) => {
        event.preventDefault();
        event.stopPropagation();
        navigator.clipboard.writeText(taskId);
      });
      container.querySelector('[data-action="requeue"]')?.addEventListener("click", (event) => {
        event.preventDefault();
        event.stopPropagation();
        delegateTask({
          title,
          kind: "retry",
          source: "execution-inspector",
          meta: {
            retry_of_task_id: taskId,
            retry_mode: "standard"
          },
          strategy: "standard"
        });
      });
      container.querySelector('[data-action="retry"]')?.addEventListener("click", (event) => {
        event.preventDefault();
        event.stopPropagation();
        delegateTask({
          title,
          kind: "retry",
          source: "execution-inspector",
          meta: {
            retry_of_task_id: taskId,
            retry_mode: "fresh-context"
          },
          strategy: "fresh-context"
        });
      });
    }
    function render(state) {
      const el = root();
      if (!el) return;
      const rows = events.map((e, i) => {
        const kind = e.kind || "task.event";
        const taskId = e.task_id || e.taskId || "";
        const runId = e.run_id || e.runId || "";
        const ts = e.created_at || e.ts || Date.now();
        const title = resolveTitle(e);
        const json = JSON.stringify(e, null, 2);
        return `
<details data-idx="${i}" style="border-top:1px solid rgba(148,163,184,.2); padding:16px 0;">
  <summary style="list-style:none; cursor:pointer; display:grid; grid-template-columns:120px 1fr; gap:16px; padding-left:12px;">
    <div>
      <div style="color:${kind === "task.completed" ? "#86efac" : "#93c5fd"}; font-weight:700;">
        ${kind.replace("task.", "")}
      </div>
      <div style="color:#64748b; font-size:12px;">${formatTime(ts)}</div>
    </div>

    <div>
      <div style="font-weight:700;">${escapeHtml(title)}</div>
      <div style="margin-top:8px; display:flex; gap:16px;">
        <span data-action="copy-id" style="color:#86efac; cursor:pointer;">Copy ID</span>
        <span data-action="requeue" style="color:#facc15; cursor:pointer;">Requeue</span>
        <span data-action="retry" style="color:#60a5fa; cursor:pointer;">Retry</span>
      </div>
    </div>
  </summary>

  <div style="width:92%; margin:14px auto 0 auto; background:#111827; border:1px solid #334155; border-radius:12px; padding:16px;">
    <div>${escapeHtml(contextText(e))}</div>

    <div style="margin-top:8px; color:#a78bfa; font-family:monospace;">
      task=${escapeHtml(shortId(taskId))} ${runId ? "\u2022 run=" + escapeHtml(shortId(runId)) : ""}
    </div>

    <details style="margin-top:10px;">
      <summary style="cursor:pointer;">Advanced \u25B8</summary>
      <pre style="margin-top:8px; font-size:11px;">${escapeHtml(json)}</pre>
    </details>
  </div>
</details>
      `;
      }).join("");
      el.innerHTML = `
      <div style="display:flex; justify-content:space-between; margin-bottom:12px;">
        <span>Execution Inspector: ${escapeHtml(state)}</span>
        <span>${events.length} events</span>
      </div>
      ${rows}
    `;
      document.querySelectorAll("details[data-idx]").forEach((node) => {
        const idx = Number(node.getAttribute("data-idx"));
        wireActions(node, events[idx]);
      });
    }
    function ingest(raw, type) {
      if (type === "hello") {
        render("Connected \u2014 watching task stream");
        return;
      }
      if (type === "heartbeat") {
        render("Connected \u2014 watching task stream");
        return;
      }
      const e = parse(raw);
      if (!e) return;
      e.kind = e.kind || type;
      const taskId = e.task_id || e.taskId;
      if (!taskId) return;
      const id = e.id || `${e.kind}:${taskId}`;
      if (seen.has(id)) return;
      seen.add(id);
      events.unshift(e);
      if (events.length > maxEvents) events.length = maxEvents;
      render("Connected");
    }
    function start() {
      render("Connecting");
      const es = new EventSource(STREAM_URL);
      es.onopen = () => render("Connected \u2014 watching task stream");
      es.onerror = () => {
        if (events.length > 0) {
          render("Connected \u2014 stream reconnecting");
        } else {
          render("Connected \u2014 awaiting next task event");
        }
      };
      es.onmessage = (e) => ingest(e.data, "message");
      ["task.created", "task.started", "task.completed", "task.failed"].forEach((t) => {
        es.addEventListener(t, (e) => ingest(e.data, t));
      });
    }
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", start, { once: true });
    } else {
      start();
    }
  })();

  // public/js/phase22_task_delegation_live_bindings.js
  (() => {
    const TASK_EVENT_NAME = "mb.task.event";
    const tasks = /* @__PURE__ */ new Map();
    const runningTaskIds = /* @__PURE__ */ new Set();
    const terminalTaskIds = /* @__PURE__ */ new Set();
    const completedTaskIds = /* @__PURE__ */ new Set();
    const failedTaskIds = /* @__PURE__ */ new Set();
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
    function isTerminalKind(kind) {
      const v = String(kind ?? "").toLowerCase();
      return v === "task.completed" || v === "task.failed" || v === "task.cancelled" || v === "task.canceled";
    }
    function isRunningKind(kind) {
      const v = String(kind ?? "").toLowerCase();
      return v === "task.created" || v === "task.started" || v === "task.running";
    }
    function isSuccessKind(kind) {
      const v = String(kind ?? "").toLowerCase();
      return v === "task.completed";
    }
    function isFailureKind(kind) {
      const v = String(kind ?? "").toLowerCase();
      return v === "task.failed" || v === "task.cancelled" || v === "task.canceled";
    }
    function isTerminalStatus(status) {
      const v = normStatus(status);
      return v === "done" || v === "failed" || v === "cancelled" || v === "canceled" || v === "complete" || v === "completed" || v === "error";
    }
    function isSuccessStatus(status) {
      const v = normStatus(status);
      return v === "done" || v === "complete" || v === "completed";
    }
    function isFailureStatus(status) {
      const v = normStatus(status);
      return v === "failed" || v === "cancelled" || v === "canceled" || v === "error";
    }
    function isRunningStatus(status) {
      const v = normStatus(status);
      return v === "queued" || v === "pending" || v === "running" || v === "started" || v === "active" || v === "in_progress" || v === "in-progress";
    }
    function updateRunningTaskDerivation(ev, task) {
      const id = task?.id ? String(task.id) : null;
      if (!id) return;
      const kind = String(ev?.kind ?? "").toLowerCase();
      const status = task?.status ?? ev?.status ?? ev?.payload?.status ?? ev?.task?.status ?? null;
      if (terminalTaskIds.has(id)) {
        runningTaskIds.delete(id);
        return;
      }
      if (isTerminalKind(kind) || isTerminalStatus(status)) {
        runningTaskIds.delete(id);
        terminalTaskIds.add(id);
        return;
      }
      if (isRunningKind(kind) || isRunningStatus(status)) {
        runningTaskIds.add(id);
      }
    }
    function updateCompletedTaskDerivation(ev, task) {
      const id = task?.id ? String(task.id) : null;
      if (!id) return;
      const kind = String(ev?.kind ?? "").toLowerCase();
      const status = task?.status ?? ev?.status ?? ev?.payload?.status ?? ev?.task?.status ?? null;
      if (completedTaskIds.has(id)) return;
      if (isFailureKind(kind) || isFailureStatus(status)) return;
      if (isSuccessKind(kind) || isSuccessStatus(status)) {
        completedTaskIds.add(id);
      }
    }
    function updateFailedTaskDerivation(ev, task) {
      const id = task?.id ? String(task.id) : null;
      if (!id) return;
      const kind = String(ev?.kind ?? "").toLowerCase();
      const status = task?.status ?? ev?.status ?? ev?.payload?.status ?? ev?.task?.status ?? null;
      if (failedTaskIds.has(id)) return;
      if (isSuccessKind(kind) || isSuccessStatus(status)) return;
      if (isFailureKind(kind) || isFailureStatus(status)) {
        failedTaskIds.add(id);
      }
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
      const nodes = [
        document.getElementById(`task-${id}`),
        document.getElementById(`task_${id}`),
        document.querySelector?.(`[data-task-id="${CSS.escape(id)}"]`),
        document.querySelector?.(`[data-taskid="${CSS.escape(id)}"]`)
      ].filter(Boolean);
      for (const n of nodes) setStatusOnNode(n, task.status);
    }
    function updateCounterNode(key, value) {
      const el = document.getElementById(`task-count-${key}`) || document.getElementById(`tasks-${key}-count`) || document.querySelector?.(`[data-task-count="${key}"]`) || null;
      if (el) el.textContent = String(value);
    }
    function updateCountersUI() {
      let queued = 0;
      let done = 0;
      let failed = 0;
      for (const t of tasks.values()) {
        const s = normStatus(t.status);
        if (s === "queued") queued++;
        else if (s === "done") done++;
        else if (s === "failed") failed++;
      }
      updateCounterNode("queued", queued);
      updateCounterNode("done", done);
      updateCounterNode("failed", failed);
      updateCounterNode("running", runningTaskIds.size);
      updateCounterNode("completed", completedTaskIds.size);
      updateCounterNode("failed-terminal", failedTaskIds.size);
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
      updateRunningTaskDerivation(ev, t);
      updateCompletedTaskDerivation(ev, t);
      updateFailedTaskDerivation(ev, t);
      if (t.id) ingestTask(t);
      else updateCountersUI();
    }
    function attach() {
      if (window.__PHASE22_TASK_UI_BOUND) return;
      window.__PHASE22_TASK_UI_BOUND = true;
      window.addEventListener(TASK_EVENT_NAME, (e) => {
        try {
          if (window.__UI_DEBUG || window.__PHASE22_DEBUG) {
            console.log("[phase22] mb.task.event", e.detail);
          }
          onTaskEvent(e.detail);
        } catch {
        }
      });
      window.__PHASE22_TASK_UI = {
        tasks,
        runningTaskIds,
        terminalTaskIds,
        completedTaskIds,
        failedTaskIds,
        getRunningTasksCount: () => runningTaskIds.size,
        getCompletedTasksCount: () => completedTaskIds.size,
        getFailedTasksCount: () => failedTaskIds.size
      };
      console.log("[phase22] bindings attached");
    }
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", attach, { once: true });
    } else {
      attach();
    }
  })();

  // public/js/telemetry/phase65b_metric_bootstrap.js
  (function() {
    function load(src) {
      try {
        var existing = document.querySelector('script[data-telemetry-src="' + src + '"]');
        if (existing) return;
        var script = document.createElement("script");
        script.src = src;
        script.async = false;
        script.defer = false;
        script.dataset.telemetrySrc = src;
        document.head.appendChild(script);
      } catch (err) {
        console.error("[telemetry-bootstrap] failed to load:", src, err);
      }
    }
    function start() {
      load("/js/telemetry/phase65b_metric_ownership_guard.js");
      load("/js/telemetry/running_tasks_metric.js");
      load("/js/telemetry/success_rate_metric.js");
      load("/js/telemetry/latency_metric.js");
      load("/js/telemetry/queue_latency_metric.js");
    }
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", start, { once: true });
    } else {
      start();
    }
  })();

  // public/js/planning-preview-card.js
  (() => {
    "use strict";
    if (window.__PLANNING_PREVIEW_CARD_ACTIVE__) return;
    window.__PLANNING_PREVIEW_CARD_ACTIVE__ = true;
    const ENDPOINT = "/api/governed-planning/dry-run";
    let latestBundle = null;
    function escapeHtml(value) {
      return String(value ?? "").replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;").replaceAll("'", "&#039;");
    }
    function boolLabel(value) {
      return value === true ? "true" : "false";
    }
    function statusPill(label, ok) {
      return `

      <div class="flex items-center justify-between rounded-lg border border-gray-800 bg-gray-950/50 px-3 py-2">

        <span class="text-xs text-gray-300">${escapeHtml(label)}</span>

        <span class="text-[10px] uppercase tracking-[0.16em] ${ok ? "text-green-300" : "text-gray-500"}">

          ${ok ? "ok" : "false"}

        </span>

      </div>

    `;
    }
    function renderTrace(trace = []) {
      if (!Array.isArray(trace) || trace.length === 0) {
        return '<div class="text-xs text-gray-500">No trace events returned.</div>';
      }
      return trace.map((entry, index) => `

      <div class="flex items-center justify-between gap-3 rounded-lg border border-gray-800 bg-gray-950/50 px-3 py-2">

        <span class="text-xs text-gray-300">${index + 1}. ${escapeHtml(entry.event || "unknown_event")}</span>

        <span class="text-[10px] uppercase tracking-[0.16em] ${entry.ok === true ? "text-green-300" : "text-red-300"}">

          ${entry.ok === true ? "ok" : "blocked"}

        </span>

      </div>

    `).join("");
    }
    function renderSummary(bundle) {
      if (!bundle) {
        return `

        <div class="rounded-xl border border-yellow-700/60 bg-yellow-950/20 p-3 text-sm text-yellow-200">

          No governed planning bundle was returned.

        </div>

      `;
      }
      const response = bundle.response || {};
      const authority = bundle.execution_authority || {};
      const governanceOk = response.governance?.ok === true;
      const planningDone = bundle.phase === "planning_completed";
      const approvalGateOk = response.approval_gate?.ok === true;
      const anyExecutionAuthority = authority.mutation_performed === true || authority.shell_execution_performed === true || authority.autonomous_execution_performed === true;
      return `

      <div class="space-y-3">

        <div class="rounded-xl border border-purple-700/50 bg-purple-950/20 p-3">

          <div class="flex items-start justify-between gap-3">

            <div>

              <div class="text-xs uppercase tracking-[0.2em] text-purple-300">Governed Planning Artifact</div>

              <div class="mt-1 text-sm text-gray-200">${escapeHtml(bundle.phase || "planning")}</div>

            </div>

          </div>

        </div>

        <div class="grid gap-2 md:grid-cols-2">

          ${statusPill("Governance", governanceOk)}

          ${statusPill("Planning", planningDone)}

          ${statusPill("Approval gate", approvalGateOk)}

          ${statusPill("Execution authority", anyExecutionAuthority)}

        </div>

        <button

          id="planning-preview-open-modal"

          type="button"

          class="w-full rounded-xl border border-purple-700/60 bg-purple-900/30 px-4 py-2 text-sm font-semibold text-purple-100 hover:bg-purple-800/40 focus:outline-none focus:ring-2 focus:ring-purple-500"

        >

          Open Planning Preview

        </button>

      </div>

    `;
    }
    function renderModalBody(bundle) {
      if (!bundle) {
        return '<div class="text-sm text-yellow-200">No governed planning bundle loaded.</div>';
      }
      const response = bundle.response || {};
      const reconciliation = bundle.reconciliation || {};
      const auditLedger = bundle.audit_ledger || {};
      const authority = bundle.execution_authority || {};
      const immutable = auditLedger.immutable_constraints || {};
      const trace = reconciliation.trace || response.trace || [];
      const entries = Array.isArray(reconciliation.reconciliation_entries) ? reconciliation.reconciliation_entries : [];
      const governanceOk = response.governance?.ok === true;
      const approvalGateOk = response.approval_gate?.ok === true;
      const cadePlanningOk = response.cade_planning?.ok === true;
      return `

      <div class="space-y-4">

        <section class="rounded-xl border border-purple-700/50 bg-purple-950/20 p-4">

          <h4 class="text-sm font-semibold text-purple-200">What this is</h4>

          <p class="mt-2 text-sm leading-6 text-gray-200">

            This is a read-only planning preview. It shows that Motherboard created a governed planning artifact,

            checked it through the current governance path, and kept it in planning-only mode.

          </p>

          <p class="mt-2 text-sm leading-6 text-gray-300">

            It does not approve execution. It does not run Cade. It does not modify files.

          </p>

        </section>

        <section class="rounded-xl border border-gray-800 bg-gray-950/50 p-4">

          <h4 class="text-sm font-semibold text-gray-100">Plain-language status</h4>

          <div class="mt-3 space-y-2">

            ${statusPill("Governance checks passed", governanceOk)}

            ${statusPill("Planning artifact created", bundle.phase === "planning_completed")}

            ${statusPill("Approval gate evaluated", approvalGateOk)}

            ${statusPill("Cade planning completed", cadePlanningOk)}

          </div>

        </section>

        <section class="rounded-xl border border-gray-800 bg-gray-950/50 p-4">

          <h4 class="text-sm font-semibold text-gray-100">What is allowed right now</h4>

          <div class="mt-3 grid gap-2 md:grid-cols-3">

            <div class="rounded-lg border border-gray-800 bg-black/30 p-3 text-sm text-gray-200">

              File changes<br><span class="text-green-300">Not authorized</span>

            </div>

            <div class="rounded-lg border border-gray-800 bg-black/30 p-3 text-sm text-gray-200">

              Shell commands<br><span class="text-green-300">Not authorized</span>

            </div>

            <div class="rounded-lg border border-gray-800 bg-black/30 p-3 text-sm text-gray-200">

              Autonomous execution<br><span class="text-green-300">Not authorized</span>

            </div>

          </div>

        </section>

        <section class="rounded-xl border border-gray-800 bg-gray-950/50 p-4">

          <h4 class="text-sm font-semibold text-gray-100">What happened</h4>

          <div class="mt-3 space-y-2">${renderTrace(trace)}</div>

        </section>

        <section class="rounded-xl border border-gray-800 bg-gray-950/50 p-4">

          <h4 class="text-sm font-semibold text-gray-100">What would be reviewed next</h4>

          <p class="mt-2 text-sm leading-6 text-gray-300">

            The next governance step is not execution. The next step is a clearer preview-confirmation surface:

            a human-readable view of the interpreted request, proposed work, risks, rollback, and reconciliation details.

          </p>

          <p class="mt-2 text-sm leading-6 text-gray-400">

            Current reconciliation entries: ${entries.length}

          </p>

        </section>

        <details class="rounded-xl border border-gray-800 bg-gray-950/50 p-4">

          <summary class="cursor-pointer text-sm font-semibold text-gray-200">

            Developer details

          </summary>

          <div class="mt-4 space-y-4">

            <section>

              <h5 class="text-xs uppercase tracking-[0.2em] text-gray-500">Artifact identity</h5>

              <div class="mt-2 grid gap-2 md:grid-cols-3">

                <div class="text-xs text-gray-300">Schema: ${escapeHtml(bundle.bundle_schema)}</div>

                <div class="text-xs text-gray-300">Phase: ${escapeHtml(bundle.phase)}</div>

                <div class="text-xs text-gray-300">Envelope: ${escapeHtml(bundle.envelope_version)}</div>

              </div>

            </section>

            <section>

              <h5 class="text-xs uppercase tracking-[0.2em] text-gray-500">Immutable constraints</h5>

              <div class="mt-2 grid gap-2 md:grid-cols-2">

                <div class="text-xs text-gray-300">Append only: ${boolLabel(immutable.append_only)}</div>

                <div class="text-xs text-gray-300">Mutation authority granted: ${boolLabel(immutable.mutation_authority_granted)}</div>

                <div class="text-xs text-gray-300">Shell authority granted: ${boolLabel(immutable.shell_authority_granted)}</div>

                <div class="text-xs text-gray-300">Autonomous authority granted: ${boolLabel(immutable.autonomous_authority_granted)}</div>

              </div>

            </section>

            <section>

              <h5 class="text-xs uppercase tracking-[0.2em] text-gray-500">Raw bundle</h5>

              <pre class="mt-2 max-h-72 overflow-auto rounded-lg bg-black/40 p-3 text-xs text-gray-300">${escapeHtml(JSON.stringify(bundle, null, 2))}</pre>

            </section>

          </div>

        </details>

      </div>

    `;
    }
    function ensureModal() {
      let modal = document.getElementById("planning-preview-modal");
      if (modal) return modal;
      modal = document.createElement("div");
      modal.id = "planning-preview-modal";
      modal.hidden = true;
      modal.className = "fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4";
      modal.innerHTML = `

      <div class="max-h-[88vh] w-full max-w-5xl overflow-hidden rounded-2xl border border-gray-700 bg-gray-900 shadow-2xl">

        <div class="flex items-center justify-between border-b border-gray-700 p-4">

          <div>

            <h3 class="text-lg font-semibold text-gray-100">Governed Planning Artifact</h3>

            <p class="mt-1 text-xs text-gray-400">Read-only preview. No approval or execution authority is granted here.</p>

          </div>

          <button

            id="planning-preview-close-modal"

            type="button"

            class="rounded-lg border border-gray-700 bg-gray-950 px-3 py-2 text-sm text-gray-200 hover:bg-gray-800"

          >

            Close

          </button>

        </div>

        <div id="planning-preview-modal-body" class="max-h-[72vh] overflow-auto p-4"></div>

      </div>

    `;
      document.body.appendChild(modal);
      modal.addEventListener("click", (event) => {
        if (event.target === modal) closeModal();
      });
      modal.querySelector("#planning-preview-close-modal")?.addEventListener("click", (event) => {
        event.preventDefault();
        closeModal();
      });
      document.addEventListener("keydown", (event) => {
        if (event.key === "Escape" && !modal.hidden) closeModal();
      });
      return modal;
    }
    function openModal() {
      const modal = ensureModal();
      const body = document.getElementById("planning-preview-modal-body");
      if (body) body.innerHTML = renderModalBody(latestBundle);
      modal.hidden = false;
      modal.style.display = "flex";
    }
    function closeModal() {
      const modal = document.getElementById("planning-preview-modal");
      if (!modal) return;
      modal.hidden = true;
      modal.style.display = "none";
    }
    function createCard() {
      const card = document.createElement("section");
      card.id = "planning-preview-card";
      card.className = "obs-surface";
      card.setAttribute("data-planning-preview-card", "true");
      card.style.marginTop = "1rem";
      card.innerHTML = `

      <div class="flex items-center justify-between mb-3 border-b border-gray-700 pb-2">

        <h3 class="text-sm uppercase tracking-[0.2em] text-gray-400">Planning Preview</h3>

        <span class="text-xs text-purple-300">read-only</span>

      </div>

      <div id="planning-preview-content" class="bg-gray-900 border border-gray-700 rounded-xl p-3 text-sm text-gray-300">

        Loading governed planning preview artifact...

      </div>

    `;
      return card;
    }
    async function loadPreview() {
      const content = document.getElementById("planning-preview-content");
      if (!content) return;
      try {
        const response = await fetch(ENDPOINT, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            actor: "Matilda",
            target: "Cade",
            objective: "Render governed planning preview artifact in the dashboard read-only preview card",
            scope_constraints: "Read-only Planning Preview card render. No approval, no preview confirmation, no mutation, no shell execution, no autonomous execution.",
            risk_level: "low"
          })
        });
        if (!response.ok) throw new Error(`Governed planning route returned ${response.status}`);
        const payload = await response.json();
        latestBundle = payload.bundle || null;
        content.innerHTML = renderSummary(latestBundle);
        document.getElementById("planning-preview-open-modal")?.addEventListener("click", openModal);
      } catch (err) {
        content.innerHTML = `

        <div class="rounded-xl border border-red-700/60 bg-red-950/20 p-3 text-sm text-red-200">

          Planning preview artifact could not be loaded.

          <div class="mt-2 text-xs text-red-300">${escapeHtml(err?.message || err)}</div>

        </div>

      `;
      }
    }
    function mount() {
      const existing = document.getElementById("planning-preview-card");
      if (existing) {
        loadPreview();
        return;
      }
      const recentTasksCard = document.getElementById("recent-tasks-card");
      if (!recentTasksCard || !recentTasksCard.parentElement) return;
      recentTasksCard.parentElement.appendChild(createCard());
      loadPreview();
    }
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", mount, { once: true });
    } else {
      mount();
    }
  })();

  // public/js/phase61_tabs_workspace.js
  (() => {
    if (window.__PHASE61_TABS_WORKSPACE_ACTIVE__) return;
    window.__PHASE61_TABS_WORKSPACE_ACTIVE__ = true;
    function qsa(root, selector) {
      return Array.from((root || document).querySelectorAll(selector));
    }
    function setSelected(tab, selected) {
      tab.classList.toggle("active", selected);
      tab.setAttribute("aria-selected", selected ? "true" : "false");
      if (selected) {
        tab.removeAttribute("tabindex");
      } else {
        tab.setAttribute("tabindex", "-1");
      }
    }
    function setPanelVisible(panel, visible) {
      panel.classList.toggle("active", visible);
      if (visible) {
        panel.removeAttribute("hidden");
        panel.setAttribute("aria-hidden", "false");
        panel.style.display = "";
      } else {
        panel.setAttribute("hidden", "");
        panel.setAttribute("aria-hidden", "true");
        panel.style.display = "none";
      }
    }
    function activateTab(groupRoot, targetId) {
      const tabs = qsa(groupRoot, "[data-workspace-tab]");
      const panels = qsa(groupRoot, "[data-workspace-panel]");
      let matched = false;
      tabs.forEach((tab) => {
        const isSelected = tab.getAttribute("data-target") === targetId;
        setSelected(tab, isSelected);
        if (isSelected) matched = true;
      });
      panels.forEach((panel) => {
        setPanelVisible(panel, panel.id === targetId);
      });
      return matched;
    }
    function installTabGroup(tablistId, panelContainerId) {
      const tablist = document.getElementById(tablistId);
      const panelContainer = document.getElementById(panelContainerId);
      if (!tablist || !panelContainer) return false;
      const groupRoot = tablist.parentElement || document;
      const tabs = qsa(tablist, "[data-workspace-tab]");
      const panels = qsa(panelContainer, "[data-workspace-panel]");
      if (!tabs.length || !panels.length) return false;
      tabs.forEach((tab) => {
        tab.setAttribute("role", "tab");
        tab.type = "button";
        tab.addEventListener("click", (event) => {
          event.preventDefault();
          const targetId2 = tab.getAttribute("data-target");
          if (!targetId2) return;
          activateTab(groupRoot, targetId2);
        });
        tab.addEventListener("keydown", (event) => {
          const currentIndex = tabs.indexOf(tab);
          if (currentIndex < 0) return;
          let nextIndex = currentIndex;
          if (event.key === "ArrowRight" || event.key === "ArrowDown") {
            nextIndex = (currentIndex + 1) % tabs.length;
          } else if (event.key === "ArrowLeft" || event.key === "ArrowUp") {
            nextIndex = (currentIndex - 1 + tabs.length) % tabs.length;
          } else if (event.key === "Home") {
            nextIndex = 0;
          } else if (event.key === "End") {
            nextIndex = tabs.length - 1;
          } else {
            return;
          }
          event.preventDefault();
          const nextTab = tabs[nextIndex];
          const targetId2 = nextTab.getAttribute("data-target");
          if (!targetId2) return;
          activateTab(groupRoot, targetId2);
          nextTab.focus();
        });
      });
      panels.forEach((panel) => {
        panel.setAttribute("role", "tabpanel");
      });
      const preselected = tabs.find((tab) => tab.classList.contains("active")) || tabs.find((tab) => tab.getAttribute("aria-selected") === "true") || tabs[0];
      const targetId = preselected?.getAttribute("data-target");
      if (targetId) {
        activateTab(groupRoot, targetId);
      }
      return true;
    }
    function boot() {
      installTabGroup("operator-tabs", "operator-panels");
      installTabGroup("observational-tabs", "observational-panels");
    }
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", boot, { once: true });
    } else {
      boot();
    }
  })();

  // public/js/phase530_visible_panels_bridge.js
  (function() {
    if (window.__PHASE530_VISIBLE_PANELS_BRIDGE__) return;
    window.__PHASE530_VISIBLE_PANELS_BRIDGE__ = true;
    const POLL_MS = 1e4;
    function esc(value) {
      return String(value ?? "").replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;").replaceAll("'", "&#39;");
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
      const phase718TaskTitleByKey = /* @__PURE__ */ new Map();
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
          return phase718TaskTitleByKey.has(nestedTarget) ? phase718ResolveBaseTitle(phase718TaskTitleByKey.get(nestedTarget), depth + 1) : nestedTarget;
        };
        const operatorAction = retryTitleMatch ? retryTitleMatch[1].toLowerCase() === "requeue" ? "Requeue" : "Retry differently" : "";
        const operatorTarget = retryTitleMatch ? retryTitleMatch[2] : "";
        const resolvedTargetTitleRaw = operatorTarget && phase718TaskTitleByKey.has(operatorTarget) ? phase718ResolveBaseTitle(phase718TaskTitleByKey.get(operatorTarget)) : operatorTarget;
        const operatorTitle = operatorAction && resolvedTargetTitleRaw ? `${operatorAction}: ${resolvedTargetTitleRaw}` : operatorAction || phase718ResolveBaseTitle(rawTitle);
        const title = esc(operatorTitle);
        const targetTitle = esc(operatorTarget);
        const status = esc(t.status || "unknown");
        const taskId = esc(t.task_id || t.id || "");
        const updated = esc(t.updated_at || "");
        const outcome = esc(t.outcome_preview || "");
        const explanation = esc(t.explanation_preview || "");
        const artifactRaw = t.artifact || (Array.isArray(t.artifacts) ? t.artifacts[0] : null) || t.payload && t.payload.artifact || (t.payload && Array.isArray(t.payload.artifacts) ? t.payload.artifacts[0] : null) || t.metadata && t.metadata.artifact || (t.metadata && Array.isArray(t.metadata.artifacts) ? t.metadata.artifacts[0] : null) || null;
        const artifactName = artifactRaw ? esc(artifactRaw.filename || artifactRaw.path || "artifact") : "";
        const artifactType = artifactRaw ? esc(artifactRaw.type || "artifact") : "";
        const artifactSize = artifactRaw && artifactRaw.size_bytes ? esc(String(artifactRaw.size_bytes) + " bytes") : "";
        const artifactPath = artifactRaw ? esc(artifactRaw.path || "") : "";
        const triageStatusRaw = String(t.status || "").toLowerCase();
        const triageLabel = status ? `status: ${status}` : "";
        const executionStrategyRaw = t.strategy || t.execution_strategy || t.execution_mode || t.executionMode || "";
        const executionStrategy = esc(String(executionStrategyRaw || ""));
        const retryOfRaw = t.retry_of_task_id || t.meta && t.meta.retry_of_task_id || t.payload && t.payload.meta && t.payload.meta.retry_of_task_id || t.execution_meta && t.execution_meta.retry_of_task_id || "";
        const retryOf = esc(String(retryOfRaw || ""));
        const guidance = t.guidance || t.payload && t.payload.guidance || t.metadata && t.metadata.guidance || {};
        const trace = guidance.communicationResult && guidance.communicationResult.systemTrace ? guidance.communicationResult.systemTrace.content : t.payload && t.payload.trace || t.metadata && t.metadata.trace || null;
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

              ${artifactRaw ? `<div style="margin-bottom:8px;color:#86efac;font-size:11px;line-height:1.5;overflow-wrap:anywhere;border:1px solid rgba(134,239,172,.28);border-radius:10px;padding:7px;background:rgba(20,83,45,.14);">Artifact: ${artifactName}${artifactType ? ` \xB7 ${artifactType}` : ""}${artifactSize ? ` \xB7 ${artifactSize}` : ""}</div>` : ""}
            <div style="color:#cbd5e1;font-size:11px;font-weight:700;margin-bottom:7px;letter-spacing:.02em;">Operator actions</div>

            <div style="display:flex;flex-wrap:wrap;gap:7px;align-items:center;">

              <button type="button" data-phase717-requeue="true" data-task-id="${taskId}" data-task-title="${title}" title="Explicit operator action: requeue this task" style="cursor:pointer;border:1px solid rgba(148,163,184,.35);background:rgba(15,23,42,.8);color:#cbd5e1;border-radius:8px;padding:5px 8px;font-size:11px;">Requeue</button>

              <button type="button" data-phase717-retry-differently="true" data-task-id="${taskId}" data-task-title="${title}" title="Explicit operator action: retry this task differently" style="cursor:pointer;border:1px solid rgba(96,165,250,.45);background:rgba(30,41,59,.92);color:#dbeafe;border-radius:8px;padding:5px 8px;font-size:11px;">Retry differently</button>

            </div>

          </div>

          ${outcome ? "" : ""}

          ${explanation ? `<button type="button" data-phase717-inspect-details="true" data-phase717-inspect-title="${title} \u2014 Details" data-phase717-inspect-content="${explanation}" style="margin-top:10px;cursor:pointer;border:1px solid rgba(147,197,253,.35);background:rgba(30,64,175,.14);color:#93c5fd;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect details</button>` : ""}

          ${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} \u2014 Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect trace</button>` : ""}

          ${logContent ? `<button type="button" data-phase717-inspect-logs="true" data-phase717-inspect-title="${title} \u2014 Logs" data-phase717-inspect-content="${logContent}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(45,212,191,.38);background:rgba(20,83,45,.14);color:#5eead4;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect logs</button>` : ""}

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
      return String(value ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;");
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
      const detailMessage = mode === "fresh-context" ? "This will create a new queued attempt using a fresh-context execution strategy.\n\nPlease confirm this action to continue." : "This will create a new queued attempt for this task.\n\nPlease confirm this action to continue.";
      const ok = await phase717RetryModal({ title: modalTitle, message: `Submit ${label} for \u201C${displayName}\u201D?

${detailMessage}`, confirmLabel: "Submit", cancelLabel: "Cancel" });
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
      try {
        const data = await getJson("/api/tasks?limit=12");
        renderRecent(data.tasks || []);
      } catch (e) {
        console.warn("[phase530] recent tasks render failed", e);
      }
      renderActivity([]);
    }
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", refresh, { once: true });
    } else {
      refresh();
    }
    setInterval(refresh, POLL_MS);
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
      modal.addEventListener("click", function(event) {
        if (event.target === modal || event.target.closest("[data-phase719-preview-close]")) {
          modal.style.display = "none";
        }
      });
      document.addEventListener("keydown", function(event) {
        if (event.key === "Escape" && modal.style.display !== "none") {
          modal.style.display = "none";
        }
      });
      return modal;
    }
    function phase719EscapePreviewHtml(value) {
      return String(value || "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
    }
    function phase733NormalizePreviewTransportText(value) {
      return String(value || "").replace(/\\r\\n/g, "\n").replace(/\\n/g, "\n").replace(/\\t/g, "  ");
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
      const semanticType = semanticSource.includes("error") || semanticSource.includes("failed") || semanticSource.includes("failure") ? "Recovery Artifact" : semanticSource.includes("next steps") || semanticSource.includes("recommend") ? "Execution Plan" : semanticSource.includes("completed") || semanticSource.includes("success") ? "Completion Summary" : "Task Artifact";
      const semanticPriority = semanticSource.includes("failed") || semanticSource.includes("blocked") || semanticSource.includes("error") ? "Needs Review" : semanticSource.includes("next") || semanticSource.includes("recommend") ? "Actionable" : "Informational";
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
        return String(value || "").replace(/Standard execution prepared for:/gi, "").replace(/Prepared artifact for:/gi, "").replace(/\s+/g, " ").trim().toLowerCase();
      }
      function phase722IsDuplicateSemanticText(a, b) {
        const left = phase722NormalizeSemanticText(a);
        const right = phase722NormalizeSemanticText(b);
        return Boolean(left && right && (left === right || left.includes(right) || right.includes(left)));
      }
      const semanticOperatorSummary = semanticEnvelope ? [
        semanticEnvelope.task_summary && !phase722IsDuplicateSemanticText(semanticEnvelope.task_summary, displaySummary) ? ["Semantic Summary", semanticEnvelope.task_summary] : null,
        Array.isArray(semanticEnvelope.actionable_outputs) && semanticEnvelope.actionable_outputs.length ? ["Actionable Outputs", semanticEnvelope.actionable_outputs.filter((item) => !phase722IsDuplicateSemanticText(item, displayDeliverable)).join("\n")] : null,
        Array.isArray(semanticEnvelope.evidence_notes) && semanticEnvelope.evidence_notes.length ? ["Evidence Notes", semanticEnvelope.evidence_notes.join("\n")] : null,
        semanticEnvelope.operator_next_steps && !phase722IsDuplicateSemanticText(semanticEnvelope.operator_next_steps, nextSteps) ? ["Operator Next Steps", semanticEnvelope.operator_next_steps] : null
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
        '<meta charset="utf-8">',
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
    function phase723SanitizeVisualArtifactHtml(html) {
      const source = String(html || "");
      const withoutUnsafeBlocks = source.replace(/<\s*script\b[\s\S]*?<\s*\/\s*script\s*>/gi, "").replace(/<\s*style\b[\s\S]*?<\s*\/\s*style\s*>/gi, "").replace(/<\s*iframe\b[\s\S]*?<\s*\/\s*iframe\s*>/gi, "").replace(/<\s*object\b[\s\S]*?<\s*\/\s*object\s*>/gi, "").replace(/<\s*embed\b[\s\S]*?>/gi, "").replace(/<\s*link\b[\s\S]*?>/gi, "").replace(/<\s*meta\b[\s\S]*?>/gi, "");
      return withoutUnsafeBlocks.replace(/\s+on[a-z]+\s*=\s*"[^"]*"/gi, "").replace(/\s+on[a-z]+\s*=\s*'[^']*'/gi, "").replace(/\s+on[a-z]+\s*=\s*[^\s>]+/gi, "").replace(/\s+(href|src)\s*=\s*"javascript:[^"]*"/gi, "").replace(/\s+(href|src)\s*=\s*'javascript:[^']*'/gi, "").replace(/\s+(href|src)\s*=\s*javascript:[^\s>]+/gi, "");
    }
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
      const markdownWithoutVisualArtifact = (source.slice(0, startIndex) + source.slice(endIndex + endMarker.length)).trim();
      return {
        hasVisualArtifact: Boolean(visualHtml),
        visualHtml,
        markdownWithoutVisualArtifact
      };
    }
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
    function phase736TryParseRenderNativeVisualMountCandidate(candidate) {
      if (!candidate) {
        return null;
      }
      if (typeof candidate === "object") {
        return candidate;
      }
      if (typeof candidate !== "string") {
        return null;
      }
      const trimmed = candidate.trim();
      if (!trimmed || !trimmed.startsWith("{") && !trimmed.startsWith("[")) {
        return null;
      }
      try {
        return JSON.parse(trimmed);
      } catch (error) {
        return null;
      }
    }
    function phase736TryRenderNativeVisualMountPayload(data, templateHtml) {
      try {
        const candidates = [
          data?.render_native_dashboard,
          data?.renderNativeDashboard,
          data?.render_native_payload,
          data?.renderNativePayload,
          data?.artifact?.render_native_dashboard,
          data?.artifact?.renderNativeDashboard,
          data?.artifact?.render_native_payload,
          data?.artifact?.renderNativePayload,
          data?.artifact,
          templateHtml,
          data?.content
        ];
        for (const candidate of candidates) {
          const parsedCandidate = phase736TryParseRenderNativeVisualMountCandidate(candidate);
          const guarded = phase736RenderNativeDashboardGuard(parsedCandidate);
          if (!guarded || guarded.renderNative !== true) {
            continue;
          }
          const rendered = phase736RenderNativeDashboardHtml(guarded.payload);
          if (rendered && typeof rendered === "string") {
            return rendered;
          }
        }
        return null;
      } catch (error) {
        console.warn(
          "[phase736] render-native visual mount route failed, falling back",
          error
        );
        return null;
      }
    }
    function phase736RenderNativeDashboardGuard(payload) {
      try {
        if (!payload || typeof payload !== "object") {
          return null;
        }
        const schemaVersion = payload.schemaVersion || "";
        const renderMode = payload.renderMode || "";
        const rendererTarget = payload.rendererTarget || "";
        const isRenderNative = schemaVersion.includes("render-native") || renderMode.includes("render-native") || rendererTarget.includes("render-native");
        if (!isRenderNative) {
          return null;
        }
        return {
          renderNative: true,
          payload
        };
      } catch (error) {
        console.warn(
          "[phase736] render-native guard failed",
          error
        );
        return null;
      }
    }
    function phase736EscapeRenderNativeText(value) {
      return String(value ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
    }
    function phase736RenderNativeToneClass(tone) {
      const normalized = String(tone || "info").toLowerCase();
      if (normalized.includes("ready")) return "phase736-tone-ready";
      if (normalized.includes("blocked")) return "phase736-tone-blocked";
      if (normalized.includes("warning")) return "phase736-tone-warning";
      if (normalized.includes("critical")) return "phase736-tone-critical";
      return "phase736-tone-info";
    }
    function phase736RenderNativePanel(panel) {
      const payload = panel && panel.payload ? panel.payload : {};
      const type = phase736EscapeRenderNativeText(panel && panel.type ? panel.type : "panel");
      const title = phase736EscapeRenderNativeText(payload.title || panel?.title || type);
      const accent = phase736EscapeRenderNativeText(panel?.styling?.accent || "teal");
      if (panel?.renderer === "status-card-grid" && Array.isArray(payload.cards)) {
        return `

      <section class="phase736-render-panel phase736-panel-status-grid phase736-accent-${accent}">

        <div class="phase736-panel-kicker">${type}</div>

        <h3>${title}</h3>

        <div class="phase736-status-grid">

          ${payload.cards.map((card) => `

            <article class="phase736-status-card ${phase736RenderNativeToneClass(card.tone)}">

              <span class="phase736-status-label">${phase736EscapeRenderNativeText(card.label)}</span>

              <strong>${phase736EscapeRenderNativeText(card.status)}</strong>

              <p>${phase736EscapeRenderNativeText(card.detail)}</p>

            </article>

          `).join("")}

        </div>

      </section>

    `;
      }
      if (panel?.renderer === "topology-map" && Array.isArray(payload.nodes)) {
        return `

      <section class="phase736-render-panel phase736-panel-topology phase736-accent-${accent}">

        <div class="phase736-panel-kicker">${type}</div>

        <h3>${title}</h3>

        <div class="phase736-topology-map">

          ${payload.nodes.map((node) => `

            <div class="phase736-topology-node ${phase736RenderNativeToneClass(node.tone)}">

              <span>${phase736EscapeRenderNativeText(node.stage)}</span>

              <strong>${phase736EscapeRenderNativeText(node.label)}</strong>

            </div>

          `).join('<div class="phase736-topology-connector">\u2192</div>')}

        </div>

      </section>

    `;
      }
      if (panel?.renderer === "risk-card-grid" && Array.isArray(payload.risks)) {
        return `

      <section class="phase736-render-panel phase736-panel-risk-grid phase736-accent-${accent}">

        <div class="phase736-panel-kicker">${type}</div>

        <h3>${title}</h3>

        <div class="phase736-risk-grid">

          ${payload.risks.map((risk) => `

            <article class="phase736-risk-card ${phase736RenderNativeToneClass(risk.severity)}">

              <strong>${phase736EscapeRenderNativeText(risk.label)}</strong>

              <p>${phase736EscapeRenderNativeText(risk.description)}</p>

              <small>${phase736EscapeRenderNativeText(risk.mitigation)}</small>

            </article>

          `).join("")}

        </div>

      </section>

    `;
      }
      if (panel?.type === "governance-boundary" && Array.isArray(payload.requirements)) {
        return `

      <section class="phase736-render-panel phase736-panel-governance phase736-accent-amber">

        <div class="phase736-panel-kicker">governance</div>

        <h3>${title}</h3>

        <ul>

          ${payload.requirements.map((item) => `<li>${phase736EscapeRenderNativeText(item)}</li>`).join("")}

        </ul>

      </section>

    `;
      }
      return `

    <section class="phase736-render-panel phase736-accent-${accent}">

      <div class="phase736-panel-kicker">${type}</div>

      <h3>${title}</h3>

      <p>${phase736EscapeRenderNativeText(payload.body || payload.subtitle || "")}</p>

      ${Array.isArray(payload.highlights) ? `

        <div class="phase736-highlight-list">

          ${payload.highlights.map((item) => `<span>${phase736EscapeRenderNativeText(item)}</span>`).join("")}

        </div>

      ` : ""}

    </section>

  `;
    }
    function phase736RenderNativeDashboardHtml(renderNativePayload) {
      const dashboard = renderNativePayload?.dashboard || renderNativePayload?.payload?.dashboard || renderNativePayload;
      const panels = Array.isArray(dashboard?.panels) ? dashboard.panels : Array.isArray(renderNativePayload?.runtimeComposition?.panels) ? renderNativePayload.runtimeComposition.panels : [];
      const title = phase736EscapeRenderNativeText(dashboard?.title || renderNativePayload?.dashboardShell?.title || "Render-Native Dashboard");
      const subtitle = phase736EscapeRenderNativeText(dashboard?.subtitle || renderNativePayload?.dashboardShell?.subtitle || "Governed visual artifact");
      const theme = dashboard?.theme || renderNativePayload?.dashboardShell?.theme || {};
      const accents = Array.isArray(theme.accents) ? theme.accents : ["teal", "violet", "amber", "coral", "emerald"];
      return `

    <div class="phase736-render-native-dashboard" data-phase736-render-native-dashboard="true">

      <style>

        .phase736-render-native-dashboard {

          background: radial-gradient(circle at top left, rgba(45, 212, 191, 0.24), transparent 34%),

                      radial-gradient(circle at top right, rgba(168, 85, 247, 0.22), transparent 30%),

                      linear-gradient(135deg, #07111f 0%, #111827 48%, #1e1b4b 100%);

          color: #f8fafc;

          border-radius: 24px;

          padding: 24px;

          font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;

          box-shadow: 0 24px 80px rgba(15, 23, 42, 0.42);

        }

        .phase736-dashboard-hero {

          display: grid;

          gap: 12px;

          margin-bottom: 22px;

          padding: 22px;

          border: 1px solid rgba(148, 163, 184, 0.24);

          border-radius: 22px;

          background: rgba(15, 23, 42, 0.62);

          backdrop-filter: blur(16px);

        }

        .phase736-dashboard-hero h2 {

          margin: 0;

          font-size: clamp(1.7rem, 3vw, 2.8rem);

          letter-spacing: -0.04em;

        }

        .phase736-dashboard-hero p {

          margin: 0;

          color: #cbd5e1;

        }

        .phase736-dashboard-badges {

          display: flex;

          flex-wrap: wrap;

          gap: 8px;

        }

        .phase736-dashboard-badges span,

        .phase736-highlight-list span {

          border: 1px solid rgba(255, 255, 255, 0.18);

          border-radius: 999px;

          padding: 6px 10px;

          background: rgba(255, 255, 255, 0.08);

          color: #e2e8f0;

          font-size: 0.78rem;

          text-transform: uppercase;

          letter-spacing: 0.08em;

        }

        .phase736-render-grid {

          display: grid;

          grid-template-columns: repeat(12, minmax(0, 1fr));

          gap: 18px;

        }

        .phase736-render-panel {

          grid-column: span 6;

          border: 1px solid rgba(148, 163, 184, 0.22);

          border-radius: 20px;

          padding: 18px;

          background: rgba(15, 23, 42, 0.64);

          backdrop-filter: blur(18px);

          box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.07), 0 16px 40px rgba(0, 0, 0, 0.24);

        }

        .phase736-panel-status-grid,

        .phase736-panel-topology {

          grid-column: span 12;

        }

        .phase736-panel-kicker {

          color: #67e8f9;

          font-size: 0.72rem;

          text-transform: uppercase;

          letter-spacing: 0.14em;

          margin-bottom: 8px;

        }

        .phase736-render-panel h3 {

          margin: 0 0 12px;

          font-size: 1.05rem;

        }

        .phase736-status-grid,

        .phase736-risk-grid {

          display: grid;

          grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));

          gap: 12px;

        }

        .phase736-status-card,

        .phase736-risk-card,

        .phase736-topology-node {

          border-radius: 16px;

          padding: 14px;

          background: rgba(255, 255, 255, 0.08);

          border: 1px solid rgba(255, 255, 255, 0.13);

        }

        .phase736-status-card strong,

        .phase736-topology-node strong {

          display: block;

          margin-top: 5px;

          font-size: 1rem;

        }

        .phase736-status-card p,

        .phase736-risk-card p,

        .phase736-risk-card small,

        .phase736-render-panel p {

          color: #cbd5e1;

          line-height: 1.45;

        }

        .phase736-topology-map {

          display: flex;

          flex-wrap: wrap;

          align-items: center;

          gap: 10px;

        }

        .phase736-topology-connector {

          color: #94a3b8;

        }

        .phase736-tone-ready {

          box-shadow: 0 0 0 1px rgba(52, 211, 153, 0.26);

        }

        .phase736-tone-warning {

          box-shadow: 0 0 0 1px rgba(251, 191, 36, 0.32);

        }

        .phase736-tone-blocked,

        .phase736-tone-critical {

          box-shadow: 0 0 0 1px rgba(251, 113, 133, 0.34);

        }

        .phase736-highlight-list {

          display: flex;

          flex-wrap: wrap;

          gap: 8px;

          margin-top: 12px;

        }

        @media (max-width: 860px) {

          .phase736-render-panel {

            grid-column: span 12;

          }

        }

      </style>

      <header class="phase736-dashboard-hero">

        <div class="phase736-dashboard-badges">

          <span>READ-ONLY</span>

          <span>NO MUTATION</span>

          <span>RENDER-NATIVE</span>

          ${accents.slice(0, 5).map((accent) => `<span>${phase736EscapeRenderNativeText(accent)}</span>`).join("")}

        </div>

        <h2>${title}</h2>

        <p>${subtitle}</p>

      </header>

      <main class="phase736-render-grid">

        ${panels.map(phase736RenderNativePanel).join("")}

      </main>

    </div>

  `;
    }
    function phase735DecodeVisualArtifactHtmlTransport(html) {
      const source = phase733NormalizePreviewTransportText(html || "").replace(/\\\\n/g, "\n").replace(/\\\\\"/g, '"').replace(/\\\\'/g, "'").replace(/style="\\+"/g, 'style="').replace(/;\\+"/g, ";").replace(/\\+"=/g, "=");
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
      body.innerHTML = `<div style="color:#93c5fd;font-size:14px;">Loading rendered artifact preview\u2026</div>`;
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
          const template = phase735Mount.parentElement ? phase735Mount.parentElement.querySelector("[data-phase735-visual-html-template]") : null;
          const templateHtml = template ? template.textContent : "";
          try {
            const decoded = phase735DecodeVisualArtifactHtmlTransport(templateHtml);
            const phase736RenderNativeVisualMountHtml = phase736TryRenderNativeVisualMountPayload(data, templateHtml);
            phase735Mount.innerHTML = phase736RenderNativeVisualMountHtml || phase723SanitizeVisualArtifactHtml(decoded);
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
    document.addEventListener("click", function(event) {
      const button = event.target.closest("[data-phase719-preview-artifact]");
      if (!button) return;
      event.preventDefault();
      phase719OpenPreviewModal(button);
    });
    function phase740TelemetryConsolePolish() {
      const recentTasks = document.getElementById("recentTasks");
      const recentLogs = document.getElementById("recentLogs");
      const recentCard = document.getElementById("recent-tasks-card") || (recentTasks ? recentTasks.closest("section, article, div") : null);
      document.querySelectorAll("button, [role='tab'], .tab, h2, h3, h4, .uppercase, .tracking-wide").forEach((el) => {
        const label = String(el.textContent || "").trim().toLowerCase();
        if (label === "execution inspector" || label === "recent logs" || label === "recent tasks") {
          el.style.display = "none";
          el.setAttribute("aria-hidden", "true");
        }
      });
      if (recentLogs) {
        recentLogs.style.display = "none";
        recentLogs.setAttribute("aria-hidden", "true");
      }
      if (recentCard) {
        recentCard.style.display = "flex";
        recentCard.style.flexDirection = "column";
        recentCard.style.minHeight = "0";
        recentCard.style.height = "100%";
        recentCard.style.overflow = "hidden";
      }
      if (recentTasks) {
        recentTasks.style.display = "block";
        recentTasks.style.flex = "1 1 auto";
        recentTasks.style.height = "100%";
        recentTasks.style.minHeight = "0";
        recentTasks.style.overflowY = "auto";
        recentTasks.style.overflowX = "hidden";
      }
    }
    const phase740RunTelemetryConsolePolish = () => {
      try {
        phase740TelemetryConsolePolish();
      } catch (error) {
        console.warn("[phase740] telemetry console polish failed", error);
      }
    };
    phase740RunTelemetryConsolePolish();
    setInterval(phase740RunTelemetryConsolePolish, 1500);
    new MutationObserver(phase740RunTelemetryConsolePolish).observe(document.documentElement, {
      childList: true,
      subtree: true
    });
    function phase740RecentTasksLiveLayoutDiagnostic() {
      const old = document.getElementById("phase740-recent-layout-diagnostic");
      if (old) old.remove();
      const recentTasks = document.getElementById("recentTasks");
      const rows = [];
      let el = recentTasks;
      let depth = 0;
      while (el && depth < 8) {
        const rect = el.getBoundingClientRect();
        const style = getComputedStyle(el);
        rows.push([
          depth,
          el.tagName.toLowerCase(),
          el.id ? "#" + el.id : "",
          Math.round(rect.width) + "x" + Math.round(rect.height),
          "display=" + style.display,
          "height=" + style.height,
          "gridRows=" + style.gridTemplateRows,
          "gridCols=" + style.gridTemplateColumns,
          "flex=" + style.flex,
          "overflow=" + style.overflow
        ].join(" | "));
        el = el.parentElement;
        depth += 1;
      }
      const box = document.createElement("pre");
      box.id = "phase740-recent-layout-diagnostic";
      box.textContent = "RECENT TASKS LIVE LAYOUT DIAGNOSTIC\n\n" + rows.join("\n");
      box.style.position = "fixed";
      box.style.right = "12px";
      box.style.bottom = "12px";
      box.style.zIndex = "99999";
      box.style.maxWidth = "720px";
      box.style.maxHeight = "360px";
      box.style.overflow = "auto";
      box.style.padding = "12px";
      box.style.border = "1px solid rgba(147,197,253,.65)";
      box.style.borderRadius = "12px";
      box.style.background = "rgba(2,6,23,.96)";
      box.style.color = "#dbeafe";
      box.style.fontSize = "11px";
      box.style.lineHeight = "1.45";
      document.body.appendChild(box);
    }
    setTimeout(phase740RecentTasksLiveLayoutDiagnostic, 1800);
    function phase740RecentTasksInnerWrapperHeightFix() {
      const diagnostic = document.getElementById("phase740-recent-layout-diagnostic");
      if (diagnostic) diagnostic.remove();
      const recentTasks = document.getElementById("recentTasks");
      const recentLogs = document.getElementById("recentLogs");
      if (recentLogs) {
        recentLogs.style.display = "none";
        recentLogs.style.height = "0";
        recentLogs.style.minHeight = "0";
        recentLogs.style.overflow = "hidden";
      }
      if (recentTasks && recentTasks.parentElement) {
        const wrapper = recentTasks.parentElement;
        wrapper.style.flex = "1 1 auto";
        wrapper.style.height = "100%";
        wrapper.style.minHeight = "0";
        wrapper.style.overflow = "hidden";
        wrapper.style.display = "flex";
        wrapper.style.flexDirection = "column";
      }
      if (recentTasks) {
        recentTasks.style.flex = "1 1 auto";
        recentTasks.style.height = "100%";
        recentTasks.style.minHeight = "0";
        recentTasks.style.overflowY = "auto";
        recentTasks.style.overflowX = "hidden";
        recentTasks.style.display = "block";
      }
    }
    const phase740RunRecentTasksInnerWrapperHeightFix = () => {
      try {
        phase740RecentTasksInnerWrapperHeightFix();
      } catch (error) {
        console.warn("[phase740] recent tasks inner wrapper height fix failed", error);
      }
    };
    phase740RunRecentTasksInnerWrapperHeightFix();
    setInterval(phase740RunRecentTasksInnerWrapperHeightFix, 1200);
    new MutationObserver(phase740RunRecentTasksInnerWrapperHeightFix).observe(document.documentElement, {
      childList: true,
      subtree: true
    });
  })();

  // public/js/phase493_telemetry_height_sync.js
  (() => {
    "use strict";
    if (window.__PHASE493_TELEMETRY_HEIGHT_SYNC_ACTIVE__) return;
    window.__PHASE493_TELEMETRY_HEIGHT_SYNC_ACTIVE__ = true;
    function px(value) {
      return `${Math.max(0, Math.round(value))}px`;
    }
    function syncTelemetryHeight() {
      const operatorCard = document.getElementById("operator-workspace-card");
      const telemetryCard = document.getElementById("observational-workspace-card");
      const telemetryPanels = document.getElementById("observational-panels");
      if (!operatorCard || !telemetryCard || !telemetryPanels) return;
      telemetryCard.style.height = "";
      telemetryCard.style.maxHeight = "";
      const operatorHeight = operatorCard.getBoundingClientRect().height;
      if (!operatorHeight || operatorHeight < 100) return;
      telemetryCard.style.height = px(operatorHeight);
      telemetryCard.style.maxHeight = px(operatorHeight);
      telemetryCard.style.overflow = "hidden";
      telemetryPanels.style.minHeight = "0";
      telemetryPanels.style.overflowY = "auto";
      telemetryPanels.style.overflowX = "hidden";
    }
    function scheduleSync() {
      window.requestAnimationFrame(() => {
        syncTelemetryHeight();
        window.requestAnimationFrame(syncTelemetryHeight);
      });
    }
    function boot() {
      scheduleSync();
      window.addEventListener("resize", scheduleSync, { passive: true });
      const operatorCard = document.getElementById("operator-workspace-card");
      const telemetryCard = document.getElementById("observational-workspace-card");
      if (typeof ResizeObserver !== "undefined") {
        const observer = new ResizeObserver(scheduleSync);
        if (operatorCard) observer.observe(operatorCard);
        if (telemetryCard) observer.observe(telemetryCard);
      }
      document.addEventListener("click", (event) => {
        if (event.target && event.target.closest("[data-workspace-tab]")) {
          scheduleSync();
        }
      });
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
