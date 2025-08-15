/* eslint-disable import/no-commonjs */
// ✅ Dashboard JS - Real-Time Agent Status + Matilda Chat Integration

console.log("✅ Dashboard JS executing");

// -------------------- Agent Status --------------------
async function fetchAgentStatus() {
  try {
    const res = await fetch('./agent-status.json');
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    console.log("📡 Fetched agent status:", data);

    const statusMap = {
      matilda: document.getElementById("matilda-indicator"),
      cade: document.getElementById("cade-indicator"),
      effie: document.getElementById("effie-indicator"),
    };

    for (const [agent, el] of Object.entries(statusMap)) {
      const status = data[agent] || "offline";
      const color = status === "online" ? "green" :
                    status === "errored" ? "red" :
                    "gray";
      if (el) el.style.backgroundColor = color;
    }
  } catch (err) {
    console.error("❌ Failed to fetch agent status:", err);
  }
}

fetchAgentStatus();
setInterval(fetchAgentStatus, 5000);

// -------------------- Chat Input --------------------
document.addEventListener("DOMContentLoaded", () => {
  const input = document.getElementById("input");
  const sendBtn = document.querySelector("button");
  const messages = document.getElementById("messages");

  if (!input || !sendBtn || !messages) return;

  // Press Enter to send
  input.addEventListener("keydown", (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      sendBtn.click();
    }
  });

  // Click button to send
  sendBtn.addEventListener("click", async () => {
    const userText = input.value.trim();
    if (!userText) return;

    // Append user message
    const userMsg = document.createElement("div");
    userMsg.className = "message user-message";
    userMsg.textContent = userText;
    messages.appendChild(userMsg);

    // Send to Matilda API
    try {
      const res = await fetch("/api/matilda", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ command: userText })
      });

      const data = await res.json();

      const botMsg = document.createElement("div");
      botMsg.className = "message bot-message";
      botMsg.textContent = data.message || "🤖 No response.";
      messages.appendChild(botMsg);
    } catch (err) {
      const errMsg = document.createElement("div");
      errMsg.className = "message bot-message";
      errMsg.textContent = "⚠️ Failed to contact Matilda.";
      messages.appendChild(errMsg);
    }

    input.value = "";
    messages.scrollTop = messages.scrollHeight;
  });
});
