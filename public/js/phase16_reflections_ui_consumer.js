/**
 * Phase 16: Reflections UI Consumer (non-bundled, safe-by-default)
 * - Subscribes to the existing owner singleton: window.__refES
 * - Renders recent reflections SSE payloads into #phase16_reflections_log
 * - Never throws if DOM elements are missing; no-op instead
 */
(() => {
  "use strict";

  const MAX_LINES = 200;

  function $(id) {
    try {
      return document.getElementById(id);
    } catch {
      return null;
    }
  }

  function safeJsonParse(s) {
    try {
      return JSON.parse(s);
    } catch {
      return null;
    }
  }

  function nowISO() {
    return new Date().toISOString();
  }

  function appendLine(el, line) {
    if (!el) return;
    const lines = (el.textContent || "").split("\n").filter(Boolean);
    lines.push(line);
    const trimmed = lines.slice(-MAX_LINES);
    el.textContent = trimmed.join("\n") + "\n";
    try {
      el.scrollTop = el.scrollHeight;
    } catch {}
  }

  function setStatus(text) {
    const el = $("phase16_reflections_status");
    if (!el) return;
    el.textContent = text;
  }

  function bindToExistingRefES() {
    const es = window.__refES;
    if (!es || typeof es.addEventListener !== "function") {
      setStatus("reflections: (no EventSource singleton found)");
      return null;
    }

    setStatus(`reflections: connected (readyState=${es.readyState})`);

    const logEl = $("phase16_reflections_log");

    function onAny(evtName, e) {
      const raw = e?.data ?? "";
      const parsed = typeof raw === "string" ? safeJsonParse(raw) : null;
      const msg = parsed ? JSON.stringify(parsed) : String(raw);
      appendLine(logEl, `[${nowISO()}] ${evtName}: ${msg}`);
    }

    es.addEventListener("open", () => setStatus("reflections: open"));
    es.addEventListener("error", () =>
      setStatus(`reflections: error (readyState=${es.readyState})`)
    );

    es.addEventListener("hello", (e) => onAny("hello", e));
    es.addEventListener("reflections.state", (e) => onAny("reflections.state", e));
    es.addEventListener("reflections.heartbeat", (e) =>
      onAny("reflections.heartbeat", e)
    );

    appendLine(logEl, `[${nowISO()}] bound to window.__refES`);
    return es;
  }

  function boot() {
    const logEl = $("phase16_reflections_log");
    const statusEl = $("phase16_reflections_status");
    if (!logEl || !statusEl) return;
    bindToExistingRefES();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
