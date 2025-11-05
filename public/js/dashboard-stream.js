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

// 🚀 Delegate button functionality
document.getElementById("delegateButton").addEventListener("click", async () => {
  const input = document.getElementById("userInput");
  const text = input.value.trim();
  if (!text) return;

  const response = await fetch("/delegations", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      description: text,
      event_type: "delegation",
      agent: "Cade",
      status: "pending"
    })
  });

  console.log("🚀 Delegation sent:", await response.text());
  input.value = "";
});
