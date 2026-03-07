(() => {
  "use strict";

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

  function text(el) {
    return (el?.textContent || "").replace(/\s+/g, " ").trim();
  }

  function ensureStyles() {
    if (document.getElementById("phase58d-operator-console-style")) return;

    const style = document.createElement("style");
    style.id = "phase58d-operator-console-style";
    style.textContent = `
      body.phase58d-operator-console {
        background:
          radial-gradient(circle at top left, rgba(30,64,175,0.08), transparent 34%),
          linear-gradient(180deg, rgba(2,6,23,0.98), rgba(2,6,23,1));
      }

      body.phase58d-operator-console [data-phase58d-primary="true"] {
        border-color: rgba(99,102,241,0.28) !important;
        box-shadow: 0 18px 48px rgba(15,23,42,0.42);
      }

      body.phase58d-operator-console [data-phase58d-secondary="true"] {
        border-color: rgba(255,255,255,0.08) !important;
      }

      body.phase58d-operator-console [data-phase58d-muted="true"] {
        opacity: 0.78;
      }

      #phase16_reflections_panel[data-phase58d-docked="true"] {
        right: 16px !important;
        bottom: 16px !important;
        width: min(420px, 42vw) !important;
        max-height: 28vh !important;
        opacity: 0.82;
      }

      #phase16_reflections_panel[data-phase58d-docked="true"] #phase16_reflections_log {
        max-height: calc(28vh - 44px) !important;
      }
    `;
    document.head.appendChild(style);
  }

  function markCards() {
    const primaryMatchers = [
      /probe event stream/i,
      /recent tasks/i,
      /atlas subsystem/i,
      /system status/i,
      /project visual output/i,
    ];

    const secondaryMatchers = [
      /system reflections/i,
      /operator signals/i,
      /task delegation/i,
      /matilda chat console/i,
      /task activity over time/i,
    ];

    const cards = qa("section, article").filter((el) => {
      if (!(el instanceof HTMLElement)) return false;
      const heading = q("h1, h2, h3, h4, h5", el);
      return Boolean(heading);
    });

    for (const card of cards) {
      const heading = q("h1, h2, h3, h4, h5", card);
      const title = text(heading);

      card.removeAttribute("data-phase58d-primary");
      card.removeAttribute("data-phase58d-secondary");

      if (primaryMatchers.some((re) => re.test(title))) {
        card.setAttribute("data-phase58d-primary", "true");
        continue;
      }

      if (secondaryMatchers.some((re) => re.test(title))) {
        card.setAttribute("data-phase58d-secondary", "true");
      }
    }
  }

  function softenIndicators() {
    const selectors = [
      "#ops-sse-indicator",
      "#reflections-sse-indicator",
      "#phase16-sse-indicator-text",
    ];

    for (const sel of selectors) {
      const el = q(sel);
      if (el) el.setAttribute("data-phase58d-muted", "true");
    }
  }

  function dockReflectionOverlay() {
    const panel = q("#phase16_reflections_panel");
    if (!panel) return;

    panel.setAttribute("data-phase58d-docked", "true");

    const status = q("#phase16_reflections_status", panel);
    if (!status) return;

    const current = text(status);
    if (!current || /waiting for owner\/consumer|waiting for js|html loaded|inline js ran/i.test(current)) {
      status.textContent = "reflections: idle";
    }
  }

  function relabelCoreEngine() {
    const labels = qa("#atlas-status-details p, #atlas-status-details span, #atlas-status-details div");
    for (const el of labels) {
      const t = text(el);
      if (/^Core Engine:/i.test(t) && /Initializing/i.test(t)) {
        el.textContent = "Core Engine: Idle";
        return;
      }
    }
  }

  function apply() {
    ensureStyles();
    document.body.classList.add("phase58d-operator-console");
    markCards();
    softenIndicators();
    dockReflectionOverlay();
    relabelCoreEngine();
  }

  function boot() {
    apply();

    const observer = new MutationObserver(() => apply());
    observer.observe(document.body || document.documentElement, {
      childList: true,
      subtree: true,
      characterData: true,
    });

    window.addEventListener("ops.state", apply);
    window.addEventListener("reflections.state", apply);
    window.addEventListener("mb:ops:update", apply);
    window.addEventListener("mb:reflections:update", apply);
    window.addEventListener("mb.task.event", apply);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
