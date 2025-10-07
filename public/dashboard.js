// ✅ Dashboard JS – Clean Rebuild

function appendChatMessage(role, text) {
  const chat = document.getElementById("chatWindow");
  if (!chat) return;
  const msg = document.createElement("div");
  msg.classList.add("chat-message");
  const time = new Date().toLocaleTimeString();
  let formatted = text;

  // Try to format JSON nicely
  try {
    const parsed = JSON.parse(text);
    formatted = `<pre>${JSON.stringify(parsed, null, 2)}</pre>`;
  } catch {}

  if (role === "You") {
    msg.classList.add("chat-user");
    msg.innerHTML = `<div><strong>You:</strong> ${formatted}</div><div class="chat-time">${time}</div>`;
  } else {
    msg.classList.add("chat-matilda");
    msg.innerHTML = `<div><strong>${role}:</strong> ${formatted}</div><div class="chat-time">${time}</div>`;
  }

  chat.appendChild(msg);
  chat.scrollTop = chat.scrollHeight;
}

// 💁 Matilda's personality filter
function personaReply(raw) {
  if (!raw) return "…";
  const lower = raw.toLowerCase();

  if (["hi","hello","hey"].some(w => lower.includes(w))) return "👋 Hello there, darling — how can I help today?";
  if (lower.includes("unknown command")) return "📎 Pardon me, love — I don’t recognize that one. Try a supported task instead.";
  if (lower.includes("success")) return "✨ All set — task completed without a hitch.";
  if (lower.includes("error")) return "⚠️ Hmm, something didn’t go quite right. Let’s try again.";
  if (lower.includes("thanks")) return "💐 Always a pleasure!";
  if (lower.includes("bye")) return "👋 Goodbye for now — I’ll be here when you need me.";

  return "💁 " + raw;
}

// 📨 Chat form submit handler
document.getElementById("chatForm").addEventListener("submit", async (e) => {
  e.preventDefault();
  const input = document.getElementById("chatInput");
  const text = input.value.trim();
  if (!text) return;

  appendChatMessage("You", text);
  input.value = "";
  input.focus();

  try {
    const res = await fetch("/matilda", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ command: text })
    });
    const data = await res.json();

    let reply;
    if (data?.cadeResult?.message) {
      reply = data.cadeResult.message;
    } else if (data?.message) {
      reply = data.message;
    } else {
      reply = "✅ Task completed!";
    }

    appendChatMessage("Matilda", personaReply(reply));
  } catch (err) {
    appendChatMessage("⚠️ Error", err.toString());
  }
});

// --- Render functions for dashboard sections ---
async function renderAgents() {
  try {
    const res = await fetch("/status/agents");
    const data = await res.json();
    const table = document.getElementById("agents");
    table.innerHTML = "<tr><th>Agent</th><th>Status</th><th>Last Seen</th></tr>";
    for (const [name, info] of Object.entries(data)) {
      table.innerHTML += `
        <tr>
          <td>${name}</td>
          <td>${info.status}</td>
          <td>${new Date(info.lastSeen).toLocaleString()}</td>
        </tr>`;
    }
  } catch (err) {
    document.getElementById("agents").innerHTML = `<tr><td colspan="3">⚠️ Error: ${err}</td></tr>`;
  }
}

async function renderTasks() {
  try {
    const res = await fetch("/tasks/recent");
    const data = await res.json();
    const table = document.getElementById("tasks");
    table.innerHTML = "<tr><th>ID</th><th>Command</th><th>Status</th><th>Time</th></tr>";
    data.forEach(task => {
      table.innerHTML += `
        <tr>
          <td>${task.id}</td>
          <td>${task.command}</td>
          <td>${task.status}</td>
          <td>${new Date(task.ts).toLocaleString()}</td>
        </tr>`;
    });
  } catch (err) {
    document.getElementById("tasks").innerHTML = `<tr><td colspan="4">⚠️ Error: ${err}</td></tr>`;
  }
}

async function renderLogs() {
  try {
    const res = await fetch("/logs/recent");
    const data = await res.json();
    const table = document.getElementById("logs");
    table.innerHTML = "<tr><th>ID</th><th>Reflection</th><th>Time</th></tr>";
    data.forEach(log => {
      table.innerHTML += `
        <tr>
          <td>${log.id}</td>
          <td>${log.reflection}</td>
          <td>${new Date(log.ts).toLocaleString()}</td>
        </tr>`;
    });
  } catch (err) {
    document.getElementById("logs").innerHTML = `<tr><td colspan="3">⚠️ Error: ${err}</td></tr>`;
  }
}

// 🔄 Refresh sections
async function refreshAll() {
  await renderAgents();
  await renderTasks();
  await renderLogs();
}

document.addEventListener("DOMContentLoaded", () => {
  console.log("⚡ Dashboard ready");
  refreshAll();
  setInterval(refreshAll, 5000);
});

// <0001fbC3> Chat send → Matilda endpoint
document.addEventListener("DOMContentLoaded", () => {
  const input = document.getElementById("userInput");
  const log = document.getElementById("chatLog");

  if (!input || !log) return;

  input.addEventListener("keydown", async (e) => {
    if (e.key === "Enter" && input.value.trim()) {
      const msg = input.value.trim();
      log.innerHTML += `<div><b>You:</b> ${msg}</div>`;
      input.value = "";

      try {
        const res = await fetch("/matilda", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ message: msg }),
        });
        const data = await res.json();
        log.innerHTML += `<div><b>Matilda:</b> ${data.reply}</div>`;
        log.scrollTop = log.scrollHeight;
      } catch (err) {
        log.innerHTML += `<div style="color:red;">Error contacting Matilda</div>`;
      }
    }
  });
});
