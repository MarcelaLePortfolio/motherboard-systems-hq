(() => {
  "use strict";

  const REFLECTIONS_TEXT = "Waiting for first reflection";
  const OPS_TEXT = "No agent signals yet";
  const TASKS_TEXT = "Waiting for first task event beyond heartbeat";

  function q(sel, root = document) {
    try {
      return root.querySelector(sel);
    } catch {
      return null;
    }
  }

  function qa(sel, root = document) {
    try {
      return Array.from(root.querySelectorAll(sel));
    } catch {
      return [];
    }
  }

  function ensureInlineStyle() {
    if (document.getElementById("phase58c-idle-style")) return;

    const style = document.createElement("style");
    style.id = "phase58c-idle-style";
    style.textContent = `
      .phase58c-idle-state {
        list-style: none;
        border: 1px solid rgba(255,255,255,0.10);
        background: rgba(255,255,255,0.03);
        border-radius: 12px;
        padding: 12px 14px;
        color: rgba(255,255,255,0.78);
        font-size: 12px;
        line-height: 1.45;
      }
      .phase58c-idle-state strong {
        display: block;
        color: rgba(255,255,255,0.92);
        font-weight: 600;
        margin-bottom: 4px;
      }
      .phase58c-idle-state span {
        display: block;
        color: rgba(255,255,255,0.60);
      }
    `;
    document.head.appendChild(style);
  }

  function buildIdleNode(title, detail, tagName = "li") {
    const el = document.createElement(tagName);
    el.className = "phase58c-idle-state";
    el.setAttribute("data-phase58c-idle", "true");

    const strong = document.createElement("strong");
    strong.textContent = title;
    el.appendChild(strong);

    if (detail) {
      const span = document.createElement("span");
      span.textContent = detail;
      el.appendChild(span);
    }

    return el;
  }

  function listHasRealItems(list) {
    const children = Array.from(list.children || []);
    return children.some((child) => {
      if (!(child instanceof HTMLElement)) return false;
      if (child.dataset.phase58cIdle === "true") return false;
      const text = (child.textContent || "").trim();
      return text.length > 0;
    });
  }

  function ensureIdleList(list, title, detail) {
    if (!list) return;
    ensureInlineStyle();

    const existing = q('[data-phase58c-idle="true"]', list);
    const hasReal = listHasRealItems(list);

    if (hasReal) {
      if (existing) existing.remove();
      return;
    }

    if (existing) {
      existing.querySelector("strong")?.replaceChildren(title);
      const detailNode = existing.querySelector("span");
      if (detailNode) detailNode.textContent = detail;
      return;
    }

    const tagName = list.tagName && /^(UL|OL)$/i.test(list.tagName) ? "li" : "div";
    list.appendChild(buildIdleNode(title, detail, tagName));
  }

  function normalizeSSEIndicatorText() {
    const indicators = [
      q("#ops-sse-indicator .meta"),
      q("#reflections-sse-indicator .meta"),
      q("#phase16-sse-indicator-text"),
      q("#phase16_reflections_status"),
    ].filter(Boolean);

    indicators.forEach((node) => {
      const text = (node.textContent || "").trim();
      if (!text) return;

      if (text.includes("disconnected") && text.includes("last: —")) {
        node.textContent = text.replace("disconnected", "idle");
      }

      if (text === "SSE: …") {
        node.textContent = "SSE: idle";
      }

      if (text.toLowerCase().includes("waiting for js")) {
        node.textContent = "reflections: idle";
      }
    });
  }

  function patchReflections() {
    const list =
      q("#reflections-list") ||
      q('[data-role="reflections-list"]') ||
      q('[data-panel="reflections"] ul') ||
      q("#reflections");

    if (!list) return;

    const empty = q("#reflections-empty") || q('[data-role="reflections-empty"]');
    if (empty) empty.style.display = "none";

    ensureIdleList(
      list,
      REFLECTIONS_TEXT,
      "This panel will populate automatically once the first reflection arrives."
    );
  }

  function patchOps() {
    const list = q("#ops-alerts-list") || q('[data-role="ops-alerts-list"]');
    if (!list) return;

    ensureIdleList(
      list,
      OPS_TEXT,
      "Agent activity will appear here when the operator console receives its first signal."
    );
  }

  function patchRecentTasks() {
    const empty = q('[data-empty="recent-tasks"]');
    if (!empty) return;

    const body = q(".text-xs, .text-sm, p, div", empty);
    if (body && (body.textContent || "").includes("heartbeats")) {
      body.textContent = TASKS_TEXT;
    }
  }

  function applyIdleUX() {
    patchReflections();
    patchOps();
    patchRecentTasks();
    normalizeSSEIndicatorText();
  }

  function boot() {
    applyIdleUX();

    const root = document.body || document.documentElement;
    if (!root) return;

    const observer = new MutationObserver(() => {
      applyIdleUX();
    });

    observer.observe(root, {
      childList: true,
      subtree: true,
      characterData: true,
    });

    window.addEventListener("ops.state", applyIdleUX);
    window.addEventListener("reflections.state", applyIdleUX);
    window.addEventListener("mb:ops:update", applyIdleUX);
    window.addEventListener("mb:reflections:update", applyIdleUX);
    window.addEventListener("mb.task.event", applyIdleUX);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
