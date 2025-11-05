// <0001fb11> ✨ Phase 7.0.1 — Chat Contrast & Legibility Fix + Bridge (Dashboard → Matilda)
document.addEventListener("DOMContentLoaded", () => {
  // --- Inject high-contrast, dark-mode overrides for chat UI ---
  const style = document.createElement("style");
  style.setAttribute("data-chat-overrides", "true");
  style.textContent = `
    /* Container defaults */
    #chatbotContainer, .chatbot-container {
      background: #0b0b0b !important;
      color: #e5e7eb !important;
    }

    /* Input + Button */
    #chatbotInput {
      background: #111827 !important;          /* very dark gray */
      color: #ffffff !important;               /* white text */
      border: 1px solid #374151 !important;    /* slate-700 */
      border-radius: 8px !important;
      padding: 10px 12px !important;
      outline: none !important;
    }
    #chatbotInput::placeholder {
      color: #9ca3af !important;               /* gray-400 */
    }
    #chatbotSend {
      background: #2563eb !important;          /* blue-600 */
      color: #ffffff !important;
      border: none !important;
      border-radius: 8px !important;
      padding: 10px 14px !important;
      cursor: pointer !important;
    }
    #chatbotSend:hover {
      filter: brightness(1.1);
    }

    /* Feed container */
    #chatbotFeed {
      background: #0b0b0b !important;
      border: 1px solid #1f2937 !important;    /* gray-800 */
      border-radius: 10px !important;
      padding: 10px !important;
      max-height: 40vh;
      overflow-y: auto;
    }

    /* Message bubbles */
    .chat-message {
      display: inline-block;
      max-width: 90%;
      padding: 10px 12px;
      border-radius: 10px;
      margin: 8px 0;
      line-height: 1.35;
      word-wrap: break-word;
      white-space: pre-wrap;
      color: #f9fafb;                          /* near-white text for all */
    }
    .chat-message.user {
      background: #1f2937;                     /* gray-800 */
      border: 1px solid #374151;               /* slate-700 */
      align-self: flex-end;
    }
    .chat-message.matilda {
      background: #0f766e;                     /* teal-700 */
      border: 1px solid #115e59;               /* teal-800 */
      align-self: flex-start;
    }
    .chat-message.system {
      background: #3f3f46;                     /* zinc-700 */
      border: 1px dashed #52525b;              /* zinc-600 */
      font-style: italic;
    }

    /* Optional layout support if feed is a flex column */
    #chatbotFeed.flex, #chatbotFeed .feed {
      display: flex;
      flex-direction: column;
      gap: 6px;
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
    // Auto-scroll to newest
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
      appendMessage("matilda", (data && data.message) ? String(data.message) : "Matilda responded with no content.");
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
