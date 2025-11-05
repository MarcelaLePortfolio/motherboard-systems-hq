// <0001fb15> ⚡ Phase 7.0.5 — Final Font Override (Absolute White Enforcement)
document.addEventListener("DOMContentLoaded", () => {
  const style = document.createElement("style");
  style.textContent = `
    body, #chatbotContainer, #chatbotFeed, #chatbotInput, .chat-message {
      color: #fff !important;
      background: #0b0b0b !important;
      -webkit-text-fill-color: #fff !important;
      text-shadow: none !important;
    }
    #chatbotInput {
      color: #fff !important;
      background: #111827 !important;
      caret-color: #fff !important;
      -webkit-text-fill-color: #fff !important;
      border: 1px solid #374151 !important;
    }
    .chat-message.user, .chat-message.matilda {
      color: #fff !important;
      -webkit-text-fill-color: #fff !important;
    }
    .chat-message.system {
      color: #e5e7eb !important;
    }
  `;
  document.head.appendChild(style);

  const enforceWhite = (el) => {
    if (!el) return;
    el.style.color = "#fff";
    el.style.setProperty("-webkit-text-fill-color", "#fff", "important");
    el.style.setProperty("caret-color", "#fff", "important");
  };

  const applyAll = () => {
    [
      document.body,
      document.querySelector("#chatbotContainer"),
      document.querySelector("#chatbotFeed"),
      document.querySelector("#chatbotInput"),
      ...document.querySelectorAll(".chat-message"),
    ].forEach(enforceWhite);
  };

  const observer = new MutationObserver(() => applyAll());
  observer.observe(document.body, { childList: true, subtree: true });
  applyAll();

  const input = document.querySelector("#chatbotInput");
  const sendBtn = document.querySelector("#chatbotSend");
  const feed = document.querySelector("#chatbotFeed");

  function appendMessage(role, text) {
    if (!feed) return;
    const msg = document.createElement("div");
    msg.className = `chat-message ${role}`;
    msg.textContent = text;
    enforceWhite(msg);
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
