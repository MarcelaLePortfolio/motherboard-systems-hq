import "./sse-ops.js";

const chatForm = document.getElementById("matilda-chat-form");
const chatInput = document.getElementById("matilda-chat-input");
const chatOutput = document.getElementById("project-viewport-output");

async function sendChat(message) {
  const res = await fetch("/api/chat", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ message, agent: "matilda" })
  });
  const data = await res.json();
  return data.response || JSON.stringify(data);
}

if (chatForm) {
  chatForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const text = chatInput.value.trim();
    if (!text) return;

    chatOutput.innerHTML = "<p><em>Matilda is thinking…</em></p>";

    try {
      const reply = await sendChat(text);
      chatOutput.innerHTML = `<div class="matilda-reply">${reply}</div>`;
    } catch (err) {
      chatOutput.innerHTML = `<p style="color:red;">Chat error: ${err}</p>`;
    }

    chatInput.value = "";
  });
}

