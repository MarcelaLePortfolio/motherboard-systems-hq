// <0001fb12> ⚡ Phase 7.0.2 — Force White Font Rendering (Chat Input & Output)
document.addEventListener("DOMContentLoaded", () => {
  // --- Inject stronger contrast overrides for chat UI ---
  const style = document.createElement("style");
  style.setAttribute("data-chat-overrides", "true");
  style.textContent = `
    /* Global dark background and white font enforcement */
    #chatbotContainer, .chatbot-container, body {
      background: #0b0b0b !important;
      color: #ffffff !important;
      font-family: 'Inter', sans-serif !important;
    }

    /* Input field */
    #chatbotInput {
      background: #111827 !important;          /* dark gray */
      color: #ffffff !important;               /* force pure white */
      border: 1px solid #374151 !important;
      border-radius: 8px !important;
      padding: 10px 12px !important;
      outline: none !important;
    }
    #chatbotInput::placeholder {
      color: #d1d5db !important;               /* light gray placeholder */
      opacity: 1 !important;
    }

    /* Send button */
    #chatbotSend {
      background: #2563eb !important;          /* blue-600 */
      color: #ffffff !important;               /* white text */
      border: none !important;
      border-radius: 8px !important;
      padding: 10px 14px !important;
      cursor: pointer !important;
      font-weight: 600;
    }
    #chatbotSend:hover {
      filter: brightness(1.15);
    }

    /* Chat feed container */
    #chatbotFeed {
      background: #0b0b0b !important;
      border: 1px solid #1f2937 !important;
      border-radius: 10px !important;
      padding: 10px !important;
      max-height: 40vh;
      overflow-y: auto;
      color: #ffffff !important;               /* enforce white text globally */
    }

    /* Message bubbles */
    .chat-message {
      display: inline-block;
      max-width: 90%;
      padding: 10px 12px;
      border-radius: 10px;
      margin: 8px 0;
      line-height: 1.4;
      word-wrap: break-word;
      white-space: pre-wrap;
      font-size: 0.95rem;
      color: #ffffff !important;               /* absolute white */
    }
    .chat-message.user {
      background: #1f2937 !important;
      border: 1px solid #374151 !important;
    }
    .chat-message.matilda {
      background: #047857 !important;          /* emerald-700 */
      border: 1px solid #065f46 !important;
    }
    .chat-message.system {
      background: #3f3f46 !important;
      border: 1px dashed #52525b !important;
      font-style: italic;
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
