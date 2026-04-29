(function () {
  if (window.__PHASE534_EXECUTION_INSPECTOR_EXPAND__) return;
  window.__PHASE534_EXECUTION_INSPECTOR_EXPAND__ = true;

  let selectedEventId = "";
  let showJsonForEventId = "";
  let copiedTaskId = "";

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

    const lines = selectedRow.innerText.split("\n").map((line) => line.trim()).filter(Boolean);

    const title = lines[1] || "";
    const meta1 = lines[0] || "";
    const meta2 = lines[2] || "";

    let panel = container.querySelector("[data-expanded-panel]");
    if (!panel) {
      panel = document.createElement("div");
      panel.setAttribute("data-expanded-panel", "true");
      panel.style.marginBottom = "0.5rem";
      panel.style.padding = "0.5rem 0.8rem";
      panel.style.border = "1px solid rgba(51,65,85,0.9)";
      panel.style.borderRadius = "0.75rem";
      panel.style.background = "rgba(15,23,42,0.6)";
      container.prepend(panel);
    }

    panel.innerHTML = `
      <div style="font-size:0.7rem; color:#94a3b8; margin-bottom:0.2rem;">Selected Event</div>

      <div style="font-size:0.85rem; color:#e2e8f0; margin-bottom:0.25rem;">
        ${escapeHtml(title)}
      </div>

      <div style="font-size:0.72rem; color:#cbd5e1;">
        ${escapeHtml(meta1)}
      </div>

      <div style="font-size:0.7rem; color:#64748b; margin-bottom:0.25rem;">
        ${escapeHtml(meta2)}
      </div>

      <div style="display:flex; gap:0.5rem; font-size:0.7rem;">
        <span data-action="copy" style="cursor:pointer; color:#86efac;">Copy ID</span>
        <span data-action="json" style="cursor:pointer; color:#c4b5fd;">
          ${showJsonForEventId === selectedEventId ? "Hide JSON" : "View JSON"}
        </span>
        <span data-action="requeue" style="cursor:pointer; color:#facc15;">Requeue</span>
        <span data-action="retry" style="cursor:pointer; color:#facc15;">Retry</span>
      </div>
    `;

    panel.querySelectorAll("[data-action]").forEach((el) => {
      el.onclick = (e) => {
        e.stopPropagation();
        const action = el.getAttribute("data-action");

        if (action === "copy") {
          navigator.clipboard.writeText(selectedEventId);
          copiedTaskId = selectedEventId;
          el.textContent = "Copied ✓";
          setTimeout(() => {
            el.textContent = "Copy ID";
          }, 1500);
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
