/**
 * Phase 21: Task Events SSE listener
 * - Parallel to ops/reflections (does not modify their ownership)
 * - Opens EventSource("/events/task-events")
 * - Buffers events on window.__TASK_EVENTS_FEED and emits DOM event "task-events:append"
 * - Optional tiny debug panel shown only when window.__UI_DEBUG or window.__PHASE21_SHOW_TASK_EVENTS is true
 */
(function () {
  const URL = "/events/task-events";
  const MAX_ITEMS = 200;

  function nowIso() {
    try { return new Date().toISOString(); } catch { return String(Date.now()); }
  }

  function ensureBuffer() {
    if (!window.__TASK_EVENTS_FEED) window.__TASK_EVENTS_FEED = [];
    return window.__TASK_EVENTS_FEED;
  }

  function pushItem(item) {
    const buf = ensureBuffer();
    buf.push(item);
    if (buf.length > MAX_ITEMS) buf.splice(0, buf.length - MAX_ITEMS);
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
    wrap.style.overflow = "auto";
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
    wrap.style.display = "none";

    const hdr = document.createElement("div");
    hdr.style.display = "flex";
    hdr.style.alignItems = "center";
    hdr.style.justifyContent = "space-between";
    hdr.style.marginBottom = "8px";

    const title = document.createElement("div");
    title.textContent = "TASK EVENTS";
    title.style.letterSpacing = "0.12em";
    title.style.fontWeight = "700";
    title.style.opacity = "0.9";

    const btn = document.createElement("button");
    btn.type = "button";
    btn.textContent = "show";
    btn.style.cursor = "pointer";
    btn.style.border = "1px solid rgba(255,255,255,0.15)";
    btn.style.background = "rgba(255,255,255,0.08)";
    btn.style.color = "rgba(255,255,255,0.9)";
    btn.style.borderRadius = "10px";
    btn.style.padding = "4px 8px";
    btn.style.fontSize = "12px";
    btn.onclick = () => {
      const on = wrap.style.display === "none";
      wrap.style.display = on ? "block" : "none";
      btn.textContent = on ? "hide" : "show";
    };

    hdr.appendChild(title);
    hdr.appendChild(btn);

    const body = document.createElement("div");
    body.id = "task-events-log-body";
    wrap.appendChild(hdr);
    wrap.appendChild(body);
    document.body.appendChild(wrap);

    if (window.__UI_DEBUG || window.__PHASE21_SHOW_TASK_EVENTS) {
      wrap.style.display = "block";
      btn.textContent = "hide";
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

  function start() {
    ensureMiniPanel();

    const es = new EventSource(URL);
    window.__taskEventsES = es;

    es.onopen = () => {
      const item = { ts: Date.now(), iso: nowIso(), kind: "sse.open", url: URL };
      pushItem(item);
      appendLine(`[${item.iso}] open ${URL}`);
    };

    es.onerror = () => {
      const item = { ts: Date.now(), iso: nowIso(), kind: "sse.error", url: URL, readyState: es.readyState };
      pushItem(item);
      appendLine(`[${item.iso}] error readyState=${es.readyState}`);
    };

    // default "message"
    es.onmessage = (ev) => {
      const payload = safeJson(ev.data);
      const item = { ts: Date.now(), iso: nowIso(), kind: "message", event: "message", data: payload ?? ev.data };
      pushItem(item);
      appendLine(`[${item.iso}] message :: ${payload ? JSON.stringify(payload) : String(ev.data)}`);
    };

    // named events we expect (safe even if never emitted)
    const names = ["hello","heartbeat","task.lifecycle","task.created","task.updated","task.completed","task.failed"];
    for (const name of names) {
      es.addEventListener(name, (ev) => {
        const payload = safeJson(ev.data);
        const item = { ts: Date.now(), iso: nowIso(), kind: "event", event: name, data: payload ?? ev.data };
        pushItem(item);
        appendLine(`[${item.iso}] ${name} :: ${payload ? JSON.stringify(payload) : String(ev.data)}`);
      });
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, { once: true });
  } else {
    start();
  }
})();
