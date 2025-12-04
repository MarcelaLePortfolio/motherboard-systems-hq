// <0001faf7> Phase 6.5.1 — Dynamic Task Graph Loader
// Dynamic loader for the task activity graph, now wrapped in a guarded init()
// so it doesn't register multiple listeners when the bundle is reloaded.

import { renderTaskActivityGraph } from "./task-activity-graph.js";

async function fetchTasksAndRender() {
try {
const res = await fetch("/tasks");
if (!res.ok) {
throw new Error("HTTP " + res.status);
}
const tasks = await res.json();

```
var canvas = document.getElementById("taskActivityCanvas");
var ctx =
  canvas && typeof canvas.getContext === "function"
    ? canvas.getContext("2d")
    : null;

if (ctx && Array.isArray(tasks) && tasks.length > 0) {
  renderTaskActivityGraph(ctx, tasks);
  console.log("Rendered " + tasks.length + " task events");
} else {
  console.warn("No tasks or missing canvas context.");
}
```

} catch (err) {
console.error("Failed to load tasks for graph:", err);
}
}

/**

* Initialize the dynamic task graph loader in a guarded way so it
* cannot register multiple listeners or re-run unnecessarily.
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

// Optional: expose for manual debugging in the browser console
if (typeof window !== "undefined") {
window.initTaskGraphFromTasks = initTaskGraphFromTasks;
}
