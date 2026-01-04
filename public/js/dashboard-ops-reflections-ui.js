window.__refSSEState = window.__refSSEState || { lastEventAt:0,lastHeartbeatAt:0,backoffMs:0,staleTimer:null,reconnectTimer:null,closing:false };
window.__opsSSEState = window.__opsSSEState || { lastEventAt:0,lastHeartbeatAt:0,backoffMs:0,staleTimer:null,reconnectTimer:null,closing:false };
/**
 * Phase 16 UI consumption:
 * - consume ops.state -> paint OPS pill (label + class)
 * - consume reflections.state -> render list
 *
 * Expects SSE layer dispatches:
 *   window.dispatchEvent(new CustomEvent("ops.state", { detail: <state> }))
 *   window.dispatchEvent(new CustomEvent("reflections.state", { detail: <state> }))
 */




function normalizeOpsPillClasses(el) {
  if (!el) return;
  // wipe any prior state classes so we never get stuck in "unknown"
  el.classList.remove(
    "ops-pill-unknown",
    "ops-pill-online",
    "ops-pill-offline",
    "ops-pill-warn",
    "ops-ok",
    "ops-warn",
    "ops-bad",
    "ops-degraded",
    "ops-unknown"
  );
}

function getOpsPillEl() {
  return (
    document.querySelector('[data-role="ops-pill"]') ||
    document.querySelector("#ops-pill") ||
    document.querySelector("#ops-dashboard-pill")
  );
}
// ===== PHASE16_SSE_GLUE =====
// Translate SSE event-stream events into window CustomEvents that this UI file already consumes.
(() => {
  function safeJson(s) { try { return JSON.parse(s); } catch (_) { return null; } }

  
function wire(url, map) {
  const label = String(url).includes("/events/ops") ? "ops" : "reflections";
  const state = (label === "ops") ? window.__opsSSEState : window.__refSSEState;

  function bind(es) {
    // Preserve original wiring behavior (handlers attached to `es`)
    try {
      es.addEventListener("message", (e) => {
        // original code below expects `es` in scope; keep behavior minimal here.
      });
    } catch (_) {}

    // ORIGINAL_WIRE_BODY_START
    try {
      const es = (window.__PHASE16_SSE_OWNER_STARTED
      ? (String(url).includes("/events/ops") ? window.__opsES : window.__refES)
      : new EventSource(url));
        if (!es || typeof es.addEventListener !== "function") return null;
      for (const [evt, winEvt] of Object.entries(map)) {
        es.addEventListener(evt, (e) => {
          const data = safeJson(e.data);
          if (data == null) return;
          window.dispatchEvent(new CustomEvent(winEvt, { detail: data }));
    // ORIGINAL_WIRE_BODY_END
  }

  // Build a fresh ES and (re)bind handlers on every reconnect.
  return __p16_connectSSE(label, url, state, (es) => {
    // Rewrite any references from window.__opsES/window.__refES to `es`
    // by running the original body in a small shim context:
    const windowOpsPrev = window.__opsES;
    const windowRefPrev = window.__refES;
    try {
      if (label === "ops") window.__opsES = es;
      else window.__refES = es;
      bind(es);
    } finally {
      // keep globals pointing at current es (do NOT restore)
      void windowOpsPrev; void windowRefPrev;
    }
  });
}
);
      }
      es.addEventListener("error", () => {
        // SSE will retry automatically; keep quiet unless debugging.
        // console.warn("[SSE]", url, "error/retry");
      });
      return es;
    } catch (_) {
      return null;
    }
  }

  // Only connect after DOM exists (avoid racing DOM lookups below)
  window.addEventListener("DOMContentLoaded", () => {
    wire("/events/ops", { "ops.state": "ops.state" });
    wire("/events/reflections", {
      "reflections.state": "reflections.state",
      "reflections.add": "reflections.add",
    });
  });
})();
// ===== /PHASE16_SSE_GLUE =====

