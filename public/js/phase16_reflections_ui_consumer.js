/**
 * Phase 16/17: Reflections UI Consumer (diagnostic + safe-by-default)
 * Purpose right now: make it impossible for the UI to be "silent" if the script is running.
 */
(() => {
  "use strict";

  const MAX_LINES = 200;
  const RETRY_MS = 250;
  const RETRY_MAX_MS = 10_000;

  window.__PHASE16_REF_UI_STARTED = true;

  function $(id) {
    try { return document.getElementById(id); } catch { return null; }
  }

  function safeJsonParse(s) {
    try { return JSON.parse(s); } 
  function dispatchReflectionsState(obj) {
    try {
      window.__REFLECTIONS_STATE = obj;
      window.dispatchEvent(new CustomEvent("reflections.state", { detail: obj }));
    } catch (e) {
      /* noop */
    }
  }

catch { return null; }
  }

  function nowISO() {
    return new Date().toISOString();
  }

  function appendLine(el, line) {
    if (!el) return;
    const lines = (el.textContent || "").split("\n").filter(Boolean);
    lines.push(line);
    el.textContent = lines.slice(-MAX_LINES).join("\n") + "\n";
    try { el.scrollTop = el.scrollHeight; } catch {}
  }

  function statusSuffix() {
    const started = !!window.__PHASE16_SSE_OWNER_STARTED;
    const refVal =
      window.__refES === undefined ? "undef" :
      window.__refES === null ? "null" :
      (window.__refES && typeof window.__refES.addEventListener === "function") ? "EventSource" :
      typeof window.__refES;

    const rs = (window.__refES && typeof window.__refES.readyState === "number")
      ? ` rs=${window.__refES.readyState}`
      : "";

    return ` (owner=${started ? "on" : "off"}, __refES=${refVal}${rs})`;
  }

  function setStatus(text) {
    const el = $("phase16_reflections_status");
    if (!el) return;
    el.textContent = text + statusSuffix();
  }

  function bindToRefES(es) {
    if (!es || typeof es.addEventListener !== "function") return false;

    const logEl = $("phase16_reflections_log");
    setStatus("reflections: connected");

    function onAny(evtName, e) {
      const raw = e?.data ?? "";
      const parsed = typeof raw === "string" ? safeJsonParse(raw) : null;
      const msg = parsed ? JSON.stringify(parsed) : String(raw);
      appendLine(logEl, `[${nowISO()}] ${evtName}: ${msg}`);
    }

    es.addEventListener("open", () => setStatus("reflections: open"));
    es.addEventListener("error", () => setStatus("reflections: error"));

    es.addEventListener("hello", (e) => onAny("hello", e));
    es.addEventListener("reflections.state", (e) => {
        onAny("reflections.state", e);
        const raw = e && e.data;
        const parsed = (typeof raw === "string") ? safeJsonParse(raw) : null;
        if (parsed) dispatchReflectionsState(parsed);
      });
    es.addEventListener("reflections.heartbeat", (e) => onAny("reflections.heartbeat", e));

    appendLine(logEl, `[${nowISO()}] bound to window.__refES`);
    return true;
  }

  function boot() {
    const logEl = $("phase16_reflections_log");
    const statusEl = $("phase16_reflections_status");

    // If the panel isn't on this page, do nothing (safe-by-default).
    if (!logEl || !statusEl) return;

    appendLine(logEl, `[${nowISO()}] ✅ reflections UI consumer booted`);
    setStatus("reflections: (binding...)");

    // Always show live singleton state (even if binding fails)
    const live = setInterval(() => {
      const logEl2 = $("phase16_reflections_log");
      const statusEl2 = $("phase16_reflections_status");
      if (!logEl2 || !statusEl2) { clearInterval(live); return; }
      setStatus("reflections: (live)");
    }, 1000);

    const startedAt = Date.now();

    const tryBind = () => {
      if (bindToRefES(window.__refES)) return true;

      const elapsed = Date.now() - startedAt;
      if (elapsed >= RETRY_MAX_MS) {
        // Last resort self-heal (only if missing/falsey, not if explicitly null)
        if (window.__refES == null) {
          try {
            window.__refES = new EventSource("/events/reflections");
            appendLine(logEl, `[${nowISO()}] self-heal: created window.__refES`);
            if (bindToRefES(window.__refES)) return true;
          } catch (e) {
            appendLine(logEl, `[${nowISO()}] self-heal failed: ${String(e)}`);
          }
        }
        appendLine(logEl, `[${nowISO()}] giving up binding after ${RETRY_MAX_MS}ms`);
        setStatus("reflections: (no EventSource)");
        return true; // stop retrying
      }
      return false;
    };

    if (tryBind()) return;

    const t = setInterval(() => {
      if (tryBind()) clearInterval(t);
    }, RETRY_MS);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
