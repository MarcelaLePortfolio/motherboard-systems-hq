// Matilda Chat Console — Dashboard Injection, Wiring, and Debug Beacon
// Purpose: add visible + console debugging so we can confirm the script loads.

(function () {
  console.log("[MatildaChat] matilda-chat-console.js loaded");

  function createDebugBadge() {
    if (document.getElementById("matilda-chat-debug-badge")) return;
    var badge = document.createElement("div");
    badge.id = "matilda-chat-debug-badge";
    badge.textContent = "Matilda Chat JS Loaded";
    badge.style.position = "fixed";
    badge.style.bottom = "10px";
    badge.style.right = "10px";
    badge.style.zIndex = "9999";
    badge.style.fontSize = "10px";
    badge.style.padding = "4px 8px";
    badge.style.borderRadius = "999px";
    badge.style.background = "rgba(15, 23, 42, 0.9)";
    badge.style.color = "#a5b4fc";
    badge.style.border = "1px solid rgba(129, 140, 248, 0.7)";
    badge.style.pointerEvents = "none";
    document.body.appendChild(badge);
  }

  function createMatildaCard() {
    if (document.getElementById("matilda-chat-card")) return null;

    var card = document.createElement("div");
    card.id = "matilda-chat-card";
    card.style.padding = "16px";
    card.style.marginBottom = "16px";
    card.style.borderRadius = "12px";
    card.style.background = "rgba(15, 23, 42, 0.95)";
    card.style.border = "1px solid rgba(148, 163, 184, 0.35)";
    card.style.color = "#e5e7eb";

    var title = document.createElement("h2");
    title.textContent = "Matilda Chat Console";
    title.style.fontSize = "1rem";
    title.style.marginBottom = "8px";

    var transcript = document.createElement("div");
    transcript.id = "matilda-chat-output";
    transcript.style.minHeight = "120px";
    transcript.style.maxHeight = "260px";
    transcript.style.overflowY = "auto";
    transcript.style.background = "rgba(15, 23, 42, 0.85)";
    transcript.style.border = "1px solid rgba(55, 65, 81, 0.9)";
    transcript.style.padding = "8px";
    transcript.style.marginBottom = "8px";

    var input = document.createElement("textarea");
    input.id = "matilda-chat-input";
    input.rows = 2;
    input.placeholder = "Talk to Matilda…";
    input.style.width = "100%";
    input.style.marginBottom = "8px";

    var button = document.createElement("button");
    button.id = "matilda-chat-send";
    button.textContent = "Send";
    button.style.padding = "6px 16px";
    button.style.borderRadius = "6px";
    button.style.background = "#4f46e5";
    button.style.color = "#fff";
    button.style.border = "none";

    card.appendChild(title);
    card.appendChild(transcript);
    card.appendChild(input);
    card.appendChild(button);

    return card;
  }

  function findTaskDelegationAnchor() {
    return (
      document.querySelector('[data-section="task-delegation"]') ||
      document.querySelector("#task-delegation-card") ||
      document.querySelector(".task-delegation-card")
    );
  }

  function insertCard(card) {
    if (!card) return;
    var anchor = findTaskDelegationAnchor();
    if (anchor && anchor.parentElement) {
      anchor.parentElement.insertBefore(card, anchor);
      console.log("[MatildaChat] Card inserted above Task Delegation");
      return;
    }
    document.body.insertBefore(card, document.body.firstChild);
    console.log("[MatildaChat] Card inserted at top of body (fallback)");
  }

  function appendLine(role, text) {
    var transcript = document.getElementById("matilda-chat-output");
    if (!transcript) return;
    var div = document.createElement("div");
    div.textContent = (role === "user" ? "You: " : "Matilda: ") + text;
    transcript.appendChild(div);
    transcript.scrollTop = transcript.scrollHeight;
  }

  async function sendMessage() {
    var input = document.getElementById("matilda-chat-input");
    var msg = input.value.trim();
    if (!msg) return;
    input.value = "";
    appendLine("user", msg);

    try {
      var res = await fetch("/api/chat", {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({ message: msg, agent: "matilda" })
      });
      var data = await res.json().catch(() => ({}));
      appendLine("matilda", data.reply || "[no reply]");
    } catch (e) {
      appendLine("matilda", "[network error]");
    }
  }

  function wire() {
    var btn = document.getElementById("matilda-chat-send");
    var input = document.getElementById("matilda-chat-input");
    if (!btn || !input) return;
    btn.addEventListener("click", sendMessage);
    input.addEventListener("keydown", function (ev) {
      if (ev.key === "Enter" && !ev.shiftKey) {
        ev.preventDefault();
        sendMessage();
      }
    });
  }

  function init() {
    console.log("[MatildaChat] init() running");
    createDebugBadge();
    var card = createMatildaCard();
    insertCard(card);
    wire();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
