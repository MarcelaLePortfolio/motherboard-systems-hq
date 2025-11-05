// <0001fb1B> ⚡ Phase 7.1.5 — Absolute Isolation Fix (solid dark output block)
document.addEventListener("DOMContentLoaded", () => {
  // Create a wrapper to override all inherited backgrounds
  const feed = document.querySelector("#chatbotFeed");
  if (feed) {
    const wrapper = document.createElement("div");
    wrapper.id = "chatbotFeedWrapper";
    wrapper.style.backgroundColor = "#000000";
    wrapper.style.color = "#ffffff";
    wrapper.style.padding = "12px";
    wrapper.style.borderRadius = "8px";
    wrapper.style.maxHeight = "40vh";
    wrapper.style.overflowY = "auto";
    wrapper.style.border = "1px solid #333333";

    // Move all existing children inside wrapper
    while (feed.firstChild) wrapper.appendChild(feed.firstChild);
    feed.appendChild(wrapper);
  }

  // Apply global enforced styles
  const style = document.createElement("style");
  style.textContent = `
    body, #chatbotFeed, #chatbotFeedWrapper {
      background-color: #000000 !important;
      color: #ffffff !important;
      -webkit-text-fill-color: #ffffff !important;
      text-shadow: none !important;
    }
    .chat-message {
      background-color: #111827 !important;
      color: #ffffff !important;
      border: 1px solid #374151 !important;
      border-radius: 8px !important;
      padding: 8px 10px !important;
      margin: 6px 0 !important;
      display: inline-block !important;
      word-wrap: break-word !important;
      white-space: pre-wrap !important;
    }
    .chat-message.user {
      background-color: #1e3a8a !important;
      border-color: #3b82f6 !important;
    }
    .chat-message.matilda {
      background-color: #065f46 !important;
      border-color: #10b981 !important;
    }
    .chat-message.system {
      background-color: #3f3f46 !important;
      color: #e5e7eb !important;
      font-style: italic !important;
    }
  `;
  document.head.appendChild(style);

  const input = document.querySelector("#chatbotInput");
  const sendBtn = document.querySelector("#chatbotSend");
  const wrapper = document.querySelector("#chatbotFeedWrapper");

  function appendMessage(role, text) {
    if (!wrapper) return;
    const msg = document.createElement("div");
    msg.className = `chat-message ${role}`;
    msg.textContent = text;
    wrapper.appendChild(msg);
    wrapper.scrollTop = wrapper.scrollHeight;
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
