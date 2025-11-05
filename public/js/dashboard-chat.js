// <0001fb1D> ⚡ Phase 7.1.7 — Dark Overlay Feed (Guaranteed Legibility)
document.addEventListener("DOMContentLoaded", () => {
  // Try to find an existing feed container
  const feedEl =
    document.querySelector("#chatbotFeed") ||
    document.querySelector("[data-chat-feed]") ||
    document.querySelector(".chat-feed") ||
    document.querySelector("#chatbot") ||
    document.querySelector(".chatbot-feed") ||
    null;

  // Build overlay even if we couldn't find a canonical feed (fallback to body)
  const host = feedEl?.parentElement || document.body;

  // Ensure host can position an absolute overlay
  if (host && getComputedStyle(host).position === "static") {
    host.style.position = "relative";
  }

  // Create the overlay container
  const overlay = document.createElement("div");
  overlay.id = "chatOverlayFeed";
  Object.assign(overlay.style, {
    position: "absolute",
    inset: "0",
    backgroundColor: "#0b0b0b",
    color: "#ffffff",
    borderRadius: "8px",
    border: "1px solid #1f2937",
    padding: "12px",
    overflowY: "auto",
    maxHeight: feedEl ? `${feedEl.clientHeight || 400}px` : "40vh",
    zIndex: "9999",
  });

  // Optional: hide the original feed so its light background doesn't bleed through
  if (feedEl) {
    feedEl.style.display = "none";
  }

  // Insert overlay into the same visual slot
  host.appendChild(overlay);

  // Styles for message bubbles (scoped to overlay via an injected <style>)
  const style = document.createElement("style");
  style.textContent = `
    #chatOverlayFeed .chat-message {
      background-color: #111827;
      color: #ffffff;
      border: 1px solid #374151;
      border-radius: 8px;
      padding: 8px 10px;
      margin: 6px 0;
      line-height: 1.4;
      display: inline-block;
      max-width: 90%;
      word-wrap: break-word;
      white-space: pre-wrap;
    }
    #chatOverlayFeed .chat-message.user {
      background-color: #1e3a8a;
      border-color: #3b82f6;
    }
    #chatOverlayFeed .chat-message.matilda {
      background-color: #065f46;
      border-color: #10b981;
    }
    #chatOverlayFeed .chat-message.system {
      background-color: #3f3f46;
      border-color: #52525b;
      color: #e5e7eb;
      font-style: italic;
    }
  `;
  document.head.appendChild(style);

  // Find input & send controls
  const input =
    document.querySelector("#chatbotInput") ||
    document.querySelector('input[type="text"][name*="chat"]') ||
    document.querySelector('textarea[name*="chat"]');

  const sendBtn =
    document.querySelector("#chatbotSend") ||
    document.querySelector('button[name*="send"]') ||
    document.querySelector('button[aria-label*="send" i]');

  // Render helper
  function appendMessage(role, text) {
    const msg = document.createElement("div");
    msg.className = `chat-message ${role}`;
    msg.textContent = text;
    overlay.appendChild(msg);
    overlay.scrollTop = overlay.scrollHeight;
  }

  // Send flow
  async function sendMessage() {
    const message = input?.value?.trim();
    if (!message) return;
    if (input) input.value = "";
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
      console.error("❌ Error reaching /matilda:", err);
      appendMessage("system", "⚠️ Connection error — unable to reach Matilda.");
    }
  }

  // Wire events
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
