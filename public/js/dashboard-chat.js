// <0001fb13> ⚡ Phase 7.0.3 — Absolute Font Override for Chat Input & Output
document.addEventListener("DOMContentLoaded", () => {
  // Inject global CSS override for maximum legibility
  const style = document.createElement("style");
  style.setAttribute("data-chat-overrides", "true");
  style.textContent = `
    /* Universal reset for all chat elements */
    #chatbotContainer, .chatbot-container, #chatbotFeed, #chatbotInput, .chat-message, body {
      color: #ffffff !important;
      background-color: #0b0b0b !important;
      font-family: "Inter", "Segoe UI", Arial, sans-serif !important;
      -webkit-text-fill-color: #ffffff !important;
      text-shadow: 0 0 0 #ffffff !important;
    }

    #chatbotInput {
      background: #111827 !important;
      color: #ffffff !important;
      -webkit-text-fill-color: #ffffff !important;
      border: 1px solid #374151 !important;
      border-radius: 8px !important;
      padding: 10px 12px !important;
      outline: none !important;
      caret-color: #ffffff !important;
    }
    #chatbotInput::placeholder {
      color: #d1d5db !important;
      opacity: 1 !important;
    }

    #chatbotSend {
      background: #2563eb !important;
      color: #ffffff !important;
      border: none !important;
      border-radius: 8px !important;
      padding: 10px 14px !important;
      font-weight: 600 !important;
      cursor: pointer !important;
    }
    #chatbotSend:hover {
      filter: brightness(1.15);
    }

    #chatbotFeed {
      border: 1px solid #1f2937 !important;
      border-radius: 10px !important;
      padding: 10px !important;
      max-height: 40vh !important;
      overflow-y: auto !important;
    }

    .chat-message {
      display: inline-block !important;
      max-width: 90% !important;
      padding: 10px 12px !important;
      border-radius: 10px !important;
      margin: 8px 0 !important;
      line-height: 1.4 !important;
      white-space: pre-wrap !important;
      word-wrap: break-word !important;
      font-size: 0.95rem !important;
      color: #ffffff !important;
      -webkit-text-fill-color: #ffffff !important;
      text-shadow: 0 0 0 #ffffff !important;
    }

    .chat-message.user {
      background: #1f2937 !important;
      border: 1px solid #374151 !important;
    }
    .chat-message.matilda {
      background: #047857 !important;
      border: 1px solid #065f46 !important;
    }
    .chat-message.system {
      background: #3f3f46 !important;
      border: 1px dashed #52525b !important;
      font-style: italic !important;
      color: #e5e7eb !important;
    }
  `;
  document.head.appendChild(style);

  const input = document.querySelector("#chatbotInput");
  const sendBtn = document.querySelector("#chatbotSend");
  const feed = document.querySelector("#chatbotFeed");

  function appendMessage(role, text) {
    if (!feed) return;
    const msg = document.createElement("div");
    msg.className = `chat-message ${role}`;
    msg.textContent = text;
    feed.appendChild(msg);
    feed.scrollTop = feed.scrollHeight;
  }

  async function sendMessage() {
    const message = input?.value.trim();
    if (!message) return;
    input.value = "";
    appendMessage("user", message);

    try {
      const res = await fetch("/matilda", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message }),
      });
      const data = await res.json();
      appendMessage("matilda", data?.message || "Matilda responded with no content.");
    } catch (err) {
      console.error("❌ Error sending to Matilda:", err);
      appendMessage("system", "⚠️ Connection error — unable to reach Matilda.");
    }
  }

  sendBtn?.addEventListener("click", sendMessage);
  input?.addEventListener("keypress", (e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      sendMessage();
    }
  });
});
