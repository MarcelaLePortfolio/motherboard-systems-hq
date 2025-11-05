// <0001fb1E> ⚡ Phase 7.1.8 — Full-Screen Overlay Enforcement (Guaranteed Visibility)
document.addEventListener("DOMContentLoaded", () => {
  // Create the overlay element
  const overlay = document.createElement("div");
  overlay.id = "chatOutputOverlay";
  Object.assign(overlay.style, {
    position: "fixed",
    bottom: "0",
    left: "0",
    width: "100%",
    height: "50vh",
    backgroundColor: "#000000",
    color: "#ffffff",
    overflowY: "auto",
    borderTop: "2px solid #1f2937",
    zIndex: "99999",
    padding: "12px",
    fontFamily: "Inter, sans-serif",
  });

  // Optional header to signal override mode
  const header = document.createElement("div");
  header.textContent = "🧩 Chat Output (Visibility Override Active)";
  Object.assign(header.style, {
    fontWeight: "600",
    fontSize: "0.9rem",
    marginBottom: "8px",
    color: "#93c5fd",
  });
  overlay.appendChild(header);

  // Create feed container inside overlay
  const feed = document.createElement("div");
  feed.id = "chatOverlayFeed";
  Object.assign(feed.style, {
    backgroundColor: "#0b0b0b",
    color: "#ffffff",
    padding: "10px",
    borderRadius: "8px",
    border: "1px solid #374151",
    maxHeight: "45vh",
    overflowY: "auto",
  });
  overlay.appendChild(feed);
  document.body.appendChild(overlay);

  // Helper: append messages inside overlay
  const appendMessage = (role, text) => {
    const msg = document.createElement("div");
    msg.className = `chat-message ${role}`;
    msg.textContent = text;
    msg.style.margin = "6px 0";
    msg.style.padding = "8px 10px";
    msg.style.borderRadius = "8px";
    msg.style.display = "inline-block";
    msg.style.wordWrap = "break-word";
    msg.style.whiteSpace = "pre-wrap";
    msg.style.lineHeight = "1.4";

    if (role === "user") {
      msg.style.backgroundColor = "#1e3a8a";
      msg.style.border = "1px solid #3b82f6";
    } else if (role === "matilda") {
      msg.style.backgroundColor = "#065f46";
      msg.style.border = "1px solid #10b981";
    } else if (role === "system") {
      msg.style.backgroundColor = "#3f3f46";
      msg.style.border = "1px dashed #52525b";
      msg.style.fontStyle = "italic";
      msg.style.color = "#e5e7eb";
    } else {
      msg.style.backgroundColor = "#111827";
      msg.style.border = "1px solid #374151";
    }

    feed.appendChild(msg);
    feed.scrollTop = feed.scrollHeight;
  };

  // Find original input and send button
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
      console.error("❌ Error sending:", err);
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
