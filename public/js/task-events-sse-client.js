(() => {
  const SSE_URL = "/events/task-events";

  const PANEL_ID = "mb-task-events-panel";
  const FEED_ID = "mb-task-events-feed";
  const COUNTS_ID = "mb-task-events-counts";
  const SELECTED_ID = "mb-task-events-selected";
  const ANCHOR_ID = "mb-task-events-panel-anchor";

  let lastRenderedTaskId = null;

  function mountRoot() {
    return document.getElementById(ANCHOR_ID) || document.body;
  }

  function ensurePanel() {
    if (document.getElementById(PANEL_ID)) return;

    const root = mountRoot();

    const panel = document.createElement("div");
    panel.id = PANEL_ID;
    panel.style.maxHeight = "260px";
    panel.style.overflow = "hidden";
    panel.style.border = "1px solid rgba(255,255,255,0.12)";
    panel.style.borderRadius = "14px";
    panel.style.background = "rgba(10,10,14,0.92)";
    panel.style.color = "#fff";

    const header = document.createElement("div");
    header.style.padding = "8px 12px";
    header.textContent = "Execution Trail";

    const counts = document.createElement("div");
    counts.id = COUNTS_ID;
    counts.style.fontSize = "11px";
    counts.style.opacity = "0.7";
    counts.textContent = "queued:0 running:0 completed:0 failed:0";

    const selected = document.createElement("div");
    selected.id = SELECTED_ID;
    selected.style.padding = "6px 12px";
    selected.style.fontSize = "11px";
    selected.style.opacity = "0.75";
    selected.textContent = "selected: none";

    const feed = document.createElement("div");
    feed.id = FEED_ID;
    feed.style.overflow = "auto";
    feed.style.maxHeight = "200px";

    panel.appendChild(header);
    panel.appendChild(counts);
    panel.appendChild(selected);
    panel.appendChild(feed);

    root.appendChild(panel);

    window.__MB_TASK_EVENTS_PANEL = { feed, counts, selected };
  }

  const tally = { queued: 0, running: 0, completed: 0, failed: 0 };

  function updateCounts(kind) {
    if (kind === "task.created") tally.queued++;
    if (["task.running","task.started","task.claimed"].includes(kind)) tally.running++;
    if (["task.completed","task.succeeded"].includes(kind)) tally.completed++;
    if (["task.failed","task.error"].includes(kind)) tally.failed++;

    const el = document.getElementById(COUNTS_ID);
    if (el) {
      el.textContent = `queued:${tally.queued} running:${tally.running} completed:${tally.completed} failed:${tally.failed}`;
    }
  }

  function humanize(kind) {
    if (kind === "task.created") return "Queued";
    if (["task.running","task.started","task.claimed"].includes(kind)) return "Running";
    if (["task.completed","task.succeeded"].includes(kind)) return "Completed";
    if (["task.failed","task.error"].includes(kind)) return "Failed";
    return null;
  }

  function symbol(kind) {
    if (kind === "task.created") return "●";
    if (["task.running","task.started","task.claimed"].includes(kind)) return "▶";
    if (["task.completed","task.succeeded"].includes(kind)) return "✓";
    if (["task.failed","task.error"].includes(kind)) return "✕";
    return "";
  }

  function shouldRender(kind) {
    if (!kind) return false;
    if (kind === "task.event") return false;
    return true;
  }

  function isActiveState(kind) {
    return ["task.running","task.started","task.claimed"].includes(kind);
  }

  function shortId(id) {
    if (!id) return "—";
    return String(id).slice(-6);
  }

  function renderEvent(ev, kind) {
    const label = humanize(kind);
    if (!label) return;

    ensurePanel();
    updateCounts(kind);

    const feed = document.getElementById(FEED_ID);
    if (!feed) return;

    const row = document.createElement("div");
    row.style.padding = "6px 10px";
    row.style.borderBottom = "1px solid rgba(255,255,255,0.05)";
    row.style.fontSize = "12px";
    row.style.cursor = "pointer";

    const time = new Date(ev.ts || Date.now()).toLocaleTimeString();
    const currentId = ev.task_id || ev.taskId;
    const title = ev.title || ev.task_title || ev.taskName || currentId || "Task";
    const id = shortId(currentId);
    const sym = symbol(kind);

    if (currentId && currentId === lastRenderedTaskId) {
      row.style.paddingLeft = "18px";
    }

    if (isActiveState(kind)) {
      row.style.background = "rgba(255,255,255,0.04)";
    }

    row.textContent = `${time} — [${id}] ${sym} ${label}: ${title}`;

    // Phase 538: interaction hook (safe)
    row.onclick = () => {
      console.log("Task selected:", currentId);
      const selected = document.getElementById(SELECTED_ID);
      if (selected) {
        selected.textContent = `selected: [${id}] ${label} — ${title}`;
      }
    };

    feed.prepend(row);

    while (feed.children.length > 30) {
      feed.removeChild(feed.lastChild);
    }

    lastRenderedTaskId = currentId;
  }

  function handleFrame(eventName, data) {
    let parsed;
    try {
      parsed = typeof data === "string" ? JSON.parse(data) : data;
    } catch {
      return;
    }

    const kind = parsed.kind || eventName;
    if (!shouldRender(kind)) return;

    renderEvent(parsed, kind);
  }

  function start() {
    ensurePanel();

    const es = new EventSource(SSE_URL);

    es.onmessage = (msg) => handleFrame("message", msg.data);

    ["task.created","task.running","task.started","task.claimed","task.completed","task.succeeded","task.failed","task.error","task.event"].forEach((name) => {
      es.addEventListener(name, (e) => handleFrame(name, e.data));
    });

    es.onerror = () => {
      // silent reconnect
    };
  }

  document.addEventListener("DOMContentLoaded", start, { once: true });
})();
