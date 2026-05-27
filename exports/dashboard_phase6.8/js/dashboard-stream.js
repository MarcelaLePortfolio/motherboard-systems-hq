// <0001faf6> Phase 6.5 — Dashboard Stream Loader (with Task Graph)
import { renderTaskActivityGraph } from "./task-activity-graph.js";

export async function handleTaskStream(tasks) {
  try {
    const ctx = document.getElementById("taskActivityCanvas")?.getContext("2d");
    if (ctx && tasks?.length) {
      renderTaskActivityGraph(ctx, tasks);
      console.log("📈 Task activity graph rendered successfully.");
    } else {
      console.log("⚠️ No tasks available or missing canvas context.");
    }
  } catch (err) {
    console.error("❌ Error rendering task graph:", err);
  }
}
