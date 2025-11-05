// <0001fb17> ⚡ Phase 7.1.0 — Full dark-mode lock for chatbot feed
document.addEventListener("DOMContentLoaded", () => {
  // Inject full dark theme on page load
  const style = document.createElement("style");
  style.textContent = `
    body, #chatbotContainer, #chatbotFeed {
      background-color: #0b0b0b !important;
      color: #ffffff !important;
      -webkit-text-fill-color: #ffffff !important;
      text-shadow: none !important;
    }

    #chatbotFeed {
      background-color: #0b0b0b !important;
      border: 1px solid #1f2937 !important;
      border-radius: 8px !important;
      padding: 12px !important;
      overflow-y: auto !important;
      max-height: 40vh !important;
    }

    .chat-message {
      color: #ffffff !important;
      -webkit-text-fill-color: #ffffff !important;
      background-color: #111827 !important;
      border: 1px solid #374151 !important;
      border-radius: 8px !important;
      padding: 8px 10px !important;
      margin: 6px 0 !important;
      line-height: 1.4 !important;
      display: inline-block !important;
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
      color: #e5e7eb !important;
    }

    #chatbotInput {
      background-color: #111827 !important;
      color: #ffffff !important;
      caret-color: #ffffff !important;
      border: 1px solid #374151 !important;
      border-radius: 6px !important;
      padding: 10px 12px !important;
      outline: none !important;
    }

    #chatbotSend {
      background-color: #2563eb !important;
      color: #ffffff !important;
      border: none !important;
      border-radius: 6px !important;
      padding: 8px 14px !important;
      cursor: pointer !important;
    }
    #chatbotSend:hover {
      filter: brightness(1.15);
    }
  `;
  document.head.appendChild(style);

  // Force all chat containers to dark manually (some browsers ignore cascade)
  const darkenElements = () => {
    const targets = [
      document.body,
      document.querySelector("#chatbotFeed"),
      document.querySelector("#chatbotContainer"),
      ...document.querySelectorAll(".chat-message"),
    ].filter(Boolean);
    for (const el of targets) {
      el.style.backgroundColor = "#0b0b0b";
      el.style.color = "#ffffff";
      el.style.setProperty("-webkit-text-fill-color", "#ffffff", "important");
    }
  };

  darkenElements();
  setInterval(darkenElements, 1000);

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
    darkenElements();
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
