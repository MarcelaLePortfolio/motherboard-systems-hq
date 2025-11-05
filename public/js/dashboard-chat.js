// <0001fb1C> ⚡ Phase 7.1.6 — Emergency Inversion Fallback (Guaranteed Readability)
document.addEventListener("DOMContentLoaded", () => {
  const feed = document.querySelector("#chatbotFeed");

  if (feed) {
    // Invert the colors visually to guarantee contrast
    feed.style.filter = "invert(1) hue-rotate(180deg)";
    feed.style.transition = "filter 0.3s ease";

    // Slight background tint for balance
    feed.style.backgroundColor = "#000000";
    feed.style.borderRadius = "8px";
    feed.style.padding = "10px";
    feed.style.overflowY = "auto";
    feed.style.maxHeight = "40vh";
  }

  // Basic chat styles so bubbles stay visible
  const style = document.createElement("style");
  style.textContent = `
    .chat-message {
      border-radius: 8px !important;
      padding: 8px 10px !important;
      margin: 6px 0 !important;
      line-height: 1.4 !important;
      display: inline-block !important;
      max-width: 90% !important;
      word-wrap: break-word !important;
      white-space: pre-wrap !important;
    }
    .chat-message.user {
      background-color: #1e3a8a !important;
      border-color: #3b82f6 !important;
    }
    .chat-message.matilda {
      background-color: #047857 !important;
      border-color: #10b981 !important;
    }
    .chat-message.system {
      background-color: #3f3f46 !important;
      font-style: italic !important;
    }
  `;
  document.head.appendChild(style);

  const input = document.querySelector("#chatbotInput");
  const sendBtn = document.querySelector("#chatbotSend");

  async function sendMessage() {
    const message = input?.value.trim();
    if (!message) return;
    input.value = "";

    const msg = document.createElement("div");
    msg.className = "chat-message user";
    msg.textContent = message;
    feed.appendChild(msg);
    feed.scrollTop = feed.scrollHeight;

    try {
      const res = await fetch("/matilda", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message }),
      });
      const data = await res.json();

      const reply = document.createElement("div");
      reply.className = "chat-message matilda";
      reply.textContent = data?.message || "Matilda responded with no content.";
      feed.appendChild(reply);
      feed.scrollTop = feed.scrollHeight;
    } catch (err) {
      console.error("❌ Error:", err);
      const errMsg = document.createElement("div");
      errMsg.className = "chat-message system";
      errMsg.textContent = "⚠️ Connection error — unable to reach Matilda.";
      feed.appendChild(errMsg);
      feed.scrollTop = feed.scrollHeight;
    }
  }

  if (input) {
    input.addEventListener("keydown", (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        sendMessage();
      }
    });
  }

  sendBtn?.addEventListener("click", sendMessage);
});
