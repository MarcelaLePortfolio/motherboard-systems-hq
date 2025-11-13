// =======================================
// Dashboard Chat + Delegation (Working)
// =======================================

const API_URL = "http://localhost:3001/matilda";

// DOM elements (MATCHING DASHBOARD HTML)
const inputEl = document.getElementById("userInput");
const sendBtn = document.getElementById("sendBtn");
const delegateBtn = document.getElementById("delegateButton");
const chatLogEl = document.getElementById("chatLog");

// ------------------------------
// Helper: append chat messages
// ------------------------------
function appendMessage(sender, text) {
  const div = document.createElement("div");
  div.className = `chat-message ${sender}`;
  div.textContent = text;
  chatLogEl.appendChild(div);
  chatLogEl.scrollTop = chatLogEl.scrollHeight;
}

// ------------------------------
// SEND Button (normal chat)
// ------------------------------
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

// ------------------------------
// 🚀 DELEGATE Button
// ------------------------------
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
        delegate: true,   // <-- CRITICAL FIX
      }),
    });

    const data = await res.json();
    appendMessage("matilda", data.message || "🛠️ Delegation acknowledged.");
  } catch (err) {
    appendMessage("system", "⚠️ Delegation failed.");
    console.error(err);
  }
}
