// <0001fc46> Phase 10.3.2 — Chat rendering separation (Matilda replies stacked cleanly)
document.addEventListener("DOMContentLoaded", () => {
  const input = document.getElementById("userInput");
  const sendBtn = document.getElementById("sendBtn");
  const chatLog = document.getElementById("chatLog");

  if (!input || !sendBtn || !chatLog) {
    console.warn("⚠️ Chat UI not found (input/button/log missing)");
    return;
  }

  // Helper: create chat bubble
  function createMessage(content, type) {
    const msg = document.createElement("div");
    msg.className = `chat-message ${type}`;
    msg.innerText = content;
    chatLog.appendChild(msg);

    // Force line separation & scroll into view
    chatLog.appendChild(document.createElement("div")).style.clear = "both";
    chatLog.scrollTop = chatLog.scrollHeight;
  }

  sendBtn.addEventListener("click", async () => {
    const text = input.value.trim();
    if (!text) return;

    createMessage(text, "user");
    input.value = "";

    try {
      const res = await fetch("/matilda", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: text }),
      });
      const data = await res.json();
      createMessage(data.reply || "Matilda didn’t respond.", "bot");
    } catch (err) {
      createMessage("⚠️ Matilda connection error.", "bot");
      console.error(err);
    }
  });
});
