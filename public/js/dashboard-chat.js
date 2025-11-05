// <0001fb1A> ⚡ Phase 7.1.4 — Guaranteed Contrast via Shadow DOM Isolation
document.addEventListener("DOMContentLoaded", () => {
  const container = document.querySelector("#chatbotFeed");
  if (container && !container.shadowRoot) {
    const shadow = container.attachShadow({ mode: "open" });

    // Create a root container for messages
    const innerFeed = document.createElement("div");
    innerFeed.id = "innerFeed";
    shadow.appendChild(innerFeed);

    // Inject guaranteed visible styles
    const style = document.createElement("style");
    style.textContent = `
      :host {
        all: initial;
        display: block;
        background: #111827;
        color: #ffffff;
        font-family: 'Inter', sans-serif;
        border-radius: 8px;
        padding: 12px;
        overflow-y: auto;
        max-height: 40vh;
      }
      .chat-message {
        background: #1e293b;
        color: #ffffff;
        border: 1px solid #374151;
        border-radius: 8px;
        padding: 8px 10px;
        margin: 6px 0;
        line-height: 1.4;
        word-wrap: break-word;
        white-space: pre-wrap;
      }
      .chat-message.user {
        background: #1e3a8a;
        border-color: #3b82f6;
      }
      .chat-message.matilda {
        background: #047857;
        border-color: #10b981;
      }
      .chat-message.system {
        background: #3f3f46;
        color: #e5e7eb;
        font-style: italic;
      }
    `;
    shadow.appendChild(style);

    // Append messages safely within shadow root
    const appendMessage = (role, text) => {
      const msg = document.createElement("div");
      msg.className = `chat-message ${role}`;
      msg.textContent = text;
      innerFeed.appendChild(msg);
      innerFeed.scrollTop = innerFeed.scrollHeight;
    };

    // Restore full send logic
    const input = document.querySelector("#chatbotInput");
    const sendBtn = document.querySelector("#chatbotSend");

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
  }
});
