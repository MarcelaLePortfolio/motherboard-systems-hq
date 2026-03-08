(() => {
  const SSE_URL = "/events/task-events";

  const PANEL_ID = "mb-task-events-panel";
  const FEED_ID = "mb-task-events-feed";
  const COUNTS_ID = "mb-task-events-counts";
  const STATUS_ID = "mb-task-events-status";
  const ANCHOR_ID = "mb-task-events-panel-anchor";

  const MAX_ROWS = 24;
  const FLUSH_INTERVAL_MS = 700;
  const HEARTBEAT_COLLAPSE_MS = 4000;
  const PROBE_COLLAPSE_MS = 2500;

  const seen = new Set();
  const tally = { created: 0, completed: 0, failed: 0 };
  const queue = [];
  let flushTimer = null;
  let panelReady = false;
  let heartbeatBucket = null;
  let probeBucket = null;
  let connectionState = "connecting";
  let lastFrameAt = null;

  function mountRoot() {
    const anchor = document.getElementById(ANCHOR_ID);
    if (anchor) return anchor;
    return document.body;
  }

  function ensurePanel() {
    if (panelReady && document.getElementById(PANEL_ID)) return;

    const root = mountRoot();
    const anchored = root && root.id === ANCHOR_ID;

    const existing = document.getElementById(PANEL_ID);
    if (existing) {
      panelReady = true;
      return;
    }

    const panel = document.createElement("section");
    panel.id = PANEL_ID;
    panel.setAttribute("aria-live", "polite");
    panel.style.width = "100%";
    panel.style.maxWidth = "100%";
    panel.style.overflow = "hidden";
    panel.style.border = "1px solid rgba(148,163,184,0.18)";
    panel.style.borderRadius = "18px";
    panel.style.background = "rgba(15,23,42,0.72)";
    panel.style.backdropFilter = "blur(10px)";
    panel.style.boxShadow = "0 18px 36px rgba(2,6,23,0.38)";
    panel.style.color = "rgba(255,255,255,0.94)";
    panel.style.fontFamily = "ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif";

    if (!anchored) {
      panel.style.position = "fixed";
      panel.style.right = "12px";
      panel.style.bottom = "12px";
      panel.style.width = "min(560px, calc(100vw - 24px))";
      panel.style.zIndex = "9999";
    }

    const header = document.createElement("div");
    header.style.display = "flex";
    header.style.alignItems = "flex-start";
    header.style.justifyContent = "space-between";
    header.style.gap = "12px";
    header.style.padding = "14px 16px 12px";
    header.style.borderBottom = "1px solid rgba(148,163,184,0.14)";

    const left = document.createElement("div");
    left.style.minWidth = "0";

    const title = document.createElement("div");
    title.textContent = "Probe Event Stream";
    title.style.fontSize = "15px";
    title.style.fontWeight = "700";
    title.style.letterSpacing = "0.01em";

    const subtitle = document.createElement("div");
    subtitle.textContent = "Contained live feed for probe lifecycle and task events";
    subtitle.style.fontSize = "12px";
    subtitle.style.opacity = "0.72";
    subtitle.style.marginTop = "4px";

    const status = document.createElement("div");
    status.id = STATUS_ID;
    status.style.fontSize = "12px";
    status.style.opacity = "0.85";
    status.style.marginTop = "8px";
    status.textContent = "Connecting…";

    left.appendChild(title);
    left.appendChild(subtitle);
    left.appendChild(status);

    const right = document.createElement("div");
    right.style.display = "flex";
    right.style.alignItems = "center";
    right.style.gap = "10px";
    right.style.flexShrink = "0";

    const counts = document.createElement("div");
    counts.id = COUNTS_ID;
    counts.style.fontSize = "11px";
    counts.style.opacity = "0.8";
    counts.style.textAlign = "right";
    counts.style.whiteSpace = "nowrap";
    counts.textContent = "created 0 · completed 0 · failed 0";

    const dot = document.createElement("span");
    dot.setAttribute("aria-label", "task-events connection");
    dot.title = "task-events connection";
    dot.style.display = "inline-block";
    dot.style.width = "10px";
    dot.style.height = "10px";
    dot.style.borderRadius = "999px";
    dot.style.background = "rgba(148,163,184,0.55)";
    dot.style.boxShadow = "0 0 0 2px rgba(255,255,255,0.08) inset";

    right.appendChild(counts);
    right.appendChild(dot);

    header.appendChild(left);
    header.appendChild(right);

    const feed = document.createElement("div");
    feed.id = FEED_ID;
    feed.style.padding = "12px 16px 16px";
    feed.style.display = "flex";
    feed.style.flexDirection = "column";
    feed.style.gap = "10px";
    feed.style.maxHeight = anchored ? "340px" : "45vh";
    feed.style.overflow = "auto";

    const empty = document.createElement("div");
    empty.id = "mb-task-events-empty";
    empty.style.border = "1px dashed rgba(148,163,184,0.20)";
    empty.style.borderRadius = "14px";
    empty.style.padding = "12px 14px";
    empty.style.background = "rgba(255,255,255,0.03)";
    empty.style.fontSize = "12px";
    empty.style.lineHeight = "1.45";
    empty.style.opacity = "0.86";
    empty.textContent = "Waiting for probe lifecycle activity. Heartbeats will be grouped automatically so the panel stays readable.";

    feed.appendChild(empty);

    panel.appendChild(header);
    panel.appendChild(feed);
    root.appendChild(panel);

    window.__MB_TASK_EVENTS_PANEL = { dot, feed, counts, status };
    panelReady = true;
    syncStatus();
  }

  function syncStatus() {
    ensurePanel();
    const statusEl = document.getElementById(STATUS_ID);
    const dot = window.__MB_TASK_EVENTS_PANEL?.dot;
    if (!statusEl || !dot) return;

    if (connectionState === "open") {
      dot.style.background = "rgba(34,197,94,0.95)";
      statusEl.textContent = lastFrameAt
        ? `Connected · last event ${new Date(lastFrameAt).toLocaleTimeString()}`
        : "Connected";
      return;
    }

    if (connectionState === "error") {
      dot.style.background = "rgba(239,68,68,0.95)";
      statusEl.textContent = "Reconnecting after stream error…";
      return;
    }

    dot.style.background = "rgba(148,163,184,0.60)";
    statusEl.textContent = "Connecting…";
  }

  function updateCounts() {
    const countsEl = document.getElementById(COUNTS_ID);
    if (!countsEl) return;
    countsEl.textContent = `created ${tally.created} · completed ${tally.completed} · failed ${tally.failed}`;
  }

  function iso(ts) {
    return typeof ts === "number" ? new Date(ts).toISOString() : new Date().toISOString();
  }

  function shortTime(ts) {
    return typeof ts === "number" ? new Date(ts).toLocaleTimeString() : new Date().toLocaleTimeString();
  }

  function removeEmptyState() {
    const empty = document.getElementById("mb-task-events-empty");
    if (empty) empty.remove();
  }

  function makeRow(kind, title, meta, tone) {
    const row = document.createElement("div");
    row.style.border = "1px solid rgba(148,163,184,0.16)";
    row.style.borderRadius = "14px";
    row.style.padding = "10px 12px";
    row.style.background = "rgba(255,255,255,0.03)";
    row.style.boxShadow = "inset 0 1px 0 rgba(255,255,255,0.03)";

    if (tone === "probe") {
      row.style.borderColor = "rgba(99,102,241,0.34)";
      row.style.background = "rgba(79,70,229,0.12)";
    } else if (tone === "success") {
      row.style.borderColor = "rgba(34,197,94,0.30)";
      row.style.background = "rgba(34,197,94,0.08)";
    } else if (tone === "error") {
      row.style.borderColor = "rgba(239,68,68,0.32)";
      row.style.background = "rgba(239,68,68,0.08)";
    } else if (tone === "heartbeat") {
      row.style.opacity = "0.78";
    }

    const top = document.createElement("div");
    top.style.display = "flex";
    top.style.alignItems = "center";
    top.style.justifyContent = "space-between";
    top.style.gap = "10px";

    const label = document.createElement("div");
    label.style.fontSize = "12px";
    label.style.fontWeight = "700";
    label.style.letterSpacing = "0.02em";
    label.textContent = title;

    const time = document.createElement("div");
    time.style.fontSize = "11px";
    time.style.opacity = "0.62";
    time.style.whiteSpace = "nowrap";
    time.textContent = shortTime(meta.ts);

    const body = document.createElement("div");
    body.style.marginTop = "6px";
    body.style.fontSize = "12px";
    body.style.lineHeight = "1.45";
    body.style.opacity = "0.88";
    body.textContent = meta.text;

    const foot = document.createElement("div");
    foot.style.marginTop = "6px";
    foot.style.fontSize = "11px";
    foot.style.opacity = "0.64";
    foot.textContent = kind;

    top.appendChild(label);
    top.appendChild(time);

    row.appendChild(top);
    row.appendChild(body);
    row.appendChild(foot);

    return row;
  }

  function prependRow(row) {
    ensurePanel();
    const feed = document.getElementById(FEED_ID);
    if (!feed) return;
    removeEmptyState();
    feed.prepend(row);

    const rows = Array.from(feed.children);
    if (rows.length > MAX_ROWS) {
      for (let i = MAX_ROWS; i < rows.length; i += 1) rows[i].remove();
    }
  }

  function flushQueue() {
    flushTimer = null;
    if (queue.length === 0) return;

    while (queue.length > 0) {
      const item = queue.shift();
      prependRow(item);
    }
  }

  function scheduleFlush() {
    if (flushTimer != null) return;
    flushTimer = setTimeout(flushQueue, FLUSH_INTERVAL_MS);
  }

  function enqueueRow(row) {
    queue.push(row);
    scheduleFlush();
  }

  function formatEventText(ev, fallbackKind) {
    const kind = String(ev.kind ?? fallbackKind ?? "event");
    const parts = [];
    if (ev.task_id ?? ev.taskId) parts.push(`task ${ev.task_id ?? ev.taskId}`);
    if (ev.run_id ?? ev.runId) parts.push(`run ${ev.run_id ?? ev.runId}`);
    if (ev.actor) parts.push(`actor ${ev.actor}`);
    if (ev.status) parts.push(`status ${ev.status}`);
    if (typeof ev.cursor === "number") parts.push(`cursor ${ev.cursor}`);
    const base = parts.join(" · ");
    const msg = ev.msg ?? ev.message ?? "";
    return msg ? `${base}${base ? " · " : ""}${msg}` : (base || kind);
  }

  function collapseHeartbeat(ev) {
    const now = Date.now();
    if (!heartbeatBucket || now - heartbeatBucket.startedAt > HEARTBEAT_COLLAPSE_MS) {
      heartbeatBucket = {
        startedAt: now,
        count: 0,
        lastTs: typeof ev.ts === "number" ? ev.ts : now,
        lastCursor: ev.cursor ?? null,
      };
    }

    heartbeatBucket.count += 1;
    heartbeatBucket.lastTs = typeof ev.ts === "number" ? ev.ts : now;
    heartbeatBucket.lastCursor = ev.cursor ?? heartbeatBucket.lastCursor;

    if (heartbeatBucket.count < 3 && now - heartbeatBucket.startedAt < HEARTBEAT_COLLAPSE_MS) return;

    const text = [
      `${heartbeatBucket.count} heartbeat frames grouped`,
      heartbeatBucket.lastCursor != null ? `latest cursor ${heartbeatBucket.lastCursor}` : null,
    ].filter(Boolean).join(" · ");

    enqueueRow(
      makeRow(
        "heartbeat",
        "Heartbeat activity",
        { ts: heartbeatBucket.lastTs, text },
        "heartbeat"
      )
    );

    heartbeatBucket = null;
  }

  function collapseProbe(ev) {
    const now = Date.now();
    const kind = String(ev.kind ?? "");
    const runId = ev.run_id ?? ev.runId ?? "policy.probe.run";

    if (!probeBucket || probeBucket.kind !== kind || now - probeBucket.startedAt > PROBE_COLLAPSE_MS) {
      if (probeBucket && probeBucket.count > 0) {
        enqueueRow(
          makeRow(
            probeBucket.kind,
            "Probe lifecycle activity",
            {
              ts: probeBucket.lastTs,
              text: `${probeBucket.count} ${probeBucket.kind} events · run ${probeBucket.runId}`,
            },
            "probe"
          )
        );
      }

      probeBucket = {
        kind,
        runId,
        startedAt: now,
        count: 0,
        lastTs: typeof ev.ts === "number" ? ev.ts : now,
      };
    }

    probeBucket.count += 1;
    probeBucket.lastTs = typeof ev.ts === "number" ? ev.ts : now;

    if (probeBucket.count < 2 && now - probeBucket.startedAt < PROBE_COLLAPSE_MS) return;

    enqueueRow(
      makeRow(
        probeBucket.kind,
        "Probe lifecycle activity",
        {
          ts: probeBucket.lastTs,
          text: `${probeBucket.count} ${probeBucket.kind} events · run ${probeBucket.runId}`,
        },
        "probe"
      )
    );

    probeBucket = null;
  }

  function flushBuckets() {
    if (probeBucket && probeBucket.count > 0) {
      enqueueRow(
        makeRow(
          probeBucket.kind,
          "Probe lifecycle activity",
          {
            ts: probeBucket.lastTs,
            text: `${probeBucket.count} ${probeBucket.kind} events · run ${probeBucket.runId}`,
          },
          "probe"
        )
      );
      probeBucket = null;
    }

    if (heartbeatBucket && heartbeatBucket.count > 0) {
      const text = [
        `${heartbeatBucket.count} heartbeat frames grouped`,
        heartbeatBucket.lastCursor != null ? `latest cursor ${heartbeatBucket.lastCursor}` : null,
      ].filter(Boolean).join(" · ");

      enqueueRow(
        makeRow(
          "heartbeat",
          "Heartbeat activity",
          { ts: heartbeatBucket.lastTs, text },
          "heartbeat"
        )
      );
      heartbeatBucket = null;
    }
  }

  function dispatchWindowEvent(ev) {
    try {
      window.dispatchEvent(new CustomEvent("mb.task.event", { detail: ev }));
    } catch {}
  }

  function parseMaybeJSON(raw) {
    try {
      return JSON.parse(raw);
    } catch {
      return null;
    }
  }

  function handleFrame(eventName, rawData) {
    lastFrameAt = Date.now();
    syncStatus();

    const data = typeof rawData === "string" ? parseMaybeJSON(rawData) : rawData;
    const ev = data && typeof data === "object" ? data : { kind: eventName, raw: rawData };

    if (eventName === "task.event") {
      if (ev.actor == null && ev.meta && typeof ev.meta === "object") ev.actor = ev.meta.actor ?? ev.meta.owner ?? null;
      if (!ev.kind && ev.type) ev.kind = ev.type;
      if (ev.kind === "task.event" && ev.type) ev.kind = ev.type;
      if (ev.task_id == null && ev.taskId != null) ev.task_id = ev.taskId;
      if (ev.run_id == null && ev.runId != null) ev.run_id = ev.runId;
      if (ev && ev.meta && typeof ev.meta === "object") {
        if (ev.task_id == null && ev.meta.task_id != null) ev.task_id = ev.meta.task_id;
        if (ev.run_id == null && ev.meta.run_id != null) ev.run_id = ev.meta.run_id;
        if (ev.actor == null && ev.meta.actor != null) ev.actor = ev.meta.actor;
        if (ev.actor == null && ev.meta.owner != null) ev.actor = ev.meta.owner;
      }
    }

    if (!ev.kind) ev.kind = eventName;

    const key = `${eventName}|${ev.kind}|${ev.ts ?? ""}|${ev.task_id ?? ""}|${ev.run_id ?? ""}|${ev.cursor ?? ""}|${ev.message ?? ""}`;
    if (seen.has(key)) return;
    seen.add(key);

    if (ev.kind === "task.created") tally.created += 1;
    if (ev.kind === "task.completed") tally.completed += 1;
    if (ev.kind === "task.failed") tally.failed += 1;
    updateCounts();

    const kind = String(ev.kind ?? eventName);
    const runId = String(ev.run_id ?? ev.runId ?? "");
    const text = formatEventText(ev, eventName);

    if (kind === "heartbeat" || kind === "hello") {
      collapseHeartbeat(ev);
      dispatchWindowEvent(ev);
      return;
    }

    if (runId === "policy.probe.run" || kind.startsWith("policy.probe")) {
      collapseProbe(ev);
      dispatchWindowEvent(ev);
      return;
    }

    flushBuckets();

    const tone =
      kind === "task.completed" ? "success" :
      kind === "task.failed" ? "error" :
      runId === "policy.probe.run" ? "probe" :
      "normal";

    enqueueRow(
      makeRow(
        kind,
        kind === "task.completed"
          ? "Task completed"
          : kind === "task.failed"
          ? "Task failed"
          : "Task event",
        { ts: typeof ev.ts === "number" ? ev.ts : Date.now(), text },
        tone
      )
    );

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

    connectionState = "connecting";
    syncStatus();

    es = new EventSource(SSE_URL);

    es.onopen = () => {
      attempt = 0;
      connectionState = "open";
      syncStatus();
      enqueueRow(
        makeRow(
          "sse.open",
          "Stream connected",
          { ts: Date.now(), text: `Listening on ${SSE_URL}` },
          "normal"
        )
      );
    };

    es.onerror = () => {
      connectionState = "error";
      syncStatus();

      try { es.close(); } catch {}
      es = null;

      flushBuckets();

      attempt += 1;
      const delay = Math.min(15000, 500 * Math.pow(2, Math.min(6, attempt)));

      enqueueRow(
        makeRow(
          "sse.error",
          "Stream reconnecting",
          { ts: Date.now(), text: `Retrying in ${delay}ms` },
          "error"
        )
      );

      setTimeout(connect, delay);
    };

    es.onmessage = (msg) => handleFrame("message", msg.data);

    for (const name of [
      "hello",
      "heartbeat",
      "task.event",
      "task.created",
      "task.completed",
      "task.failed",
      "task.updated",
      "task.status",
    ]) {
      es.addEventListener(name, (e) => handleFrame(name, e.data));
    }
  }

  function boot() {
    ensurePanel();
    connect();

    setInterval(() => {
      if (!document.getElementById(PANEL_ID)) {
        panelReady = false;
        try { connect(); } catch {}
      }
    }, 2000);

    setInterval(() => {
      flushBuckets();
      flushQueue();
    }, 3000);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }

  window.__MB_TASK_EVENTS = { url: SSE_URL, reconnect: () => connect() };
})();
