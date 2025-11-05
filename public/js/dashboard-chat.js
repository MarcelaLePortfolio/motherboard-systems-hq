// <0001fb19> ⚡ Phase 7.1.3 — Reverse Contrast (dark text on light background)
document.addEventListener("DOMContentLoaded", () => {
  const style = document.createElement("style");
  style.textContent = `
    #chatbotFeed {
      background-color: #f3f4f6 !important; /* light gray */
      color: #111827 !important;            /* dark gray text */
      border: 1px solid #d1d5db !important;
      border-radius: 10px !important;
      padding: 12px !important;
      overflow-y: auto !important;
      max-height: 40vh !important;
    }

    .chat-message {
      color: #111827 !important;            /* dark readable text */
      background-color: #ffffff !important; /* white bubble */
      border: 1px solid #d1d5db !important;
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
      background-color: #dbeafe !important; /* light blue */
      border-color: #93c5fd !important;
    }
    .chat-message.matilda {
      background-color: #d1fae5 !important; /* light green */
      border-color: #6ee7b7 !important;
    }
    .chat-message.system {
      background-color: #f3f4f6 !important;
      color: #374151 !important;
      font-style: italic !important;
    }

    #chatbotInput {
      background-color: #ffffff !important;
      color: #111827 !important;
      border: 1px solid #9ca3af !important;
      border-radius: 6px !important;
      padding: 10px 12px !important;
      outline: none !important;
      caret-color: #111827 !important;
    }

    #chatbotInput::placeholder {
      color: #6b7280 !important;
    }

    #chatbotSend {
      background-color: #2563eb !important;
      color: #ffffff !important;
      border: none !important;
      border-radius: 6px !important;
      padding: 8px 14px !important;
      cursor: pointer !important;
      font-weight: 600 !important;
    }
    #chatbotSend:hover {
      filter: brightness(1.15);
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
