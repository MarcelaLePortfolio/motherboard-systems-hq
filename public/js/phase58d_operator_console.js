(() => {
  "use strict";

  const LEGACY_TITLES = new Set([
    "System Reflections",
    "Critical Ops Alerts",
    "Task Activity Over Time",
  ]);

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
          radial-gradient(circle at top left, rgba(30,64,175,0.10), transparent 34%),
          linear-gradient(180deg, rgba(2,6,23,0.98), rgba(2,6,23,1));
      }

      body.phase58d-operator-console [data-phase58d-primary="true"] {
        border: 1px solid rgba(96,165,250,0.22) !important;
        box-shadow: 0 14px 40px rgba(2,6,23,0.42);
      }

      body.phase58d-operator-console [data-phase58d-secondary="true"] {
        border: 1px solid rgba(255,255,255,0.08) !important;
      }

      body.phase58d-operator-console [data-phase58d-muted="true"] {
        opacity: 0.72;
      }

      body.phase58d-operator-console [data-phase58d-hidden="true"] {
        display: none !important;
      }

      #phase58d-operator-banner {
        margin: 0 0 18px 0;
        padding: 14px 16px;
        border-radius: 14px;
        border: 1px solid rgba(96,165,250,0.20);
        background: linear-gradient(180deg, rgba(15,23,42,0.92), rgba(15,23,42,0.78));
        box-shadow: 0 12px 30px rgba(2,6,23,0.32);
      }

      #phase58d-operator-banner .eyebrow {
        display: block;
        margin-bottom: 6px;
        font-size: 11px;
        letter-spacing: 0.16em;
        text-transform: uppercase;
        color: rgba(148,163,184,0.92);
      }

      #phase58d-operator-banner .title {
        display: block;
        font-size: 18px;
        font-weight: 700;
        color: rgba(248,250,252,0.98);
      }

      #phase58d-operator-banner .subtitle {
        display: block;
        margin-top: 6px;
        font-size: 13px;
        color: rgba(191,219,254,0.82);
      }

      #phase58d-signal-strip {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-top: 10px;
      }

      #phase58d-signal-strip .chip {
        padding: 6px 10px;
        border-radius: 999px;
        border: 1px solid rgba(255,255,255,0.10);
        background: rgba(255,255,255,0.04);
        font-size: 12px;
        color: rgba(226,232,240,0.92);
      }

      #phase58d-signal-strip .chip strong {
        color: rgba(255,255,255,0.96);
        font-weight: 600;
      }

      #phase16_reflections_panel[data-phase58d-docked="true"] {
        right: 16px !important;
        bottom: 16px !important;
        width: min(420px, 42vw) !important;
        max-height: 28vh !important;
        opacity: 0.78;
      }

      #phase16_reflections_panel[data-phase58d-docked="true"] #phase16_reflections_log {
        max-height: calc(28vh - 44px) !important;
      }
    `;
    document.head.appendChild(style);
  }

  function findMainColumn() {
    const candidates = qa("main, #dashboard, .dashboard, .container, .grid, .layout");
    if (candidates.length) return candidates[0];
    return document.body;
  }

  function findCards() {
    return qa("section, article, .card, .panel, .rounded-lg, .rounded-xl, .rounded-2xl").filter((el) => {
      if (!(el instanceof HTMLElement)) return false;
      const t = text(el);
      return t.length > 0;
    });
  }

  function findCardByTitle(regex) {
    const headings = qa("h1, h2, h3, h4, h5, strong");
    for (const heading of headings) {
      if (regex.test(text(heading))) {
        const card = heading.closest("section, article, .card, .panel, .rounded-lg, .rounded-xl, .rounded-2xl");
        if (card) return card;
      }
    }
    return null;
  }

  function hideLegacyCards() {
    const cards = findCards();
    for (const card of cards) {
      const heading = q("h1, h2, h3, h4, h5, strong", card);
      const title = text(heading);
      if (LEGACY_TITLES.has(title)) {
        card.setAttribute("data-phase58d-hidden", "true");
      }
    }
  }

  function buildBanner() {
    if (document.getElementById("phase58d-operator-banner")) return;

    const host =
      findCardByTitle(/probe lifecycle|probe event stream|recent tasks|runs/i) ||
      findMainColumn();

    if (!host || !host.parentNode) return;

    const banner = document.createElement("div");
    banner.id = "phase58d-operator-banner";
    banner.innerHTML = `
      <span class="eyebrow">Operator Console</span>
      <span class="title">Probe lifecycle is the primary signal.</span>
      <span class="subtitle">Empty panels are intentional, cold-start safe, and should read as idle rather than broken.</span>
      <div id="phase58d-signal-strip">
        <span class="chip"><strong>Primary:</strong> Probe lifecycle</span>
        <span class="chip"><strong>Secondary:</strong> Event stream</span>
        <span class="chip"><strong>Idle:</strong> Reflections / agent signals</span>
      </div>
    `;

    host.parentNode.insertBefore(banner, host);
  }

  function promotePrimaryCards() {
    const primaryMatchers = [
      /probe lifecycle/i,
      /probe event stream/i,
      /recent tasks/i,
      /^runs$/i,
    ];

    const secondaryMatchers = [
      /reflections/i,
      /ops/i,
      /matilda/i,
      /chat/i,
    ];

    for (const card of findCards()) {
      const heading = q("h1, h2, h3, h4, h5, strong", card);
      const title = text(heading);

      if (primaryMatchers.some((re) => re.test(title))) {
        card.setAttribute("data-phase58d-primary", "true");
      } else if (secondaryMatchers.some((re) => re.test(title))) {
        card.setAttribute("data-phase58d-secondary", "true");
      }
    }
  }

  function softenIndicators() {
    const ids = [
      "#ops-sse-indicator",
      "#reflections-sse-indicator",
      "#phase16-sse-indicator-text",
    ];

    for (const sel of ids) {
      const el = q(sel);
      if (el) el.setAttribute("data-phase58d-muted", "true");
    }
  }

  function dockReflectionOverlay() {
    const panel = q("#phase16_reflections_panel");
    if (!panel) return;
    panel.setAttribute("data-phase58d-docked", "true");

    const status = q("#phase16_reflections_status", panel);
    if (status) {
      const current = text(status);
      if (!current || /waiting for owner\/consumer|waiting for js|HTML loaded/i.test(current)) {
        status.textContent = "reflections: idle";
      }
    }
  }

  function relabelCoreEngine() {
    const labels = qa("div, span, p");
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
    buildBanner();
    hideLegacyCards();
    promotePrimaryCards();
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
