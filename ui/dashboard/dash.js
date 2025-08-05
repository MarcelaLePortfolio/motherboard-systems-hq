// --- Dashboard Logic with Chat Integration, Project Tracker, Ops Ticker ---
let lastLog = "";

// 1️⃣ Agent Status
async function fetchAgentStatus() {
  const res = await fetch("/api/agent-status");
  const data = await res.json();
  const container = document.getElementById("agent-status");
  if (!container) return;

  container.innerHTML = "";
  ["Matilda", "Cade", "Effie"].forEach((agent) => {
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

// 2️⃣ Ops Stream (Ticker)
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

// 3️⃣ Project Tracker
async function fetchProjectTracker() {
  const res = await fetch("/api/project-tracker");
  const tasks = await res.json();
  const container = document.getElementById("project-tracker");
  if (!container) return;

  container.innerHTML = tasks.map(task => `
    <div class="task ${task.status}">
      <strong>${task.name}</strong> — ${task.agent} (${task.status}${
        task.started ? `, started ${task.started}` : ""
      }${task.ended ? ` → ${task.ended}` : ""})
    </div>
  `).join("");
}

// 4️⃣ Chat Integration
async function sendMessage(message) {
  const chatBox = document.getElementById("chat-log");
  if (!chatBox) return;

  appendMessage("You", message);

  try {
    const res = await fetch("/api/chat", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message })
    });
    const data = await res.json();

    if (data.reply) {
      appendMessage("Matilda", data.reply);
    } else {
      appendMessage("System", "(No response from Matilda)");
    }
  } catch (err) {
    console.error(err);
    appendMessage("System", "(Error sending message)");
  }
}

function appendMessage(sender, text) {
  const chatBox = document.getElementById("chat-log");
  if (!chatBox) return;
  const div = document.createElement("div");
  div.className = "chat-message";
  div.innerHTML = `<strong>${sender}:</strong> ${text}`;
  chatBox.appendChild(div);
  chatBox.scrollTop = chatBox.scrollHeight;
}

// 5️⃣ Chat Form Submit
document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("chat-form");
  if (form) {
    form.addEventListener("submit", (e) => {
      e.preventDefault();
      const input = document.getElementById("chat-input");
      const message = input.value.trim();
      if (!message) return;
      sendMessage(message);
      input.value = "";
    });
  }

  setInterval(fetchAgentStatus, 5000);
  setInterval(fetchOpsStream, 3000);
  setInterval(fetchProjectTracker, 7000);

  fetchAgentStatus();
  fetchOpsStream();
  fetchProjectTracker();
});
