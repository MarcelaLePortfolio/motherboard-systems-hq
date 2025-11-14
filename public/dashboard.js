document.addEventListener("DOMContentLoaded", async () => {
  console.log("📋 DOM fully loaded — dashboard.js executing safely");

  const container = document.getElementById("recentTasks");
  if (!container) return console.warn("⚠️ No #recentTasks container found.");

  try {
    const res = await fetch("/tasks/recent");
    const data = await res.json();

    if (!data.rows || !Array.isArray(data.rows)) {
      container.innerText = "⚠️ No recent tasks available.";
      return;
    }

    container.innerHTML = data.rows
      .map(row => `
        <div style="padding:6px 0;border-bottom:1px solid #222;">
          <b style="color:#00ff7f;">${row.type}</b> — ${row.result || "(no result)"}<br>
          <span style="color:#999;">${row.actor} · ${new Date(row.created_at).toLocaleString()}</span>
        </div>
      `)
      .join("");
  } catch (err) {
    console.error("❌ Failed to load recent tasks:", err);
    container.innerText = "Error loading tasks.";
  }
});
// 🔹 Delegation function
async function delegateTask() {
  const promptInput = document.getElementById("task-input");
  if (!promptInput) return alert("Cannot find task input element!");
  const prompt = promptInput.value;
  if (!prompt) return alert("Please enter a task prompt before delegating.");

  try {
    const response = await fetch("http://localhost:11434/tasks/delegate", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ prompt })
    });
    const data = await response.json();
    if (data.success) {
      alert("✅ Task delegated successfully!");
      promptInput.value = "";
    } else {
      alert("❌ Failed to delegate task.");
    }
  } catch (err) {
    alert("❌ Error submitting delegation task.");
    console.error(err);
  }
}

document.addEventListener("DOMContentLoaded", () => {
  const delegateBtn = document.getElementById("delegate-btn");
  if (delegateBtn) delegateBtn.addEventListener("click", delegateTask);
});
