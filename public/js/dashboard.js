// Clean Reset — dashboard.js (Enhanced Matilda Response Handling)

const API_URL = "http://localhost:3001/matilda";

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

sendBtn.addEventListener("click", sendChat);
inputEl.addEventListener("keypress", (e) => {
  if (e.key === "Enter") sendChat();
});

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

    // Parse JSON
    const data = await res.json();

    // Matilda sometimes sends "message"
    // and sometimes sends "response" in chunks
    let finalText = "";

    if (data.message) {
      finalText = data.message;
    } else if (data.response) {
      finalText = data.response;
    } else {
      finalText = "(no response)";
    }

    appendMessage("matilda", finalText);

  } catch (err) {
    appendMessage("system", "⚠️ Matilda unreachable.");
    console.error(err);
  }
}

// Static agent status for now
agentStatusEl.textContent = "Matilda: ONLINE | Cade: ONLINE | Effie: ONLINE";
