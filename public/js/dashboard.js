// Clean Reset — dashboard.js (Send button only)

const API_URL = "http://localhost:3001/matilda";

// DOM elements
const inputEl = document.getElementById("userInput");
const sendBtn = document.getElementById("sendBtn");
const delegateBtn = document.getElementById("delegateButton");
const chatLogEl = document.getElementById("chatLog");
const agentStatusEl = document.getElementById("agentStatusContainer");

function appendMessage(sender, text) {
  const div = document.createElement("div");
  div.className = `chat-message ${sender}`;
  div.textContent = text;
  chatLogEl.appendChild(div);
  chatLogEl.scrollTop = chatLogEl.scrollHeight;
}

// 🚫 NO Enter key listener — send ONLY via button
sendBtn.addEventListener("click", sendChat);

async function sendChat() {
  const message = inputEl.value.trim();
  if (!message) return;

  appendMessage("user", message);
  inputEl.value = "";

  try {
    const res = await fetch(API_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message }),
    });

    const data = await res.json();
    appendMessage("matilda", data.message || "(no response)");

  } catch (err) {
    appendMessage("system", "⚠️ Matilda unreachable.");
    console.error(err);
  }
}

// Agent status (placeholder)
agentStatusEl.textContent = "Matilda: ONLINE | Cade: ONLINE | Effie: ONLINE";
