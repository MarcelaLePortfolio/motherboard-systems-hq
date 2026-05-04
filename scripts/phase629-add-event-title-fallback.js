const fs = require("fs");

const file = "public/js/phase61_recent_history_wire.js";
let src = fs.readFileSync(file, "utf8");

if (!src.includes("resolveTitleFallback")) {
  src = src.replace(
    "function renderGuidance(r) {",
    `function resolveTitleFallback(r) {
  return r.title || r.task_title || r.name || (r.task_id ? "Task " + r.task_id : "Untitled Event");
}

function renderGuidance(r) {`
  );
}

if (!src.includes("resolveTitleFallback(r)")) {
  src = src.replace(
    "${renderGuidance(r)}",
    "${resolveTitleFallback(r)} ${renderGuidance(r)}"
  );
}

fs.writeFileSync(file, src);
