// <0001faf7> Phase 6.5.1 — Dynamic Task Graph Loader
import { renderTaskActivityGraph } from "./task-activity-graph.js";

async function fetchTasksAndRender() {
  try {
    const res = await fetch("/tasks");
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const tasks = await res.json();

    const ctx = document.getElementById("taskActivityCanvas")?.getContext("2d");
    if (ctx && tasks?.length) {
      renderTaskActivityGraph(ctx, tasks);
      console.log(`📈 Rendered ${tasks.length} task events`);
    } else {
      console.warn("⚠️ No tasks or missing canvas context.");
    }
  } catch (err) {
    console.error("❌ Failed to load tasks for graph:", err);
  }
}

window.addEventListener("DOMContentLoaded", fetchTasksAndRender);
