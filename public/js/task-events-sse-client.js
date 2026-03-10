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
    panel.style.fontFamily =
      "ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial";

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
    title.textContent = "Task Events";
    title.style.fontSize = "12px";
    title.style.letterSpacing = "0.06em";
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
    counts.style.fontVariantNumeric = "tabular-nums";

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
    btn.textContent = "×";
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

  const seen = new Set();
  const tally = { created: 0, completed: 0, failed: 0 };

  function bumpCounts(kind) {
    if (kind === "task.created") tally.created += 1;
    if (kind === "task.completed") tally.completed += 1;
    if (kind === "task.failed") tally.failed += 1;

    const el = document.getElementById(COUNTS_ID);
    if (el) el.textContent = `created:${tally.created}  completed:${tally.completed}  failed:${tally.failed}`;
  }

  function isoText(ts) {
    if (typeof ts === "number") return new Date(ts).toISOString();
    if (typeof ts === "string" && ts.trim()) {
      const d = new Date(ts);
      if (!Number.isNaN(d.getTime())) return d.toISOString();
      return ts.trim();
    }
    return new Date().toISOString();
  }

  function classifyKind(kind, message, status) {
    const text = `${kind || ""} ${message || ""} ${status || ""}`.toLowerCase();
    if (/fail|error|cancel|timeout/.test(text)) return "terminal-error";
    if (/complete|done|success/.test(text)) return "terminal-success";
    if (/queue|pending|retry|wait|hold|sleep/.test(text)) return "waiting";
    if (/open|start|run|resume|lease|dispatch|ack|progress|update|active|heartbeat/.test(text)) return "active";
    return "neutral";
  }

  function accentColor(tone) {
    if (tone === "terminal-error") return "rgba(240,90,90,0.95)";
    if (tone === "terminal-success") return "rgba(80,200,120,0.95)";
    if (tone === "waiting") return "rgba(250,204,21,0.95)";
    if (tone === "active") return "rgba(96,165,250,0.95)";
    return "rgba(255,255,255,0.18)";
  }

  function buildEventRecord(ev, fallbackKind) {
    const ts = isoText(ev.ts);
    const kind = String(ev.kind ?? fallbackKind ?? "event");
    const taskId = ev.task_id ?? ev.taskId ?? "unknown";
    const runId = ev.run_id ?? ev.runId ?? "";
    const actor = ev.actor ?? ev.meta?.actor ?? ev.meta?.owner ?? "";
    const status = ev.status ?? ev.meta?.status ?? "";
    const cursor =
      typeof ev.cursor === "number" || typeof ev.cursor === "string" ? String(ev.cursor) : "";
    const message = String(ev.msg ?? ev.message ?? "").trim();

    const detailParts = [];
    detailParts.push(`task=${taskId}`);
    if (runId) detailParts.push(`run=${runId}`);
    if (actor) detailParts.push(`actor=${actor}`);
    if (status) detailParts.push(`status=${status}`);
    if (cursor) detailParts.push(`cursor=${cursor}`);
    if (message) detailParts.push(message);

    const detail = detailParts.join(" • ");
    const tone = classifyKind(kind, message, status);

    return { ts, kind, detail, tone };
  }

  function appendEvent(ev, fallbackKind) {
    ensurePanel();
    const feed = document.getElementById(FEED_ID);
    if (!feed) return;

    const record = buildEventRecord(ev, fallbackKind);

    const row = document.createElement("div");
    row.className = `phase61-task-event phase61-task-event-${record.tone}`;
    row.dataset.eventKind = record.kind;
    row.dataset.eventTone = record.tone;
    row.style.position = "relative";
    row.style.display = "grid";
    row.style.gridTemplateColumns = "minmax(112px, 132px) minmax(150px, 170px) 1fr";
    row.style.gap = "10px";
    row.style.alignItems = "start";
    row.style.padding = "10px 12px 10px 14px";
    row.style.marginBottom = "8px";
    row.style.border = "1px solid rgba(255,255,255,0.10)";
    row.style.borderRadius = "12px";
    row.style.background = "rgba(255,255,255,0.03)";
    row.style.lineHeight = "1.35";
    row.style.fontSize = "12px";

    const accent = document.createElement("span");
    accent.setAttribute("aria-hidden", "true");
    accent.style.position = "absolute";
    accent.style.left = "0";
    accent.style.top = "10px";
    accent.style.bottom = "10px";
    accent.style.width = "3px";
    accent.style.borderRadius = "999px";
    accent.style.background = accentColor(record.tone);

    const time = document.createElement("div");
    time.textContent = record.ts;
    time.style.color = "rgba(255,255,255,0.68)";
    time.style.fontVariantNumeric = "tabular-nums";
    time.style.whiteSpace = "nowrap";

    const kind = document.createElement("div");
    kind.textContent = record.kind;
    kind.style.color = "rgba(255,255,255,0.92)";
    kind.style.fontWeight = "600";
    kind.style.letterSpacing = "0.01em";
    kind.style.wordBreak = "break-word";

    const detail = document.createElement("div");
    detail.textContent = record.detail || "—";
    detail.style.color = "rgba(255,255,255,0.78)";
    detail.style.wordBreak = "break-word";

    row.appendChild(accent);
    row.appendChild(time);
    row.appendChild(kind);
    row.appendChild(detail);

    feed.prepend(row);

    const children = Array.from(feed.children);
    if (children.length > 60) {
      for (let i = 60; i < children.length; i++) children[i].remove();
    }
  }

  function dispatchWindowEvent(ev) {
    try { window.dispatchEvent(new CustomEvent("mb.task.event", { detail: ev })); } catch {}
  }

  function parseMaybeJSON(raw) {
    try { return JSON.parse(raw); } catch { return null; }
  }

  function handleFrame(eventName, rawData) {
    const data = typeof rawData === "string" ? parseMaybeJSON(rawData) : rawData;
    const ev = (data && typeof data === "object") ? data : { kind: eventName, raw: rawData };

    if (eventName === "task.event") {
      if (ev.actor == null && ev.meta && typeof ev.meta === "object") ev.actor = (ev.meta.actor ?? ev.meta.owner ?? null);

      if (!ev.kind && ev.type) ev.kind = ev.type;
      if (ev.kind === "task.event" && ev.type) ev.kind = ev.type;
      if (ev.task_id == null && ev.taskId != null) ev.task_id = ev.taskId;
      if (ev.run_id == null && ev.runId != null) ev.run_id = ev.runId;
      if (ev && ev.meta && typeof ev.meta === "object") {
        if (ev.task_id == null && ev.meta.task_id != null) ev.task_id = ev.meta.task_id;
        if (ev.run_id  == null && ev.meta.run_id  != null) ev.run_id  = ev.meta.run_id;
        if (ev.actor   == null && ev.meta.actor   != null) ev.actor   = ev.meta.actor;
        if (ev.actor   == null && ev.meta.owner   != null) ev.actor   = ev.meta.owner;
        if (ev.status  == null && ev.meta.status  != null) ev.status  = ev.meta.status;
      }
    }

    if (!ev.kind) ev.kind = eventName;

    const key = `${eventName}|${ev.kind}|${ev.ts ?? ""}|${ev.task_id ?? ""}|${ev.run_id ?? ""}|${ev.cursor ?? ""}`;
    if (seen.has(key)) return;
    seen.add(key);

    if (ev.kind === "task.created" || ev.kind === "task.completed" || ev.kind === "task.failed") {
      bumpCounts(String(ev.kind));
    }

    appendEvent(ev, eventName);
    if (window.__UI_DEBUG) try { console.log("[task-events] mb.task.event", ev); } catch {}
    dispatchWindowEvent(ev);
  }

  let es = null;
  let attempt = 0;

  function connect() {
    ensurePanel();

    if (es) {
      try { es.close(); } catch {}
      es = null;
    }

    const url = SSE_URL;
    es = new EventSource(url);

    es.onopen = () => {
      attempt = 0;
      setDot("open");
      appendEvent({ ts: Date.now(), kind: "sse.open", message: `url=${url}` }, "sse.open");
      console.log("[phase22] task-events SSE open", url);
    };

    es.onerror = () => {
      setDot("error");
      try { es.close(); } catch {}
      es = null;

      attempt += 1;
      const delay = Math.min(15000, 500 * Math.pow(2, Math.min(6, attempt)));
      appendEvent({ ts: Date.now(), kind: "sse.error", message: `reconnect_in=${delay}ms` }, "sse.error");
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
      "task.status",
    ];
    for (const name of names) {
      es.addEventListener(name, (e) => handleFrame(name, e.data));
    }
  }

  function boot() {
    connect();
    setInterval(() => {
      if (!document.getElementById(PANEL_ID)) {
        try { connect(); } catch {}
      }
    }, 2000);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }

  window.__MB_TASK_EVENTS = { url: SSE_URL, reconnect: () => connect() };
})();
