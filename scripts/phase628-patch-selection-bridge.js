const fs = require("fs");

function patchFile(file, transforms) {
  let src = fs.readFileSync(file, "utf8");
  for (const [needle, replacement] of transforms) {
    if (!src.includes(replacement) && src.includes(needle)) {
      src = src.replace(needle, replacement);
    }
  }
  fs.writeFileSync(file, src);
}

patchFile("public/js/dashboard-tasks-widget.js", [
  [
    `<div style="display:flex;justify-content:space-between;gap:8px">`,
    `<div data-task-row="true" data-task-id="\${esc(t.id)}" style="display:flex;justify-content:space-between;gap:8px;cursor:pointer">`
  ],
  [
    `ui.listEl.querySelectorAll("button[data-id]").forEach((btn) => {`,
    `ui.listEl.querySelectorAll("[data-task-row][data-task-id]").forEach((row) => {
        row.onclick = () => {
          window.selectedTaskId = row.getAttribute("data-task-id");
          window.dispatchEvent(new CustomEvent("execution-inspector:selected-task", { detail: { taskId: window.selectedTaskId } }));
        };
      });

      ui.listEl.querySelectorAll("button[data-id]").forEach((btn) => {`
  ]
]);

patchFile("public/js/phase61_recent_history_wire.js", [
  [
    `render(normalize(data));`,
    `const selectedTaskId = window.selectedTaskId || null;
      const rows = normalize(data);
      render(selectedTaskId ? rows.filter((r) => String(r.task_id || r.id || "") === String(selectedTaskId)) : rows);`
  ],
  [
    `setInterval(tick, REFRESH_MS);`,
    `window.addEventListener("execution-inspector:selected-task", () => tick());
  setInterval(tick, REFRESH_MS);`
  ]
]);
