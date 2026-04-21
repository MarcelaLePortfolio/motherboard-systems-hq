(() => {
  const TASK_ID_RE = /\btask\.[a-f0-9-]{8,}\b/gi;

  const state = {
    taskMap: new Map(),
  };

  function extractTasks(payload) {
    if (!payload) return [];
    if (Array.isArray(payload.tasks)) return payload.tasks;
    if (Array.isArray(payload)) return payload;
    return [];
  }

  function getId(task) {
    return task?.task_id || task?.taskId || task?.id || null;
  }

  function getTitle(task) {
    return (
      task?.title ||
      task?.task_name ||
      task?.name ||
      task?.summary ||
      null
    );
  }

  async function refreshMap() {
    try {
      const res = await fetch("/api/tasks?limit=200", { cache: "no-store" });
      if (!res.ok) return;

      const json = await res.json();
      const tasks = extractTasks(json);

      const map = new Map();

      for (const t of tasks) {
        const id = getId(t);
        const title = getTitle(t);
        if (id && title) map.set(id, title);
      }

      state.taskMap = map;

      // force immediate re-render
      rewriteAll();
    } catch {}
  }

  function replaceIds(text) {
    return text.replace(TASK_ID_RE, (id) => {
      return state.taskMap.get(id) || id;
    });
  }

  function rewriteAll() {
    // ONLY target visible UI containers (more aggressive + reliable)
    const selectors = [
      "#agent-pool",
      "#tasks-widget",
      "#mb-task-events-panel",
      "body"
    ];

    selectors.forEach((sel) => {
      const root = document.querySelector(sel);
      if (!root) return;

      const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);

      let node;
      while ((node = walker.nextNode())) {
        if (!node.textContent) continue;

        if (!node.__originalText) {
          node.__originalText = node.textContent;
        }

        const updated = replaceIds(node.__originalText);

        if (updated !== node.textContent) {
          node.textContent = updated;
        }
      }
    });
  }

  function observe() {
    const obs = new MutationObserver(() => {
      rewriteAll();
    });

    obs.observe(document.body, {
      subtree: true,
      childList: true,
      characterData: true,
    });
  }

  function boot() {
    observe();
    refreshMap();
    setInterval(refreshMap, 5000);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
