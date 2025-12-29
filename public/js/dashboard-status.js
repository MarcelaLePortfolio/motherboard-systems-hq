/**
 * Phase 16: Dashboard wiring for OPS + Reflections SSE streams.
 *
 * Goals:
 * - Consume /events/ops + /events/reflections via EventSource
 * - Treat *.state as "initial paint" (replace baseline state)
 * - Treat everything else as incremental updates (merge / patch)
 * - Show tiny "connected / last event" indicator for each stream
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
      else n.setAttribute(k, v);
    }
    if (text) n.textContent = text;
    return n;
  }

  function ensureStyles() {
    if (document.getElementById("phase16-sse-style")) return;
    const s = el("style", { id: "phase16-sse-style" });
    s.textContent = `
      .sse-indicator { display:inline-flex; gap:6px; font-size:11px; opacity:.85 }
      .sse-indicator .dot { width:7px; height:7px; border-radius:999px; background:#555 }
      .sse-indicator[data-connected="true"] .dot { background:#2dd4bf }
      .sse-indicator[data-connected="false"] .dot { background:#f97316 }
    `;
    document.head.appendChild(s);
  }

  function mount(anchor, id, label) {
    ensureStyles();
    if (!anchor) anchor = document.body;
    let node = document.getElementById(id);
    if (node) return node;
    node = el("span", { id, class: "sse-indicator", "data-connected": "false" });
    node.append(el("span", { class: "dot" }), el("span", { class: "meta" }, `${label}: disconnected · last: —`));
    anchor.appendChild(node);
    return node;
  }

  function set(ind, label, connected, last) {
    if (!ind) return;
    ind.dataset.connected = connected ? "true" : "false";
    const m = ind.querySelector(".meta");
    if (m) m.textContent = `${label}: ${connected ? "connected" : "disconnected"} · last: ${last ? formatAge(NOW()-last) : "—"}`;
  }

  function ensureGlobal() {
    window.__MB_STREAMS ||= {
      ops: { connected:false, last:0, state:{}, es:null },
      reflections: { connected:false, last:0, state:{}, es:null },
    };
    return window.__MB_STREAMS;
  }

  function connect(key, label, url, ind) {
    const g = ensureGlobal();
    g[key].es?.close?.();
    const es = new EventSource(url);
    g[key].es = es;

    es.onopen = () => { g[key].connected = true; set(ind, label, true, g[key].last); };
    es.onerror = () => { g[key].connected = false; set(ind, label, false, g[key].last); };

    es.onmessage = (e) => {
      g[key].last = NOW();
      const p = safeJsonParse(e.data);
      const isState = (p && (p.state || (p.type||"").includes("state") || (p.event||"").includes("state")));
      if (isState) g[key].state = p.state ?? p;
      else if (p && typeof p === "object") Object.assign(g[key].state, p);
      set(ind, label, g[key].connected, g[key].last);
      window.dispatchEvent(new CustomEvent(`mb:${key}:update`, { detail:{ state:g[key].state, raw:p } }));
    };
  }

  function boot() {
    const opsInd = mount(document.getElementById("ops-pill"), "ops-sse-indicator", "OPS SSE");
    const refInd = mount(document.getElementById("reflections") || document.body, "reflections-sse-indicator", "Reflections SSE");
    connect("ops", "OPS SSE", OPS_SSE_URL, opsInd);
    connect("reflections", "Reflections SSE", REFLECTIONS_SSE_URL, refInd);
    setInterval(() => {
      const g = ensureGlobal();
      set(opsInd, "OPS SSE", g.ops.connected, g.ops.last);
      set(refInd, "Reflections SSE", g.reflections.connected, g.reflections.last);
    }, 1000);
  }

  document.readyState === "loading"
    ? document.addEventListener("DOMContentLoaded", boot, { once:true })
    : boot();
})();
