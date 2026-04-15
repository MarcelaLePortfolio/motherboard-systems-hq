(() => {
  if (window.__PHASE490_MATILDA_DEBUG__) return;
  window.__PHASE490_MATILDA_DEBUG__ = true;

  function byId(id) {
    return document.getElementById(id);
  }

  function first() {
    for (const el of arguments) {
      if (el) return el;
    }
    return null;
  }

  function rectHeight(el) {
    if (!el) return 0;
    return Math.round(el.getBoundingClientRect().height || 0);
  }

  function visible(el) {
    if (!el) return false;
    const cs = window.getComputedStyle(el);
    return !el.hasAttribute("hidden") && cs.display !== "none" && cs.visibility !== "hidden";
  }

  function findPieces() {
    const transcript = first(
      byId("matilda-chat-transcript"),
      document.querySelector("#op-panel-chat #matilda-chat-transcript")
    );

    const guidance = first(
      byId("operator-guidance-panel"),
      document.querySelector("#op-panel-chat #operator-guidance-panel")
    );

    const helper = first(
      byId("matilda-helper-text-ops"),
      document.querySelector("#op-panel-chat .text-xs.text-gray-400")
    );

    const inputRow = first(
      document.querySelector("#op-panel-chat .flex.flex-col.md\\:flex-row.md\\:items-center.md\\:justify-between.gap-3"),
      document.querySelector("#op-panel-chat .gap-3"),
      document.querySelector("#op-panel-chat textarea")?.closest("div")
    );

    const textarea = first(
      byId("matilda-input"),
      document.querySelector("#op-panel-chat textarea")
    );

    return { transcript, guidance, helper, inputRow, textarea };
  }

  function render() {
    let panel = document.getElementById("phase490-matilda-debug");
    if (!panel) {
      panel = document.createElement("pre");
      panel.id = "phase490-matilda-debug";
      panel.style.position = "fixed";
      panel.style.top = "10px";
      panel.style.right = "10px";
      panel.style.zIndex = "99999";
      panel.style.background = "rgba(0,0,0,0.85)";
      panel.style.color = "#00ff9c";
      panel.style.fontSize = "11px";
      panel.style.padding = "10px";
      panel.style.borderRadius = "6px";
      panel.style.maxWidth = "320px";
      panel.style.whiteSpace = "pre-wrap";
      panel.style.pointerEvents = "none";
      document.body.appendChild(panel);
    }

    const pieces = findPieces();

    const rows = Object.entries(pieces).map(([name, el]) => {
      if (!el) return `${name}: MISSING`;
      return `${name}: h=${rectHeight(el)} visible=${visible(el)}`;
    });

    const sum = Object.values(pieces)
      .filter(el => el && visible(el))
      .reduce((total, el) => total + rectHeight(el), 0);

    panel.textContent = [
      "PHASE490 MATILDA PIECES",
      ...rows,
      "",
      `SUM = ${sum}`
    ].join("\n");
  }

  function boot() {
    render();
    window.addEventListener("load", render);
    window.addEventListener("resize", () => requestAnimationFrame(render));
    document.addEventListener("click", () => requestAnimationFrame(render));
    setTimeout(render, 500);
    setTimeout(render, 1500);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
