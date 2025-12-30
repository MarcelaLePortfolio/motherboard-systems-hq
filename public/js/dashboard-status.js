/**
 * Phase 16: Dashboard wiring for OPS + Reflections SSE streams.
 *
 * - Consume /events/ops + /events/reflections via EventSource
 * - Treat *.state as "initial paint" (replace baseline state)
 * - Treat subsequent events as incremental updates (merge / patch)
 * - Add tiny “connected / last event” UI indicator for each stream
 *
 * NOTE: Your SSE server emits NAMED events (e.g. "ops.state", "reflections.state").
 * EventSource.onmessage only receives UNNAMED events, so we must addEventListener()
 * for the named event types we care about.
 */

(() => {
  "use strict";

  const OPS_SSE_URL = "/events/ops";
  const REFLECTIONS_SSE_URL = "/events/reflections";

  const NOW = () => Date.now();

  function safeJsonParse(s) {
    try { return JSON.parse(s); } catch { return null; }
  }

  function formatAge(ms) {
    if (!Number.isFinite(ms)) return "—";
    const s = Math.floor(ms / 1000);
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
            "pointer-events:none",
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
      el("span", { class: "meta" }, `${label}: disconnected · last: —`)
    );

    // try to place nicely; otherwise append
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
    meta.textContent = `${label}: ${connected ? "connected" : "disconnected"} · last: ${lastAt ? formatAge(NOW() - lastAt) : "—"}`;
  }

  function ensureGlobal() {
    window.__MB_STREAMS ||= {
      ops: { connected: false, lastAt: 0, state: {}, es: null },
      reflections: { connected: false, lastAt: 0, state: {}, es: null },
    };
    return window.__MB_STREAMS;
  }

  function shallowMerge(target, patch) {
    if (!target || typeof target !== "object") target = {};
    if (!patch || typeof patch !== "object") return target;
    return Object.assign(target, patch);
  }

  // Minimal dot-path patch support: { path:"a.b.c", value:any }
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
    if (parsed.payload !== undefined) return parsed.payload;
    if (parsed.data !== undefined) return parsed.data;
    if (parsed.delta !== undefined) return parsed.delta;
    if (parsed.patch !== undefined) return parsed.patch;
    if (parsed.state !== undefined) return parsed.state;
    return parsed;
  }

  function connect(key, label, url, ind) {
    const g = ensureGlobal();

    // close any existing connection
    try { g[key].es && g[key].es.close(); } catch {}
    g[key].es = null;

    const es = (window.__PHASE16_SSE_OWNER_STARTED ? null : new EventSource(url));
    g[key].es = es;

    const tick = () => set(ind, label, g[key].connected, g[key].lastAt);

    es.onopen = () => { g[key].connected = true; tick(); };
    es.onerror = () => { g[key].connected = false; tick(); };

    const handle = (evtType, e) => {
      g[key].lastAt = NOW();

      const parsed = safeJsonParse(e && e.data ? e.data : "");
      const payload = extractPayload(parsed);

      if (isStateEvent(evtType, parsed)) {
        // initial paint: replace
        g[key].state = (payload && typeof payload === "object") ? payload : { value: payload };
      } else {
        // incremental: patch or merge
        if (payload && typeof payload === "object") {
          if (typeof payload.path === "string" && "value" in payload) {
            g[key].state = applyDotPathPatch(g[key].state, payload);
          } else {
            g[key].state = shallowMerge(g[key].state, payload);
          }
        } else if (payload !== null && payload !== undefined) {
          g[key].state = shallowMerge(g[key].state, { lastValue: payload });
        }
      }

      tick();
      try {
        window.dispatchEvent(new CustomEvent(`mb:${key}:update`, {
          detail: { event: evtType, state: g[key].state, raw: parsed }
        }));
      } catch {}
    };

    // Unnamed events (rare in your streams, but safe)
    es.onmessage = (e) => handle("message", e);

    // Named events (your streams DO emit these)
    const eventNames = [
      "hello",
      `${key}.state`,
      `${key}.update`,
      `${key}.patch`,
      `${key}.delta`,
      "state",
      "update",
      "patch",
      "delta",
    ];

    for (const name of eventNames) {
      try {
        es.addEventListener(name, (e) => handle(name, e));
      } catch {}
    }

    tick();
  }

  function findOpsAnchor() {
    return (
      document.getElementById("ops-pill") ||
      document.querySelector("[data-widget='ops-pill']") ||
      document.querySelector(".ops-pill") ||
      document.querySelector("#ops") ||
      null
    );
  }

  function findReflectionsAnchor() {
    return (
      document.getElementById("reflections-header") ||
      document.getElementById("reflections") ||
      document.querySelector("[data-panel='reflections']") ||
      document.querySelector(".reflections") ||
      (() => {
        const heads = Array.from(document.querySelectorAll("h1,h2,h3,h4,header,strong"));
        return heads.find(h => (h.textContent || "").toLowerCase().includes("reflections")) || null;
      })()
    );
  }

  function boot() {
    const opsInd = mount(findOpsAnchor(), "ops-sse-indicator", "OPS SSE");
    const refInd = mount(findReflectionsAnchor(), "reflections-sse-indicator", "Reflections SSE");

    connect("ops", "OPS SSE", OPS_SSE_URL, opsInd);
    connect("reflections", "Reflections SSE", REFLECTIONS_SSE_URL, refInd);

    // keep age ticking
    setInterval(() => {
      const g = ensureGlobal();
      set(opsInd, "OPS SSE", g.ops.connected, g.ops.lastAt);
      set(refInd, "Reflections SSE", g.reflections.connected, g.reflections.lastAt);
    }, 1000);
  }

  document.readyState === "loading"
    ? document.addEventListener("DOMContentLoaded", boot, { once: true })
    : boot();
})();
