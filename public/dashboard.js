// <0001fb61> Final demo dashboard wiring — chat + delegate working

console.log("📡 Dashboard Final SSE Handler Initialized");

document.addEventListener("DOMContentLoaded", () => {
  const chatInput   = document.getElementById("userInput");
  const sendBtn     = document.getElementById("sendBtn");
  const delegateBtn = document.getElementById("delegateButton");
  const chatLog     = document.getElementById("chatLog");

  console.log("🔥 Dashboard JS loaded");
  console.log("🔗 DOM bindings:", { chatInput, sendBtn, delegateBtn, chatLog });

  if (!chatInput || !sendBtn || !delegateBtn || !chatLog) {
    console.warn("⚠️ Missing one or more chat DOM elements");
    return;
  }

  function appendToChat(sender, text) {
    const wrapper = document.createElement("div");
    wrapper.className = "mb-2";

    const label = document.createElement("span");
    label.className = "font-bold mr-2";
    label.textContent = sender + ":";

    const body = document.createElement("span");
    body.textContent = text;

    wrapper.appendChild(label);
    wrapper.appendChild(body);
    chatLog.appendChild(wrapper);
    chatLog.scrollTop = chatLog.scrollHeight;
  }

  async function sendMessage(delegate = false) {
    const value = chatInput.value.trim();
    if (!value) return;

    appendToChat("You", value);
    chatInput.value = "";

    try {
      const res = await fetch("/matilda", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: value, delegate }),
      });

      const data = await res.json().catch(() => ({}));
      const reply = data.reply || data.message || JSON.stringify(data);

      appendToChat("Matilda", reply);
    } catch (err) {
      console.error("❌ Error calling /matilda:", err);
      appendToChat("System", "There was an error talking to Matilda.");
    }
  }

  // Normal chat (no delegation)
  sendBtn.addEventListener("click", () => {
    console.log("🖱️ Send button clicked");
    sendMessage(false);
  });

  // Delegated chat (Matilda → Cade/Effie)
  delegateBtn.addEventListener("click", () => {
    console.log("🖱️ Delegate button clicked");
    sendMessage(true);
  });

  // Enter = normal send
  chatInput.addEventListener("keydown", (ev) => {
    if (ev.key === "Enter" && !ev.shiftKey) {
      ev.preventDefault();
      console.log("⌨️ Enter pressed — sending normal message");
      sendMessage(false);
    }
  });
});
