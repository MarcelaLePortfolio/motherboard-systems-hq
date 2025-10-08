// <0001fbDB> Dashboard Chat – Compatible with full layout (restored Matilda chat)
document.addEventListener("DOMContentLoaded", () => {
  const input = document.querySelector("input[type='text'], #userInput");
  const log = document.getElementById("chatLog") || document.querySelector(".chat-log");
  const sendBtn = document.getElementById("sendBtn") || document.querySelector("button");

  if (!input || !log) return console.warn("⚠️ Chat elements not found.");

  async function sendMessage() {
    const msg = input.value.trim();
    if (!msg) return;
    log.innerHTML += `<div><b>You:</b> ${msg}</div>`;
    input.value = "";

    try {
      const res = await fetch("/matilda", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: msg }),
      });
      const data = await res.json();
      const reply = data.reply || data.result || "✅ Task completed!";
      log.innerHTML += `<div><b>Matilda:</b> ${reply}</div>`;
      log.scrollTop = log.scrollHeight;
    } catch (err) {
      log.innerHTML += `<div style="color:red;">Error contacting Matilda</div>`;
    }
  }

  // Enter key or click → send
  input.addEventListener("keydown", (e) => {
    if (e.key === "Enter") sendMessage();
  });
  sendBtn?.addEventListener("click", sendMessage);
});

/* ----------------- OPS STREAM TICKER ----------------- */
async function refreshOpsStream() {
  try {
    const res = await fetch("/ops");
    const { events } = await res.json();
    const container = document.getElementById("opsStream");
    if (!container) return;
    container.innerHTML = events.map(e => {
      const ts = new Date(e.ts).toLocaleTimeString();
      return `<div>[${ts}] ${e.event}</div>`;
    }).join("");
  } catch (err) {
    console.error("OPS Stream refresh failed", err);
  }
}
setInterval(refreshOpsStream, 3000);

async function refreshCognitivePanel() {
  try {
    const res = await fetch("/cognitive/history");
    const { history } = await res.json();
    const latest = history.at(-1);
    const container = document.getElementById("cognitivePanel");
    if (!container) return;
    container.innerHTML = latest
      ? `<strong>${latest.coherence}</strong> — ${latest.summary}`
      : "No lessons yet.";
  } catch (err) {
    console.error("Cognitive panel refresh failed", err);
  }
}

setInterval(refreshCognitivePanel, 5000);

async function refreshSystemHealth() {
  try {
    const res = await fetch("/system/health");
    const { health } = await res.json();
    const container = document.getElementById("systemHealth");
    if (!container) return;
    const color = health.status === "Operational" ? "green" : "red";
    container.innerHTML = `<strong style="color:${color}">${health.status}</strong> — ${health.summary}`;
  } catch (err) {
    console.error("System Health refresh failed", err);
  }
}

setInterval(refreshSystemHealth, 5000);

async function refreshSystemHealth() {
  try {
    const res = await fetch("/system/health");
    const { health } = await res.json();
    const container = document.getElementById("systemHealth");
    if (!container) return;
    const color = health.status === "Operational" ? "green" : "red";
    const ts = new Date(health.ts).toLocaleTimeString();
    container.innerHTML = `
      <div><strong style="color:${color}">${health.status}</strong> — ${health.summary}</div>
      <div style="font-size:0.9em;color:#555">Last checked: ${ts} | Uptime: ${health.uptimeHr} hrs</div>
    `;
  } catch (err) {
    console.error("System Health refresh failed", err);
  }
}

setInterval(refreshSystemHealth, 5000);
