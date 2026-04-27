(() => {
  const SSE_URL = "/events/task-events";

  const PANEL_ID = "mb-task-events-panel";
  const FEED_ID = "mb-task-events-feed";
  const COUNTS_ID = "mb-task-events-counts";
  const ANCHOR_ID = "mb-task-events-panel-anchor";

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

    const feed = document.createElement("div");
    feed.id = FEED_ID;
    feed.style.overflow = "auto";
    feed.style.maxHeight = "200px";

    panel.appendChild(header);
    panel.appendChild(counts);
    panel.appendChild(feed);

    root.appendChild(panel);

    window.__MB_TASK_EVENTS_PANEL = { feed, counts };
  }

  const tally = { queued: 0, running: 0, completed: 0, failed: 0 };

  function updateCounts(kind) {
    if (kind === "task.created") tally.queued++;
    if (kind === "task.running" || kind === "task.started" || kind === "task.claimed") tally.running++;
    if (kind === "task.completed" || kind === "task.succeeded") tally.completed++;
    if (kind === "task.failed" || kind === "task.error") tally.failed++;

    const el = document.getElementById(COUNTS_ID);
    if (el) {
      el.textContent = `queued:${tally.queued} running:${tally.running} completed:${tally.completed} failed:${tally.failed}`;
    }
  }

  function shortId(id) {
    if (!id) return "----";
    return String(id).slice(0, 6);
  }

  function symbol(kind) {
    if (kind === "task.created") return "●";
    if (kind === "task.running" || kind === "task.started" || kind === "task.claimed") return "▶";
    if (kind === "task.completed" || kind === "task.succeeded") return "✓";
    if (kind === "task.failed" || kind === "task.error") return "✕";
    return "";
  }

  function humanize(kind) {
    if (kind === "task.created") return "Queued";
    if (kind === "task.running" || kind === "task.started" || kind === "task.claimed") return "Running";
    if (kind === "task.completed" || kind === "task.succeeded") return "Completed";
    if (kind === "task.failed" || kind === "task.error") return "Failed";
    return null;
  }

  function shouldRender(kind) {
    if (!kind) return false;
    if (kind === "task.event") return false;
    return true;
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

    const time = new Date(ev.ts || Date.now()).toLocaleTimeString();
    const title = ev.title || ev.task_title || ev.taskName || ev.task_id || ev.taskId || "Task";
    const id = shortId(ev.task_id || ev.taskId);
    const sym = symbol(kind);

    row.textContent = `${time} — [${id}] ${sym} ${label}: ${title}`;

    feed.prepend(row);

    while (feed.children.length > 30) {
      feed.removeChild(feed.lastChild);
    }
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

    ["task.created", "task.running", "task.started", "task.claimed", "task.completed", "task.succeeded", "task.failed", "task.error", "task.event"].forEach((name) => {
      es.addEventListener(name, (e) => handleFrame(name, e.data));
    });

    es.onerror = () => {
      // silent reconnect — no UI spam
    };
  }

  document.addEventListener("DOMContentLoaded", start, { once: true });
})();
