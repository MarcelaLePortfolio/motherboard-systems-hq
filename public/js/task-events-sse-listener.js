/**
 * Phase 21: Task Events SSE listener
 * - Parallel to ops/reflections (does not modify their ownership)
 * - Opens EventSource("/events/task-events")
 * - Buffers events on window.__TASK_EVENTS_FEED and emits DOM event "task-events:append"
 * - Tiny debug panel is ALWAYS clickable (collapsed by default)
 *   - Auto-expands when window.__UI_DEBUG or window.__PHASE21_SHOW_TASK_EVENTS is true
 * - Exposes window.__TASK_EVENTS snapshot for quick inspection
 */
(function () {
  const URL = "/events/task-events";
  const MAX_ITEMS = 200;

  if (typeof window === "undefined" || typeof document === "undefined") return;
  if (window.__TASK_EVENTS_SSE_INITED) return;
  window.__TASK_EVENTS_SSE_INITED = true;

  function nowIso() {
    try { return new Date().toISOString(); } catch { return String(Date.now()); }
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
        readyState: null,
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
    try { snap.readyState = window.__taskEventsES?.readyState ?? null; } catch {}

    try {
      window.dispatchEvent(new CustomEvent("task-events:append", { detail: item }));
    } catch {}
  }

  function safeJson(s) {
    try { return JSON.parse(s); } catch { return null; }
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
    wrap.style.overflow = "hidden"; // body scrolls, header stays
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
    wrap.style.display = "block"; // ALWAYS clickable

    const hdr = document.createElement("div");
    hdr.style.display = "flex";
    hdr.style.alignItems = "center";
    hdr.style.justifyContent = "space-between";
    hdr.style.gap = "10px";
    hdr.style.marginBottom = "8px";

    const title = document.createElement("div");
    title.id = "task-events-log-title";
    title.textContent = "TASK EVENTS · disconnected";
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
    body.style.display = "none"; // collapsed by default

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

    // Auto-expand when debugging
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
      setHeaderStatus("TASK EVENTS · connected");
      appendLine(`[${item.iso}] open ${URL}`);
    };

    es.onerror = () => {
      const snap = ensureSnapshot();
      snap.connected = false;
      snap.readyState = es.readyState;

      const item = { ts: Date.now(), iso: nowIso(), kind: "sse.error", event: "error", url: URL, readyState: es.readyState };
      pushItem(item);
      setHeaderStatus(`TASK EVENTS · error (readyState=${es.readyState})`);
      appendLine(`[${item.iso}] error readyState=${es.readyState}`);
    };

    // default "message"
    es.onmessage = (ev) => {
      const payload = safeJson(ev.data);
      const item = { ts: Date.now(), iso: nowIso(), kind: "message", event: "message", data: payload ?? ev.data };
      pushItem(item);
      appendLine(`[${item.iso}] message :: ${payload ? JSON.stringify(payload) : String(ev.data)}`);
    };

    // named events (include what server ACTUALLY emits: task.event)
    const names = [
      "hello",
      "heartbeat",
      "task.event",
      "task.lifecycle",
      "task.created",
      "task.updated",
      "task.completed",
      "task.failed",
      "error",
    ];

    for (const name of names) {
      try {
        es.addEventListener(name, (ev) => {
          const payload = safeJson(ev.data);
          const item = { ts: Date.now(), iso: nowIso(), kind: "event", event: name, data: payload ?? ev.data };
          pushItem(item);
          appendLine(`[${item.iso}] ${name} :: ${payload ? JSON.stringify(payload) : String(ev.data)}`);
        });
      } catch {}
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, { once: true });
  } else {
    start();
  }
})();
