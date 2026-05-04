(() => {
  const state = {
    map: new Map(),
  };

  async function refreshTaskMap() {
    try {
      const res = await fetch("/api/tasks?limit=50");
      const payload = await res.json();

      const tasks = Array.isArray(payload?.tasks)
        ? payload.tasks
        : Array.isArray(payload)
        ? payload
        : [];

      const next = new Map();

      for (const t of tasks) {
        const id = String(t?.task_id ?? t?.taskId ?? t?.id ?? "").trim();
        const title = String(
          t?.title ?? t?.task_name ?? t?.taskName ?? t?.name ?? ""
        ).trim();

        if (id && title) next.set(id, title);
      }

      state.map = next;

      // expose globally for agent pool
      window.__PHASE487_TASK_TITLE_MAP = next;
    } catch (err) {
      console.warn("phase487 humanizer map refresh failed", err);
    }
  }

  function replaceIds(text) {
    if (!text) return text;

    return text.replace(/task\.[a-z0-9\-]+/gi, (match) => {
      const title = state.map.get(match);
      return title || match;
    });
  }

  function rewriteNode(node) {
    if (!node || !node.textContent) return;

    const original = node.__originalText || node.textContent;
    node.__originalText = original;

    const updated = replaceIds(original);

    if (updated !== node.textContent) {
      node.textContent = updated;
    }
  }

  function rewriteAll() {
    const walker = document.createTreeWalker(
      document.body,
      NodeFilter.SHOW_TEXT
    );

    let node;
    while ((node = walker.nextNode())) {
      rewriteNode(node);
    }
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
    refreshTaskMap();
    setInterval(refreshTaskMap, 5000);

    rewriteAll();
    setInterval(rewriteAll, 2000);

    observe();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
