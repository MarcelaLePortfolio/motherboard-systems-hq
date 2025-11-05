// <0001fb18> ⚡ Phase 7.1.2 — Runtime DOM Enforcement for Dark Output Area
document.addEventListener("DOMContentLoaded", () => {
  const enforceDarkMode = () => {
    const feed = document.querySelector("#chatbotFeed");
    if (feed) {
      feed.style.setProperty("background-color", "#0b0b0b", "important");
      feed.style.setProperty("color", "#ffffff", "important");
      feed.style.setProperty("-webkit-text-fill-color", "#ffffff", "important");
    }

    document.querySelectorAll(".chat-message").forEach((msg) => {
      msg.style.setProperty("background-color", "#111827", "important");
      msg.style.setProperty("color", "#ffffff", "important");
      msg.style.setProperty("-webkit-text-fill-color", "#ffffff", "important");
    });
  };

  // Apply immediately and monitor DOM changes continuously
  enforceDarkMode();
  const observer = new MutationObserver(() => enforceDarkMode());
  observer.observe(document.body, { childList: true, subtree: true });

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
    enforceDarkMode();
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
