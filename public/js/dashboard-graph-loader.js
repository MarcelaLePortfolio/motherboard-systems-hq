// <0001faf7> Phase 6.5.1 — Dynamic Task Graph Loader
import { renderTaskActivityGraph } from "./task-activity-graph.js";

async function fetchTasksAndRender() {
try {
const res = await fetch("/tasks");
if (!res.ok) throw new Error(HTTP ${res.status});
const tasks = await res.json();

const canvas = document.getElementById("taskActivityCanvas");
const ctx = canvas && canvas.getContext && canvas.getContext("2d");

if (ctx && Array.isArray(tasks) && tasks.length) {
  renderTaskActivityGraph(ctx, tasks);
  console.log(`📈 Rendered ${tasks.length} task events`);
} else {
  console.warn("⚠️ No tasks or missing canvas context.");
}


} catch (err) {
console.error("❌ Failed to load tasks for graph:", err);
}
}

/**

Initialize the dynamic task graph loader in a guarded way so it

cannot register multiple listeners or re-run unnecessarily.
*/
export function initTaskGraphFromTasks() {
if (typeof window === "undefined" || typeof document === "undefined") {
return;
}

if (window.__taskGraphFromTasksInited) {
return;
}
window.__taskGraphFromTasksInited = true;

if (document.readyState === "loading") {
window.addEventListener("DOMContentLoaded", fetchTasksAndRender);
} else {
fetchTasksAndRender();
}
}
