document.addEventListener("DOMContentLoaded", async () => {
  console.log("📋 DOM fully loaded — dashboard.js executing safely");

  // Helper: create collapsible section
  function createCollapsibleSection(id, title, contentHTML = "") {
    return `
      <details id="${id}" open style="margin-bottom:10px;">
        <summary style="cursor:pointer;font-weight:bold;font-size:1.1em;color:#c87b36;">
          ${title}
        </summary>
        <div class="collapsible-content" style="padding:6px 0 0 8px;">
          ${contentHTML}
        </div>
      </details>
    `;
  }

  const container = document.getElementById("recentTasks");
  if (!container) return console.warn("⚠️ No #recentTasks container found.");

  try {
    const res = await fetch("/tasks/recent");
    const data = await res.json();

    if (!data.rows || !Array.isArray(data.rows)) {
      container.innerHTML = createCollapsibleSection(
        "recentTasksSection",
        "Recent Tasks",
        "<p>⚠️ No recent tasks available.</p>"
      );
      return;
    }

    const rowsHTML = data.rows
      .map(
        (row) => `
        <div style="padding:6px 0;border-bottom:1px solid #222;">
          <b style="color:#00ff7f;">${row.type}</b> — ${row.result || "(no result)"}<br>
          <span style="color:#999;">${row.actor} · ${new Date(
            row.created_at
          ).toLocaleString()}</span>
        </div>`
      )
      .join("");

    container.innerHTML = createCollapsibleSection(
      "recentTasksSection",
      "Recent Tasks",
      rowsHTML
    );
  } catch (err) {
    console.error("❌ Failed to load recent tasks:", err);
    container.innerHTML = createCollapsibleSection(
      "recentTasksSection",
      "Recent Tasks",
      "<p>Error loading tasks.</p>"
    );
  }
});
