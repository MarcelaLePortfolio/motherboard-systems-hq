// Dashboard Chat + Delegation (Send button only + 🚀 delegate)

// API endpoint
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

// 🚫 Enter key does NOTHING — button only
// (Intentionally left empty, no keypress listener)

// =======================================
// 🚀 SEND MESSAGE (BUTTON)
// =======================================
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

// =======================================
// 🚀 DELEGATE BUTTON LOGIC
// =======================================
delegateBtn.addEventListener("click", delegateTask);

async function delegateTask() {
  const message = inputEl.value.trim();
  if (!message) return;

  appendMessage("user", `🚀 Delegate: ${message}`);
  inputEl.value = "";

  try {
    const res = await fetch(API_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        message,
        delegate: true   // 🔥 signals Matilda → Cade → Effie
      }),
    });

    const data = await res.json();

    appendMessage(
      "matilda",
      data.message || "🛠️ Delegation acknowledged (no message returned)."
    );

  } catch (err) {
    appendMessage("system", "⚠️ Delegation failed — Matilda unreachable.");
    console.error(err);
  }
}

// Placeholder agent panel
agentStatusEl.textContent = "Matilda: ONLINE | Cade: ONLINE | Effie: ONLINE";
