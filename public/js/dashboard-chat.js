// <0001fb14> ⚡ Phase 7.0.4 — Nuclear Font Fix (Inline DOM Enforcement)
document.addEventListener("DOMContentLoaded", () => {
  // Apply inline styles dynamically to guarantee browser obedience
  const applyInlineFix = () => {
    const allTargets = [
      document.body,
      document.querySelector("#chatbotContainer"),
      document.querySelector("#chatbotFeed"),
      document.querySelector("#chatbotInput"),
      ...document.querySelectorAll(".chat-message")
    ].filter(Boolean);

    for (const el of allTargets) {
      el.style.setProperty("color", "#ffffff", "important");
      el.style.setProperty("backgroundColor", "#0b0b0b", "important");
      el.style.setProperty("-webkit-text-fill-color", "#ffffff", "important");
      el.style.setProperty("textShadow", "0 0 0 #ffffff", "important");
      el.style.setProperty("caretColor", "#ffffff", "important");
    }
  };

  // CSS injection for new messages
  const style = document.createElement("style");
  style.textContent = `
    .chat-message.user {
      background: #1f2937 !important;
      border: 1px solid #374151 !important;
      color: #ffffff !important;
    }
    .chat-message.matilda {
      background: #047857 !important;
      border: 1px solid #065f46 !important;
      color: #ffffff !important;
    }
    .chat-message.system {
      background: #3f3f46 !important;
      border: 1px dashed #52525b !important;
      color: #e5e7eb !important;
      font-style: italic;
    }
    #chatbotInput {
      background: #111827 !important;
      color: #ffffff !important;
      border: 1px solid #374151 !important;
      border-radius: 8px !important;
      padding: 10px 12px !important;
      outline: none !important;
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
    msg.style.color = "#ffffff";
    msg.style.webkitTextFillColor = "#ffffff";
    feed.appendChild(msg);
    feed.scrollTop = feed.scrollHeight;
    applyInlineFix(); // reinforce color after each addition
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

  // Run fix immediately and every 2s to ensure persistence
  applyInlineFix();
  setInterval(applyInlineFix, 2000);
});
