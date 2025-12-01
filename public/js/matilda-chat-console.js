// Matilda Chat Console — Dashboard Injection & Wiring
// Assumes backend /api/chat accepts: { message: string, agent: "matilda" }

(function () {

  function createMatildaCard() {
    if (document.getElementById("matilda-chat-card")) return null;

    const card = document.createElement("div");
    card.id = "matilda-chat-card";
    card.setAttribute("data-section", "matilda-chat");
    card.style.display = "flex";
    card.style.flexDirection = "column";
    card.style.gap = "8px";
    card.style.padding = "16px";
    card.style.borderRadius = "12px";
    card.style.background = "rgba(15, 23, 42, 0.95)";
    card.style.border = "1px solid rgba(148, 163, 184, 0.35)";
    card.style.boxShadow = "0 10px 25px rgba(0, 0, 0, 0.45)";
    card.style.color = "#e5e7eb";

    const header = document.createElement("div");
    header.style.display = "flex";
    header.style.justifyContent = "space-between";
    header.style.alignItems = "center";

    const titleWrap = document.createElement("div");

    const title = document.createElement("h2");
    title.textContent = "Matilda Chat Console";
    title.style.fontSize = "1rem";
    title.style.textTransform = "uppercase";

    const subtitle = document.createElement("div");
    subtitle.textContent = "Direct chat with Matilda — separate from task delegation.";
    subtitle.style.fontSize = "0.75rem";
    subtitle.style.color = "#9ca3af";

    titleWrap.appendChild(title);
    titleWrap.appendChild(subtitle);

    const statusPill = document.createElement("span");
    statusPill.id = "matilda-chat-status-pill";
    statusPill.textContent = "Idle";
    statusPill.style.fontSize = "0.7rem";
    statusPill.style.padding = "4px 10px";
    statusPill.style.borderRadius = "999px";
    statusPill.style.border = "1px solid rgba(148, 163, 184, 0.45)";
    statusPill.style.color = "#9ca3af";

    header.appendChild(titleWrap);
    header.appendChild(statusPill);

    const transcript = document.createElement("div");
    transcript.id = "matilda-chat-output";
    transcript.style.minHeight = "120px";
    transcript.style.maxHeight = "260px";
    transcript.style.overflowY = "auto";
    transcript.style.padding = "10px";
    transcript.style.borderRadius = "10px";
    transcript.style.background = "rgba(15, 23, 42, 0.85)";
    transcript.style.border = "1px solid rgba(55, 65, 81, 0.9)";

    const inputRow = document.createElement("div");
    inputRow.style.display = "flex";
    inputRow.style.gap = "8px";

    const input = document.createElement("textarea");
    input.id = "matilda-chat-input";
    input.rows = 2;
    input.placeholder = "Talk directly to Matilda…";
    input.style.flex = "1 1 0";
    input.style.padding = "8px 10px";
    input.style.borderRadius = "10px";
    input.style.background = "rgba(15, 23, 42, 0.95)";
    input.style.color = "#e5e7eb";

    const button = document.createElement("button");
    button.id = "matilda-chat-send";
    button.textContent = "Send";
    button.style.padding = "0 16px";
    button.style.borderRadius = "999px";
    button.style.background = "linear-gradient(135deg, #4f46e5, #06b6d4)";
    button.style.color = "#fff";
    button.style.fontSize = "0.8rem";
    button.style.textTransform = "uppercase";

    inputRow.appendChild(input);
    inputRow.appendChild(button);

    card.appendChild(header);
    card.appendChild(transcript);
    card.appendChild(inputRow);

    return card;
  }

  function findTaskDelegationAnchor() {
    return (
      document.querySelector('[data-section="task-delegation"]') ||
      document.querySelector("#task-delegation-card") ||
      document.querySelector(".task-delegation-card") ||
      null
    );
  }

  function insertCard(card) {
    const anchor = findTaskDelegationAnchor();
    if (anchor && anchor.parentElement) {
      anchor.parentElement.insertBefore(card, anchor);
      return;
    }
    document.body.insertBefore(card, document.body.firstChild);
  }

  function appendLine(role, text) {
    const transcript = document.getElementById("matilda-chat-output");
    const line = document.createElement("div");
    line.style.marginBottom = "6px";

    const label = document.createElement("span");
    label.textContent = role === "user" ? "You: " : "Matilda: ";
    label.style.fontWeight = "600";
    label.style.marginRight = "6px";

    const span = document.createElement("span");
    span.textContent = text;

    line.appendChild(label);
    line.appendChild(span);
    transcript.appendChild(line);
    transcript.scrollTop = transcript.scrollHeight;
  }

  async function sendMessage() {
    const input = document.getElementById("matilda-chat-input");
    const button = document.getElementById("matilda-chat-send");
    const status = document.getElementById("matilda-chat-status-pill");

    const msg = input.value.trim();
    if (!msg) return;

    input.value = "";
    appendLine("user", msg);

    status.textContent = "Sending…";
    status.style.color = "#f97316";

    button.disabled = true;

    try {
      const res = await fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: msg, agent: "matilda" })
      });

      let data = {};
      try {
        data = await res.json();
      } catch (_) {}

      if (!res.ok) {
        appendLine("matilda", "Error: " + res.status + " — check backend");
      } else {
        appendLine("matilda", data.reply || "[no reply returned]");
      }
    } catch {
      appendLine("matilda", "Network error — is server.mjs running?");
    }

    button.disabled = false;
    status.textContent = "Idle";
    status.style.color = "#9ca3af";
  }

  function wire() {
    const input = document.getElementById("matilda-chat-input");
    const button = document.getElementById("matilda-chat-send");

    button.addEventListener("click", sendMessage);

    input.addEventListener("keydown", function (ev) {
      if (ev.key === "Enter" && !ev.shiftKey) {
        ev.preventDefault();
        sendMessage();
      }
    });
  }

  function init() {
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
