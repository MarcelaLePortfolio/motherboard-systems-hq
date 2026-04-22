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
    header.textContent = "Task Activity";

    const counts = document.createElement("div");
    counts.id = COUNTS_ID;
    counts.style.fontSize = "11px";
    counts.style.opacity = "0.7";
    counts.textContent = "created:0 completed:0 failed:0";

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

  const tally = { created: 0, completed: 0, failed: 0 };

  function updateCounts(kind) {
    if (kind === "task.created") tally.created++;
    if (kind === "task.completed") tally.completed++;
    if (kind === "task.failed") tally.failed++;

    const el = document.getElementById(COUNTS_ID);
    if (el) {
      el.textContent = `created:${tally.created} completed:${tally.completed} failed:${tally.failed}`;
    }
  }

  function humanize(kind) {
    if (kind === "task.created") return "Task queued";
    if (kind === "task.completed") return "Task completed";
    if (kind === "task.failed") return "Task failed";
    return null;
  }

  function shouldIgnore(kind) {
    return ["hello", "heartbeat"].includes(kind);
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

    const title = ev.title || ev.task_title || ev.taskName || ev.task_id || "Task";

    row.textContent = `${time} — ${label}: ${title}`;

    feed.prepend(row);
  }

  function handleFrame(eventName, data) {
    let parsed;
    try {
      parsed = typeof data === "string" ? JSON.parse(data) : data;
    } catch {
      return;
    }

    if (shouldIgnore(eventName)) return;

    const kind = parsed.kind || eventName;

    renderEvent(parsed, kind);
  }

  function start() {
    const es = // PHASE488_DISABLED new EventSource(SSE_URL);

    es.onmessage = (msg) => handleFrame("message", msg.data);

    ["task.created", "task.completed", "task.failed", "task.event"].forEach((name) => {
      es.addEventListener(name, (e) => handleFrame(name, e.data));
    });

    es.onerror = () => {
      // silent reconnect — no UI spam
    };
  }

  document.addEventListener("DOMContentLoaded", start, { once: true });
})();
