// Matilda Chat Console — improved placement & debug

(function () {
  console.log("[MatildaChat] matilda-chat-console.js loaded");

  function createDebugBadge() {
    if (document.getElementById("matilda-chat-debug-badge")) return;
    const badge = document.createElement("div");
    badge.id = "matilda-chat-debug-badge";
    badge.textContent = "Matilda Chat JS Loaded";
    badge.style.position = "fixed";
    badge.style.bottom = "10px";
    badge.style.right = "10px";
    badge.style.zIndex = "9999";
    badge.style.fontSize = "10px";
    badge.style.padding = "4px 8px";
    badge.style.borderRadius = "999px";
    badge.style.background = "rgba(15,23,42,0.9)";
    badge.style.color = "#a5b4fc";
    badge.style.border = "1px solid rgba(129,140,248,0.7)";
    document.body.appendChild(badge);
  }

  function createMatildaCard() {
    if (document.getElementById("matilda-chat-card")) return null;

    const card = document.createElement("div");
    card.id = "matilda-chat-card";
    card.style.padding = "16px";
    card.style.margin = "16px 0";
    card.style.borderRadius = "12px";
    card.style.background = "rgba(15,23,42,0.95)";
    card.style.border = "1px solid rgba(148,163,184,0.35)";
    card.style.color = "#e5e7eb";

    const title = document.createElement("h2");
    title.textContent = "Matilda Chat Console";
    title.style.fontSize = "1rem";
    title.style.marginBottom = "8px";

    const subtitle = document.createElement("div");
    subtitle.textContent = "Direct chat with Matilda — this does NOT create tasks.";
    subtitle.style.fontSize = "0.8rem";
    subtitle.style.color = "#9ca3af";
    subtitle.style.marginBottom = "8px";

    const transcript = document.createElement("div");
    transcript.id = "matilda-chat-output";
    transcript.style.minHeight = "120px";
    transcript.style.maxHeight = "260px";
    transcript.style.overflowY = "auto";
    transcript.style.background = "rgba(15,23,42,0.85)";
    transcript.style.border = "1px solid rgba(55,65,81,0.9)";
    transcript.style.padding = "8px";
    transcript.style.marginBottom = "8px";

    const input = document.createElement("textarea");
    input.id = "matilda-chat-input";
    input.rows = 2;
    input.placeholder = "Message Matilda…";
    input.style.width = "100%";
    input.style.marginBottom = "8px";

    const button = document.createElement("button");
    button.id = "matilda-chat-send";
    button.textContent = "Send";
    button.style.padding = "6px 16px";
    button.style.borderRadius = "999px";
    button.style.background = "#4f46e5";
    button.style.color = "#fff";
    button.style.border = "none";

    card.appendChild(title);
    card.appendChild(subtitle);
    card.appendChild(transcript);
    card.appendChild(input);
    card.appendChild(button);

    return card;
  }

  function insertCard(card) {
    const header = document.querySelector("header");

    if (header && header.parentNode) {
      header.parentNode.insertBefore(card, header.nextSibling);
      console.log("[MatildaChat] Card inserted after header");
      return;
    }

    document.body.insertBefore(card, document.body.firstChild);
    console.log("[MatildaChat] Card inserted at top of body (fallback)");
  }

  function appendLine(role, text) {
    const transcript = document.getElementById("matilda-chat-output");
    if (!transcript) return;
    const div = document.createElement("div");
    div.textContent = (role === "user" ? "You: " : "Matilda: ") + text;
    transcript.appendChild(div);
    transcript.scrollTop = transcript.scrollHeight;
  }

  async function sendMessage() {
    const input = document.getElementById("matilda-chat-input");
    const msg = (input.value || "").trim();
    if (!msg) return;
    input.value = "";

    appendLine("user", msg);

    try {
      const res = await fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: msg, agent: "matilda" })
      });

      const data = await res.json().catch(() => ({}));
      appendLine("matilda", data.reply || "[no reply]");
    } catch {
      appendLine("matilda", "[network error]");
    }
  }

  function wire() {
    const btn = document.getElementById("matilda-chat-send");
    const input = document.getElementById("matilda-chat-input");
    if (!btn || !input) return;

    btn.addEventListener("click", sendMessage);

    input.addEventListener("keydown", ev => {
      if (ev.key === "Enter" && !ev.shiftKey) {
        ev.preventDefault();
        sendMessage();
      }
    });
  }

  function init() {
    console.log("[MatildaChat] init() running");
    createDebugBadge();
    const card = createMatildaCard();
    insertCard(card);
    wire();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
