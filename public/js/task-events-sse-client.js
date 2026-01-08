(() => {
  const SSE_URL = "/events/task-events";

  // ---- UI: small live panel (safe, non-invasive) ----
  const PANEL_ID = "mb-task-events-panel";
  const FEED_ID = "mb-task-events-feed";
  const COUNTS_ID = "mb-task-events-counts";

  function ensurePanel() {
    if (document.getElementById(PANEL_ID)) return;

    const panel = document.createElement("div");
    panel.id = PANEL_ID;
    panel.style.position = "fixed";
    panel.style.right = "12px";
    panel.style.bottom = "12px";
    panel.style.width = "360px";
    panel.style.maxWidth = "calc(100vw - 24px)";
    panel.style.maxHeight = "40vh";
    panel.style.overflow = "hidden";
    panel.style.zIndex = "9999";
    panel.style.border = "1px solid rgba(255,255,255,0.12)";
    panel.style.borderRadius = "14px";
    panel.style.background = "rgba(10,10,14,0.92)";
    panel.style.backdropFilter = "blur(10px)";
    panel.style.boxShadow = "0 10px 30px rgba(0,0,0,0.35)";
    panel.style.color = "rgba(255,255,255,0.92)";
    panel.style.fontFamily = "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace";

    const header = document.createElement("div");
    header.style.display = "flex";
    header.style.alignItems = "center";
    header.style.justifyContent = "space-between";
    header.style.gap = "8px";
    header.style.padding = "10px 12px";
    header.style.borderBottom = "1px solid rgba(255,255,255,0.10)";

    const title = document.createElement("div");
    title.textContent = "TASK EVENTS (live)";
    title.style.fontSize = "12px";
    title.style.letterSpacing = "0.08em";
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
    feed.style.maxHeight = "calc(40vh - 46px)";

    panel.appendChild(header);
    panel.appendChild(feed);

    document.body.appendChild(panel);

    // expose for debugging
    window.__MB_TASK_EVENTS_PANEL = { dot, feed, counts };
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

  function formatLine(ev) {
    const ts = typeof ev.ts === "number" ? new Date(ev.ts).toISOString() : new Date().toISOString();
    const tid = ev.task_id ?? ev.id ?? ev.taskId ?? "unknown";
    const run = ev.run_id ?? ev.runId ?? "";
    const msg = ev.msg ?? ev.message ?? "";
    const extras = [];
    if (run) extras.push(`run=${run}`);
    if (ev.actor) extras.push(`actor=${ev.actor}`);
    if (ev.status) extras.push(`status=${ev.status}`);
    const extraStr = extras.length ? ` (${extras.join(" ")})` : "";
    return `${ts}  ${ev.kind}  task=${tid}${extraStr}${msg ? " — " + msg : ""}`;
  }

  function appendLine(text, kind) {
    ensurePanel();
    const feed = document.getElementById(FEED_ID);
    if (!feed) return;

    const row = document.createElement("div");
    row.style.whiteSpace = "pre-wrap";
    row.style.wordBreak = "break-word";
    row.style.fontSize = "11px";
    row.style.lineHeight = "1.35";
    row.style.padding = "6px 8px";
    row.style.border = "1px solid rgba(255,255,255,0.10)";
    row.style.borderRadius = "12px";
    row.style.marginBottom = "8px";
    row.style.background = "rgba(255,255,255,0.03)";

    if (kind === "task.completed") row.style.borderColor = "rgba(80,200,120,0.35)";
    if (kind === "task.failed") row.style.borderColor = "rgba(240,90,90,0.35)";

    row.textContent = text;

    // newest on top
    feed.prepend(row);

    // trim to last 50 entries
    const children = Array.from(feed.children);
    if (children.length > 50) {
      for (let i = 50; i < children.length; i++) children[i].remove();
    }
  }

  // ---- Optional: try to reflect lifecycle in existing UI if it has recognizable hooks ----
  function reflectIntoExistingUI(ev) {
    const tid = ev.task_id ?? ev.id ?? ev.taskId;
    if (!tid) return;

    // Convention: rows like #task-<id> or [data-task-id="<id>"]
    const byId = document.getElementById(`task-${tid}`) || document.getElementById(`task_${tid}`);
    const byData = document.querySelector?.(`[data-task-id="${CSS.escape(String(tid))}"]`) || null;
    const node = byId || byData;
    if (!node) return;

    node.setAttribute("data-task-kind", String(ev.kind));
    node.setAttribute("data-task-updated-at", String(ev.ts ?? Date.now()));

    // light-touch class toggles
    node.classList?.remove("task-created", "task-completed", "task-failed");
    if (ev.kind === "task.created") node.classList?.add("task-created");
    if (ev.kind === "task.completed") node.classList?.add("task-completed");
    if (ev.kind === "task.failed") node.classList?.add("task-failed");
  }

  function dispatchWindowEvent(ev) {
    try {
      window.dispatchEvent(new CustomEvent("mb.task.event", { detail: ev }));
    } catch {}
  }

  // ---- SSE connect with backoff ----
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
      appendLine(`${new Date().toISOString()}  sse.open  url=${url}`, "sse.open");
    };

    es.onerror = () => {
      setDot("error");
      try { es.close(); } catch {}
      es = null;

      attempt += 1;
      const delay = Math.min(15000, 500 * Math.pow(2, Math.min(6, attempt)));
      appendLine(`${new Date().toISOString()}  sse.error  reconnect_in=${delay}ms`, "sse.error");
      setTimeout(connect, delay);
    };

    es.onmessage = (msg) => {
      // Some servers send default "message" events; if payload has "kind", treat it like a task event.
      let data = null;
      try { data = JSON.parse(msg.data); } catch { return; }
      if (!data || typeof data !== "object") return;
      if (!data.kind) return;

      const key = `${data.kind}|${data.ts ?? ""}|${data.task_id ?? data.id ?? ""}|${data.run_id ?? ""}`;
      if (seen.has(key)) return;
      seen.add(key);

      bumpCounts(String(data.kind));
      appendLine(formatLine(data), String(data.kind));
      reflectIntoExistingUI(data);
      dispatchWindowEvent(data);
    };
  }

  // Boot when DOM is ready
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", connect, { once: true });
  } else {
    connect();
  }

  // expose for console
  window.__MB_TASK_EVENTS = {
    url: SSE_URL,
    reconnect: () => connect(),
  };
})();