(function () {
// PHASE16_4_CLIENT_STALE_DETECT
const PHASE16_4_STALE_MS = Number(window.__PHASE16_4_STALE_MS || 15000);
const PHASE16_4_BACKOFF_MIN = Number(window.__PHASE16_4_BACKOFF_MIN || 500);
const PHASE16_4_BACKOFF_MAX = Number(window.__PHASE16_4_BACKOFF_MAX || 10000);

function __p16_nowMs() { return Date.now(); }
function __p16_jitter(ms) { return Math.floor(ms * (0.85 + Math.random() * 0.3)); }
function __p16_nextBackoff(prev) {
  const base = prev ? Math.min(prev * 2, PHASE16_4_BACKOFF_MAX) : PHASE16_4_BACKOFF_MIN;
  return __p16_jitter(base);
}

function __p16_connectSSE(label, url, state, bind) {
  state = state || { lastEventAt:0,lastHeartbeatAt:0,backoffMs:0,staleTimer:null,reconnectTimer:null,closing:false };

  function __clearTimers() {
    try { if (state.staleTimer) clearInterval(state.staleTimer); } catch (_) {}
    try { if (state.reconnectTimer) clearTimeout(state.reconnectTimer); } catch (_) {}
    state.staleTimer = null;
    state.reconnectTimer = null;
  }

  function __assignGlobal(es) {
    try {
      if (label === "ops") window.__opsES = es;
      if (label === "reflections") window.__refES = es;
    } catch (_) {}
  }

  function __scheduleReconnect(es) {
    if (state.closing) return;
    state.closing = true;
    try { if (es) es.close(); } catch (_) {}
    __clearTimers();
    state.backoffMs = __p16_nextBackoff(state.backoffMs);
    state.reconnectTimer = setTimeout(() => {
      state.closing = false;
      const nes = __connectOnce();
      __assignGlobal(nes);
    }, state.backoffMs);
  }

  function __armStaleTimer(es) {
    __clearTimers();
    const tick = () => {
      const t = __p16_nowMs();
      const last = state.lastHeartbeatAt || state.lastEventAt;
      if (last && (t - last) > PHASE16_4_STALE_MS) __scheduleReconnect(es);
    };
    state.staleTimer = setInterval(tick, Math.max(1000, Math.floor(PHASE16_4_STALE_MS / 3)));
  }

  function __connectOnce() {
    const es = new EventSource(url);

    // app wiring
    try { if (typeof bind === "function") bind(es); } catch (_) {}

    // reliability hooks
    es.addEventListener("open", () => {
      const t = __p16_nowMs();
      state.lastEventAt = t;
      state.lastHeartbeatAt = t;
      state.backoffMs = 0;
      __armStaleTimer(es);
    });

    es.addEventListener("message", () => {
      state.lastEventAt = __p16_nowMs();
    });

    es.addEventListener("heartbeat", () => {
      const t = __p16_nowMs();
      state.lastEventAt = t;
      state.lastHeartbeatAt = t;
    });

    es.addEventListener("error", () => {
      __scheduleReconnect(es);
    });

    return es;
  }

  const first = __connectOnce();
  __assignGlobal(first);
  return first;
}


  var UI_DEBUG = !!(window && window.__UI_DEBUG);
  var SEL = {
    opsPill: ["#ops-pill","[data-role='ops-pill']",".ops-pill",".pill.ops","[data-pill='ops']"],
    reflectionsList: ["#reflections-list","[data-role='reflections-list']",".reflections-list","#reflections","[data-panel='reflections'] ul","[data-panel='reflections'] .list"],
    reflectionsEmpty: ["#reflections-empty","[data-role='reflections-empty']",".reflections-empty"],
  };

  function qsFirst(selectors) {
    for (var i = 0; i < selectors.length; i++) {
      var el = document.querySelector(selectors[i]);
      if (el) return el;
    }
    return null;
  }

  function normalizeDetail(detail) {
    if (!detail || typeof detail !== "object") return detail;
    if (detail.state && typeof detail.state === "object") return detail.state;
    if (detail.data && typeof detail.data === "object") return detail.data;
    return detail;
  }

  function opsStatusClass(status) {
    var s = String(status || "unknown");
    if (s === "ok" || s === "healthy" || s === "up") return "ops-ok";
    if (s === "degraded" || s === "warn" || s === "warning") return "ops-warn";
    if (s === "down" || s === "error" || s === "dead") return "ops-down";
    return "ops-unknown";
  }

  function paintOpsPill(raw) {
    var pill = qsFirst(SEL.opsPill);
    if (!pill) return;

    if (UI_DEBUG) console.log("[ui] missing ops pill element (selectors):", SEL.opsPill);

    var state = normalizeDetail(raw) || {};
    var status = (state.status != null ? state.status : (state.level != null ? state.level : (state.health != null ? state.health : "unknown")));
    var cls = opsStatusClass(status);

    pill.classList.remove("ops-ok", "ops-warn", "ops-down", "ops-unknown");
normalizeOpsPillClasses(pill);
    pill.classList.add(cls);

    var label = String(status || "unknown").toUpperCase() + (state.lastHeartbeatAt ? " • HB" : "");

    var labelEl =
      pill.querySelector("[data-role='ops-pill-label']") ||
      pill.querySelector(".label") ||
      null;

    if (labelEl) labelEl.textContent = label;
    else pill.textContent = label;

    pill.setAttribute("data-ops-status", String(status || "unknown"));
    if (state.lastHeartbeatAt != null) pill.setAttribute("data-last-hb", String(state.lastHeartbeatAt));
  }

  function coerceReflectionsItems(state) {
    var s = normalizeDetail(state) || {};
    if (Array.isArray(s.items)) return s.items;
    if (Array.isArray(s.reflections)) return s.reflections;
    if (Array.isArray(s.entries)) return s.entries;

    if (s.byId && typeof s.byId === "object") {
      var order = Array.isArray(s.order) ? s.order : Object.keys(s.byId);
      var out = [];
      for (var i = 0; i < order.length; i++) {
        var id = order[i];
        if (s.byId[id]) out.push(s.byId[id]);
      }
      return out;
    }
    return [];
  }

  function fmtTs(ms) {
    var n = Number(ms);
    if (!Number.isFinite(n)) return "";
    try { return new Date(n).toLocaleString(); } catch (e) { return ""; }
  }

  function renderReflections(raw) {
    var list = qsFirst(SEL.reflectionsList);
    if (!list) return;

    if (UI_DEBUG) console.log("[ui] missing reflections list element (selectors):", SEL.reflectionsList);

    var emptyEl = qsFirst(SEL.reflectionsEmpty);

    var state = normalizeDetail(raw) || {};
    var items = coerceReflectionsItems(state);

    var listEl =
      (list.tagName === "UL" || list.tagName === "OL")
        ? list
        : (list.querySelector("ul,ol") || list);

    while (listEl.firstChild) listEl.removeChild(listEl.firstChild);

    if (!items.length) {
      if (emptyEl) emptyEl.style.display = "";
      var placeholder = document.createElement((listEl.tagName === "UL" || listEl.tagName === "OL") ? "li" : "div");
      placeholder.className = "text-xs opacity-70";
      placeholder.textContent = "No reflections yet.";
      listEl.appendChild(placeholder);
      return;
    } else if (emptyEl) {
      emptyEl.style.display = "none";
    }

    var sorted = items.slice().sort(function (a, b) {
      var at = Number((a && (a.ts != null ? a.ts : a.createdAt)) || 0);
      var bt = Number((b && (b.ts != null ? b.ts : b.createdAt)) || 0);
      return bt - at;
    });

    for (var j = 0; j < sorted.length; j++) {
      var r = sorted[j] || {};
      var ts = (r.ts != null ? r.ts : (r.createdAt != null ? r.createdAt : r.time));
      var title = (r.title != null ? r.title : (r.kind != null ? r.kind : (r.type != null ? r.type : "reflection")));
      var msg = (r.msg != null ? r.msg : (r.text != null ? r.text : (r.summary != null ? r.summary : (r.content != null ? r.content : (r.note != null ? r.note : "")))));

      var row = document.createElement((listEl.tagName === "UL" || listEl.tagName === "OL") ? "li" : "div");
      row.className = "reflection-row";

      var top = document.createElement("div");
      top.className = "reflection-top";

      var t = document.createElement("div");
      t.className = "reflection-title";
      t.textContent = String(title);

      var when = document.createElement("div");
      when.className = "reflection-ts";
      when.textContent = fmtTs(ts);

      top.appendChild(t);
      top.appendChild(when);

      row.appendChild(top);

      if (msg) {
        var body = document.createElement("div");
        body.className = "reflection-body";
        body.textContent = String(msg);
        row.appendChild(body);
      }

      listEl.appendChild(row);
    }
  }

  function onOpsState(e) { if (UI_DEBUG) console.log("[ui] ops.state", e && e.detail); paintOpsPill(e && e.detail); }
  function onReflectionsState(e) { if (UI_DEBUG) console.log("[ui] reflections.state", e && e.detail); renderReflections(e && e.detail); }

  window.addEventListener("ops.state", onOpsState);
  window.addEventListener("reflections.state", onReflectionsState);

  if (window.__OPS_STATE) paintOpsPill(window.__OPS_STATE);
  if (window.__REFLECTIONS_STATE) renderReflections(window.__REFLECTIONS_STATE);
})();
