// <0001fc00> Phase 10.0 — Intentful Chat Flow (click-only send)
document.addEventListener("DOMContentLoaded", () => {
  const sendBtn = document.querySelector("#sendBtn");
  const input = document.querySelector("#chatInput");
  const chatBox = document.querySelector("#chatBox");

  if (!sendBtn || !input || !chatBox) {
    console.warn("⚠️ Chat elements missing — cannot initialize chat");
    return;
  }

  // Helper: append a message bubble
  function appendMessage(sender, text) {
    const msg = document.createElement("div");
    msg.className = `chat-msg ${sender}`;
    msg.innerHTML = `<strong>${sender}:</strong> ${text}`;
    chatBox.appendChild(msg);
    chatBox.scrollTop = chatBox.scrollHeight;
  }

  // Send only when button is clicked
  sendBtn.addEventListener("click", async () => {
    const message = input.value.trim();
    if (!message) return;

    appendMessage("You", message);
    input.value = "";

    try {
      const res = await fetch("http://localhost:3001/matilda", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message }),
      });

      const data = await res.json();
      if (data.reply) {
        appendMessage("Matilda", data.reply);
      } else {
        appendMessage("System", "⚠️ No reply from Matilda.");
      }
    } catch (err) {
      appendMessage("System", "❌ Error sending message to Matilda.");
      console.error(err);
    }
  });

  // Prevent Enter key from sending
  input.addEventListener("keydown", (e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      console.log("↩️ Enter suppressed — use the Send button.");
    }
  });
});
