const fs = require("fs");

const dashboardFile = "public/js/dashboard-tasks-widget.js";
let dashboard = fs.readFileSync(dashboardFile, "utf8");

if (!dashboard.includes('execution-inspector:selected-task')) {
  dashboard = dashboard.replace(
    '      ui.listEl.querySelectorAll("button[data-id]").forEach((btn) => {',
    `      ui.listEl.querySelectorAll("[data-task-row][data-task-id]").forEach((row) => {
        row.onclick = () => {
          window.selectedTaskId = row.getAttribute("data-task-id");
          window.dispatchEvent(new CustomEvent("execution-inspector:selected-task", { detail: { taskId: window.selectedTaskId } }));
        };
      });

      ui.listEl.querySelectorAll("button[data-id]").forEach((btn) => {`
  );
}

fs.writeFileSync(dashboardFile, dashboard);

const inspectorFile = "public/js/phase61_recent_history_wire.js";
let inspector = fs.readFileSync(inspectorFile, "utf8");

if (!inspector.includes("const selectedTaskId = window.selectedTaskId || null;")) {
  inspector = inspector.replace(
    "      render(normalize(data));",
    `      const selectedTaskId = window.selectedTaskId || null;
      const rows = normalize(data);
      render(selectedTaskId ? rows.filter((r) => String(r.task_id || r.id || "") === String(selectedTaskId)) : rows);`
  );
}

if (!inspector.includes('window.addEventListener("execution-inspector:selected-task"')) {
  inspector = inspector.replace(
    "  setInterval(tick, REFRESH_MS);",
    `  window.addEventListener("execution-inspector:selected-task", () => tick());
  setInterval(tick, REFRESH_MS);`
  );
}

fs.writeFileSync(inspectorFile, inspector);
