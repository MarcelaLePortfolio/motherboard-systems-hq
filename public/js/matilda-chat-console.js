// Matilda Chat Console – Restored DOM Injection + Guaranteed Placement Above Task Delegation
// Ensures Matilda Chat always appears even if removed from HTML.

(function () {
  function logInfo(msg) { console.log("[MatildaChat]", msg); }

  // --- Ensure stylesheet is present ---
  function ensureMatildaChatStyles() {
    if (document.querySelector('link[href="/css/matilda-chat.css"]')) return;
    var link = document.createElement("link");
    link.rel = "stylesheet";
    link.href = "/css/matilda-chat.css";
    document.head.appendChild(link);
    logInfo("Injected /css/matilda-chat.css");
  }

  // --- Create Matilda Chat Console if missing ---
  function ensureMatildaChatConsole() {
    if (document.getElementById("matilda-chat-container")) return;

    var headings = Array.from(document.querySelectorAll("h2, h3"));
    var taskHeader = headings.find(h => h.textContent.trim().startsWith("Task Delegation"));

    var taskCard = taskHeader &&
      (taskHeader.closest(".card, .panel, .dashboard-section, section, .tile") ||
       taskHeader.parentElement);

    var chatCard = document.createElement("section");
    chatCard.id = "matilda-chat-container";
    chatCard.className = "dashboard-section card";

    chatCard.innerHTML = `
      <h2>Matilda Chat Console</h2>
      <div id="matilda-chat-log"></div>
      <div id="matilda-chat-input-row">
        <textarea id="matilda-chat-input" rows="2"
          placeholder="Chat with Matilda about tasks, status, or next steps…"></textarea>
        <button id="matilda-chat-send" type="button">Send</button>
      </div>
    `;

    if (taskCard && taskCard.parentElement) {
      taskCard.parentElement.insertBefore(chatCard, taskCard);
      logInfo("Matilda Chat inserted above Task Delegation.");
    } else {
      (document.querySelector("main") || document.body).appendChild(chatCard);
      logInfo("Matilda Chat inserted into main content.");
    }
  }

  // --- Chat actions ---
  async function sendChatMessage() {
    var input = document.getElementById("matilda-chat-input");
    var sendBtn = document.getElementById("matilda-chat-send");
    var logEl = document.getElementById("matilda-chat-log");
    if (!input || !sendBtn || !logEl) return;

    var text = input.value.trim();
    if (!text) return;

    appendMessage(logEl, text, "user");
    input.value = ""; input.focus();

    var thinkingId = appendMessage(logEl, "Matilda is thinking…", "matilda", true);
    sendBtn.disabled = true;

    try {
      var res = await fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: text, agent: "matilda" })
      });

      var data = await res.json();
      removeMessageById(logEl, thinkingId);
      appendMessage(logEl, data.reply || "(no reply)", "matilda");
    } catch {
      removeMessageById(logEl, thinkingId);
      appendMessage(logEl, "Matilda encountered an error.", "matilda");
    }
    sendBtn.disabled = false;
  }

  var msgCounter = 0;

  function appendMessage(logEl, text, role, ephemeral) {
    var div = document.createElement("div");
    var id = "matilda-msg-" + (msgCounter++);
    div.dataset.msgId = id;
    div.className = role === "user" ? "user-msg" : "matilda-msg";
    div.textContent = text;
    if (ephemeral) div.classList.add("ephemeral");
    logEl.appendChild(div);
    logEl.scrollTop = logEl.scrollHeight;
    return id;
  }

  function removeMessageById(logEl, id) {
    var el = logEl.querySelector(`[data-msg-id="${id}"]`);
    if (el) el.remove();
  }

  function wireChatControls() {
    var input = document.getElementById("matilda-chat-input");
    var sendBtn = document.getElementById("matilda-chat-send");
    var logEl = document.getElementById("matilda-chat-log");
    if (!input || !sendBtn || !logEl) return;

    sendBtn.addEventListener("click", sendChatMessage);
    input.addEventListener("keydown", e => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        sendChatMessage();
      }
    });
  }

  // --- Reposition if markup existed but drifted ---
  function repositionMatildaChatCard() {
    var headings = Array.from(document.querySelectorAll("h2, h3"));
    var chatHeader = headings.find(h => h.textContent.trim().startsWith("Matilda Chat Console"));
    var taskHeader = headings.find(h => h.textContent.trim().startsWith("Task Delegation"));
    if (!chatHeader || !taskHeader) return;

    var chatCard = chatHeader.closest(".card, .panel, .dashboard-section, section, .tile") || chatHeader.parentElement;
    var taskCard = taskHeader.closest(".card, .panel, .dashboard-section, section, .tile") || taskHeader.parentElement;

    if (chatCard && taskCard && chatCard !== taskCard) {
      taskCard.parentElement.insertBefore(chatCard, taskCard);
      logInfo("Matilda Chat repositioned above Task Delegation.");
    }
  }

  // --- Fix Critical Ops height ---
  function fixCriticalOpsSize() {
    var panel = document.getElementById("critical-ops-alerts") ||
                document.getElementById("critical-ops-panel");
    if (!panel) return;
    panel.style.maxHeight = "260px";
    panel.style.minHeight = "260px";
    panel.style.overflowY = "auto";
  }

  // --- Chart.js loader + chart creation ---
  function loadChartJs() {
    if (window.Chart) return Promise.resolve();
    return new Promise((resolve, reject) => {
      var script = document.createElement("script");
      script.src = "https://cdn.jsdelivr.net/npm/chart.js";
      script.onload = resolve;
      script.onerror = reject;
      document.head.appendChild(script);
    });
  }

  function createTaskActivityChart() {
    var container =
      document.getElementById("task-activity-over-time") ||
      document.getElementById("task-activity-card");
    if (!container) return;

    var canvas = container.querySelector("#task-activity-chart") ||
      container.appendChild(Object.assign(document.createElement("canvas"), { id: "task-activity-chart" }));

    var ctx = canvas.getContext("2d");
    if (!window.Chart) return;

    new Chart(ctx, {
      type: "line",
      data: {
        labels: ["0m", "5m", "10m", "15m", "20m", "25m", "30m"],
        datasets: [{
          label: "Tasks Completed",
          data: [3, 7, 5, 9, 6, 10, 8],
          tension: 0.35,
          borderWidth: 2,
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false
      }
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    ensureMatildaChatStyles();
    ensureMatildaChatConsole();
    wireChatControls();
    repositionMatildaChatCard();
    fixCriticalOpsSize();

    loadChartJs().then(createTaskActivityChart);
  });
})();
