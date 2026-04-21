(() => {
  const TASK_ID_RE = /\btask\.[a-f0-9-]{8,}\b/gi;
  const EXCLUDED_TAGS = new Set(["SCRIPT", "STYLE", "NOSCRIPT", "TEXTAREA"]);

  const state = {
    taskMap: new Map(),
    lastFetchOk: false,
  };

  function normalizeTasks(payload) {
    if (!payload) return [];
    if (Array.isArray(payload)) return payload;
    if (Array.isArray(payload.tasks)) return payload.tasks;
    if (Array.isArray(payload.items)) return payload.items;
    return [];
  }

  function bestTitle(task) {
    const candidates = [
      task?.title,
      task?.task_name,
      task?.taskName,
      task?.name,
      task?.summary,
    ];
    for (const value of candidates) {
      if (typeof value === "string" && value.trim()) return value.trim();
    }
    return null;
  }

  function bestId(task) {
    const candidates = [
      task?.task_id,
      task?.taskId,
      task?.id,
    ];
    for (const value of candidates) {
      if (typeof value === "string" && value.trim()) return value.trim();
    }
    return null;
  }

  async function refreshTaskMap() {
    try {
      const res = await fetch("/api/tasks?limit=200", { cache: "no-store" });
      if (!res.ok) return;
      const json = await res.json();
      const tasks = normalizeTasks(json);

      const next = new Map();
      for (const task of tasks) {
        const taskId = bestId(task);
        const title = bestTitle(task);
        if (!taskId || !title) continue;
        next.set(taskId, {
          title,
          status: typeof task?.status === "string" ? task.status.trim() : "",
          agent:
            typeof task?.agent === "string"
              ? task.agent.trim()
              : typeof task?.assigned_agent === "string"
                ? task.assigned_agent.trim()
                : "",
        });
      }

      state.taskMap = next;
      state.lastFetchOk = true;
      humanizeDocument();
    } catch (_) {
      state.lastFetchOk = false;
    }
  }

  function humanizeString(input) {
    if (!input || typeof input !== "string") return input;

    return input.replace(TASK_ID_RE, (rawId) => {
      const match = state.taskMap.get(rawId);
      if (!match?.title) return rawId;
      return match.title;
    });
  }

  function shouldSkipTextNode(node) {
    if (!node || !node.parentElement) return true;
    const parent = node.parentElement;
    if (EXCLUDED_TAGS.has(parent.tagName)) return true;
    if (parent.closest("[data-phase487-humanized-ignore='true']")) return true;
    return false;
  }

  function humanizeTextNode(node) {
    if (shouldSkipTextNode(node)) return;

    const current = node.textContent;
    if (!current || !TASK_ID_RE.test(current)) return;
    TASK_ID_RE.lastIndex = 0;

    if (!node.__phase487OriginalText) {
      node.__phase487OriginalText = current;
    }

    const original = node.__phase487OriginalText;
    const updated = humanizeString(original);

    if (updated !== current) {
      node.textContent = updated;
    }
  }

  function humanizeAttributes(root = document.body) {
    const elements = root.querySelectorAll("[title],[aria-label]");
    for (const el of elements) {
      if (el.hasAttribute("title")) {
        const title = el.getAttribute("title");
        if (title && TASK_ID_RE.test(title)) {
          TASK_ID_RE.lastIndex = 0;
          if (!el.dataset.phase487OriginalTitle) {
            el.dataset.phase487OriginalTitle = title;
          }
          el.setAttribute("title", humanizeString(el.dataset.phase487OriginalTitle));
        }
      }

      if (el.hasAttribute("aria-label")) {
        const aria = el.getAttribute("aria-label");
        if (aria && TASK_ID_RE.test(aria)) {
          TASK_ID_RE.lastIndex = 0;
          if (!el.dataset.phase487OriginalAriaLabel) {
            el.dataset.phase487OriginalAriaLabel = aria;
          }
          el.setAttribute("aria-label", humanizeString(el.dataset.phase487OriginalAriaLabel));
        }
      }
    }
  }

  function humanizeDocument(root = document.body) {
    if (!root) return;
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
    const nodes = [];
    let node;
    while ((node = walker.nextNode())) nodes.push(node);
    for (const textNode of nodes) humanizeTextNode(textNode);
    humanizeAttributes(root);
  }

  function installObserver() {
    const observer = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        for (const node of mutation.addedNodes) {
          if (node.nodeType === Node.TEXT_NODE) {
            humanizeTextNode(node);
            continue;
          }
          if (node.nodeType === Node.ELEMENT_NODE) {
            humanizeDocument(node);
          }
        }

        if (mutation.type === "characterData" && mutation.target?.nodeType === Node.TEXT_NODE) {
          humanizeTextNode(mutation.target);
        }
      }
    });

    observer.observe(document.body, {
      subtree: true,
      childList: true,
      characterData: true,
    });
  }

  function boot() {
    humanizeDocument();
    installObserver();
    refreshTaskMap();
    setInterval(refreshTaskMap, 10000);
    setInterval(humanizeDocument, 4000);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
