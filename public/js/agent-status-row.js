// Phase 60 — Agent Pool compact console rows (PATCHED FOR HUMAN READABILITY)

(() => {
  const container = document.getElementById("agent-status-container");
  if (!container) return;

  const title = container.querySelector("h2");
  container.innerHTML = "";
  if (title) container.appendChild(title);

  const AGENTS = ["Matilda", "Atlas", "Cade", "Effie"];

  const AGENT_EMOJI = {
    matilda: "🗣️",
    atlas: "🧭",
    cade: "💻",
    effie: "📊",
  };

  const indicators = {};
  const agentReportedState = {};
  const taskMap = new Map();

  async function refreshTaskMap() {
    try {
      const res = await fetch("/api/tasks?limit=50", { cache: "no-store" });
      const json = await res.json();
      const tasks = json?.tasks || [];

      tasks.forEach((t) => {
        if (t.task_id && t.title) {
          taskMap.set(String(t.task_id), String(t.title));
        }
      });
    } catch (_) {}
  }

  function humanize(text) {
    if (!text) return text;

    const match = text.match(/task\.[a-f0-9-]{8,}/i);
    if (!match) return text;

    const id = match[0];
    const title = taskMap.get(id);
    if (!title) return text;

    return text.replace(id, title);
  }

  const stack = document.createElement("div");
  stack.className = "w-full flex flex-col gap-0.5";
  container.appendChild(stack);

  AGENTS.forEach((name) => {
    const key = name.toLowerCase();

    const row = document.createElement("div");
    row.className =
      "w-full rounded-md bg-gray-900 border border-gray-700 px-3 py-1.5 flex items-center justify-between";

    const left = document.createElement("div");
    left.className = "flex items-center gap-3 min-w-0";

    const emoji = document.createElement("span");
    emoji.textContent = AGENT_EMOJI[key] || "•";

    const label = document.createElement("span");
    label.textContent = name;

    const status = document.createElement("span");
    status.textContent = "unknown";

    left.append(emoji, label);
    row.append(left, status);
    stack.appendChild(row);

    indicators[key] = { status };
  });

  function applyAgentMap(payload) {
    if (!payload?.agents) return;

    for (const [name, value] of Object.entries(payload.agents)) {
      const key = name.toLowerCase();
      const indicator = indicators[key];
      if (!indicator) continue;

      let text =
        value?.status ||
        value?.message ||
        value?.task ||
        value?.currentTask ||
        "unknown";

      text = humanize(text);

      indicator.status.textContent = text;
    }
  }

  function start() {
    const es = new EventSource("/events/ops");

    es.onmessage = (e) => {
      try {
        const data = JSON.parse(e.data);
        applyAgentMap(data);
      } catch {}
    };

    es.onerror = () => {};
  }

  refreshTaskMap();
  setInterval(refreshTaskMap, 5000);
  start();
})();
