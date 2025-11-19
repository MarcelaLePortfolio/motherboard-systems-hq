// --- Phase 1 Dashboard Chat Fix with Logging ---
let lastLog = "";

async function fetchAgentStatus() {
  const res = await fetch("/api/agent-status");
  const data = await res.json();
  const container = document.getElementById("agent-status");
  if (!container) return;

  container.innerHTML = "";
  ["Matilda", "Cade", "Effie"].forEach(agent => {
    const info = data[agent];
    if (!info) return;
    const div = document.createElement("div");
    div.className = "agent";

    const dot = document.createElement("span");
    dot.className = `status-dot ${info.status || "offline"}`;

    const name = document.createElement("strong");
    name.textContent = agent;

    div.appendChild(dot);
    div.appendChild(name);
    container.appendChild(div);
  });
}

async function fetchOpsStream() {
  const res = await fetch("/api/ops-stream");
  const data = await res.json();
  const container = document.getElementById("ops-stream");
  if (!container) return;
  const latest = data[data.length - 1]?.message || "";
  if (latest && latest !== lastLog) {
    lastLog = latest;
    container.innerHTML = `<div class="ops-log">${latest}</div>`;
  }
}

// --- Chat Function with Console Logs ---
window.sendMessage = async function () {
  const input = document.getElementById("input");
  const messages = document.getElementById("messages");
  const userText = input.value.trim();
  if (!userText) return;

  console.log("📡 sendMessage fired:", userText);

  // Display user message
  const userMsg = document.createElement("div");
  userMsg.className = "message user-message";
  userMsg.textContent = userText;
  messages.appendChild(userMsg);
  input.value = "";
  messages.scrollTop = messages.scrollHeight;

  try {
    const res = await fetch("/api/chat", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message: userText })
    });

    console.log("📡 POST /api/chat sent, awaiting response...");

    const data = await res.json();
    console.log("🤖 Matilda replied:", data);

    const botMsg = document.createElement("div");
    botMsg.className = "message bot-message";
    botMsg.textContent = data.reply || "(no response)";
    messages.appendChild(botMsg);
    messages.scrollTop = messages.scrollHeight;
  } catch (err) {
    console.error("❌ Chat fetch failed:", err);
    const botMsg = document.createElement("div");
    botMsg.className = "message bot-message";
    botMsg.textContent = "(Error sending message)";
    messages.appendChild(botMsg);
  }
};

// --- Bind Send Button and Enter Key ---
document.addEventListener("DOMContentLoaded", () => {
  const sendButton = document.querySelector("button[onclick='sendMessage()']");
  if (sendButton) {
    sendButton.addEventListener("click", () => sendMessage());
  }

  const input = document.getElementById("input");
  if (input) {
    input.addEventListener("keypress", (e) => {
      if (e.key === "Enter") {
        sendMessage();
        e.preventDefault();
      }
    });
  }

  console.log("✅ Chat bindings initialized");
});

setInterval(fetchAgentStatus, 5000);
setInterval(fetchOpsStream, 3000);
