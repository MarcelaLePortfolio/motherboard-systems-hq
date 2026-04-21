(() => {
  const TASK_ID_RE = /\btask\.[a-f0-9-]{8,}\b/gi;

  const state = {
    map: new Map(),
  };

  function extractTasks(payload) {
    if (!payload) return [];
    if (Array.isArray(payload.tasks)) return payload.tasks;
    if (Array.isArray(payload)) return payload;
    return [];
  }

  function getId(t) {
    return t?.task_id || t?.taskId || t?.id || null;
  }

  function getTitle(t) {
    return t?.title || t?.task_name || t?.name || t?.summary || null;
  }

  async function refreshMap() {
    try {
      const res = await fetch("/api/tasks?limit=200", { cache: "no-store" });
      if (!res.ok) return;

      const json = await res.json();
      const tasks = extractTasks(json);

      const next = new Map();
      for (const t of tasks) {
        const id = getId(t);
        const title = getTitle(t);
        if (id && title) next.set(id, title);
      }

      state.map = next;
    } catch {}
  }

  function replaceIds(text) {
    return text.replace(TASK_ID_RE, (id) => state.map.get(id) || id);
  }

  function rewriteNode(node) {
    if (!node || !node.textContent) return;

    const original = node.__orig || node.textContent;

    if (!node.__orig) node.__orig = original;

    const updated = replaceIds(original);

    if (updated !== node.textContent) {
      node.textContent = updated;
    }
  }

  function rewriteAll() {
    const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT);

    let node;
    while ((node = walker.nextNode())) {
      rewriteNode(node);
    }
  }

  function patchAgentPoolDirectly() {
    // HARD FIX: specifically target "Working on task.xxx"
    const nodes = document.querySelectorAll("*");

    nodes.forEach((el) => {
      if (!el || !el.textContent) return;

      if (el.textContent.includes("Working on task.")) {
        const replaced = replaceIds(el.textContent);
        if (replaced !== el.textContent) {
          el.textContent = replaced;
        }
      }
    });
  }

  function loop() {
    rewriteAll();
    patchAgentPoolDirectly();
  }

  function boot() {
    refreshMap();
    setInterval(refreshMap, 5000);

    loop();
    setInterval(loop, 1000); // aggressive UI sync
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
