/**
 * Phase 16/17: Reflections UI Consumer (safe-by-default)
 * - Prefers the owner singleton: window.__refES (created by phase16_sse_owner_ops_reflections.js)
 * - Logs reflections SSE events into #phase16_reflections_log
 * - Never throws if DOM elements are missing; no-op instead
 * - Retries binding in case owner initializes after DOMContentLoaded
 * - If still missing after retry window, creates window.__refES as a last-resort self-heal
 */
(() => {
  "use strict";

  const MAX_LINES = 200;
  const RETRY_MS = 250;
  const RETRY_MAX_MS = 10_000;

  function $(id) {
    try { return document.getElementById(id); } catch { return null; }
  }

  function safeJsonParse(s) {
    try { return JSON.parse(s); } catch { return null; }
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
    const refType = window.__refES === null ? "null" : typeof window.__refES;
    const rs = window.__refES && typeof window.__refES.readyState === "number"
      ? ` rs=${window.__refES.readyState}`
      : "";
    return ` (owner=${started ? "on" : "off"}, __refES=${refType}${rs})`;
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
    es.addEventListener("reflections.state", (e) => onAny("reflections.state", e));
    es.addEventListener("reflections.heartbeat", (e) => onAny("reflections.heartbeat", e));

    appendLine(logEl, `[${nowISO()}] bound to window.__refES`);
    return true;
  }

  function boot() {
    const logEl = $("phase16_reflections_log");
    const statusEl = $("phase16_reflections_status");
    if (!logEl || !statusEl) return;

    const startedAt = Date.now();
    setStatus("reflections: (binding...)");

    const tryBind = () => {
      const es = window.__refES;
      if (bindToRefES(es)) return true;

      const elapsed = Date.now() - startedAt;
      if (elapsed >= RETRY_MAX_MS) {
        // Last resort: if owner singleton never appeared, create it once.
        if (!window.__refES) {
          try {
            window.__refES = new EventSource("/events/reflections");
            appendLine(logEl, `[${nowISO()}] self-heal: created window.__refES`);
            if (bindToRefES(window.__refES)) return true;
          } catch (e) {
            appendLine(logEl, `[${nowISO()}] self-heal failed: ${String(e)}`);
          }
        }
        setStatus("reflections: (no EventSource)");
        appendLine(logEl, `[${nowISO()}] no usable EventSource after ${RETRY_MAX_MS}ms`);
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
