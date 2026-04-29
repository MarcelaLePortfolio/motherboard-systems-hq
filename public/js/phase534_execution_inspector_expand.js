(function () {
  if (window.__PHASE534_EXECUTION_INSPECTOR_EXPAND__) return;
  window.__PHASE534_EXECUTION_INSPECTOR_EXPAND__ = true;

  let selectedEventId = "";
  let showJsonForEventId = "";
  let copiedTaskId = false;

  function root() {
    return document.getElementById("mb-task-events-panel-anchor");
  }

  function escapeHtml(value) {
    return String(value ?? "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function enhance() {
    const container = root();
    if (!container) return;

    const rows = container.querySelectorAll("[data-task-event-id]");
    if (!rows.length) return;

    rows.forEach((row) => {
      row.style.cursor = "pointer";

      row.onclick = () => {
        selectedEventId = row.getAttribute("data-task-event-id") || "";
        renderExpanded();
      };
    });
  }

  function renderExpanded() {
    const container = root();
    if (!container) return;

    const selectedRow = container.querySelector(`[data-task-event-id="${selectedEventId}"]`);
    if (!selectedRow) return;

    const content = selectedRow.innerText;

    const existing = container.querySelector("[data-expanded-panel]");
    if (existing) existing.remove();

    const panel = document.createElement("div");
    panel.setAttribute("data-expanded-panel", "true");
    panel.style.border = "1px solid rgba(55,65,81,1)";
    panel.style.background = "#020617";
    panel.style.borderRadius = "0.75rem";
    panel.style.padding = "0.6rem";
    panel.style.marginBottom = "0.5rem";
    panel.style.fontSize = "0.75rem";
    panel.style.color = "#cbd5e1";

    panel.innerHTML = `
      <div style="font-size:.7rem; color:#94a3b8; margin-bottom:.25rem;">Selected Event</div>
      <div style="margin-bottom:.4rem;">${escapeHtml(content)}</div>

      <div style="display:flex; gap:.5rem; font-size:.7rem;">
        <span data-action="copy" style="cursor:pointer; color:#86efac;">
          ${copiedTaskId ? "Copied ✓" : "Copy ID"}
        </span>
        <span data-action="json" style="cursor:pointer; color:#c4b5fd;">
          ${showJsonForEventId === selectedEventId ? "Hide JSON" : "View JSON"}
        </span>
      </div>

      ${showJsonForEventId === selectedEventId ? `
        <pre style="margin-top:.4rem; max-height:8rem; overflow:auto; background:#020617; border:1px solid #374151; padding:.4rem; border-radius:.5rem;">${escapeHtml(content)}</pre>
      ` : ""}
    `;

    container.prepend(panel);

    panel.querySelectorAll("[data-action]").forEach((el) => {
      el.onclick = (e) => {
        e.stopPropagation();

        const action = el.getAttribute("data-action");

        if (action === "copy") {
          navigator.clipboard.writeText(content);
          copiedTaskId = true;
          renderExpanded();
          setTimeout(() => {
            copiedTaskId = false;
            renderExpanded();
          }, 1200);
        }

        if (action === "json") {
          showJsonForEventId = showJsonForEventId === selectedEventId ? "" : selectedEventId;
          renderExpanded();
        }
      };
    });
  }

  function boot() {
    setInterval(enhance, 500);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
