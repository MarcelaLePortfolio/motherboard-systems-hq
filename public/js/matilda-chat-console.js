// Matilda Chat Console – Phase 2 Helpers
// - Guarantees Matilda Chat console exists
// - Positions it above Task Delegation
// - Fixes Critical Ops Alerts height
// - Recreates Task Activity Over Time chart
// - Adds a Project Visual Output card below Atlas Subsystem Status
// - Narrows the Task Delegation / Atlas column via CSS class

(function () {
  function logInfo(msg) {
    console.log("[MatildaChat]", msg);
  }

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

    var headings = Array.prototype.slice.call(
      document.querySelectorAll("h2, h3")
    );
    var taskHeader = headings.find(function (h) {
      return h.textContent.trim().indexOf("Task Delegation") === 0;
    });

    var taskCard =
      taskHeader &&
      (taskHeader.closest(
        ".card, .panel, .dashboard-section, section, .tile"
      ) ||
        taskHeader.parentElement);

    var chatCard = document.createElement("section");
    chatCard.id = "matilda-chat-container";
    chatCard.className = "dashboard-section card";

    chatCard.innerHTML =
      '<h2>Matilda Chat Console</h2>' +
      '<div id="matilda-chat-log"></div>' +
      '<div id="matilda-chat-input-row">' +
      '  <textarea id="matilda-chat-input" rows="2" placeholder="Chat with Matilda about tasks, status, or next steps…"></textarea>' +
      '  <button id="matilda-chat-send" type="button">Send</button>' +
      "</div>";

    if (taskCard && taskCard.parentElement) {
      taskCard.parentElement.insertBefore(chatCard, taskCard);
      taskCard.classList.add("delegation-column-card");
      logInfo("Matilda Chat inserted above Task Delegation.");
    } else {
      (document.querySelector("main") || document.body).appendChild(chatCard);
      logInfo("Matilda Chat inserted into main content.");
    }
  }

  // --- Chat actions ---
  var msgCounter = 0;

  function appendMessage(logEl, text, role, ephemeral) {
    var div = document.createElement("div");
    var id = "matilda-msg-" + msgCounter++;
    div.dataset.msgId = id;
    div.className = role === "user" ? "user-msg" : "matilda-msg";
    div.textContent = text;
    if (ephemeral) div.classList.add("ephemeral");
    logEl.appendChild(div);
    logEl.scrollTop = logEl.scrollHeight;
    return id;
  }

  function removeMessageById(logEl, id) {
    if (!id) return;
    var el = logEl.querySelector('[data-msg-id="' + id + '"]');
    if (el) el.remove();
  }

  async function sendChatMessage() {
    var input = document.getElementById("matilda-chat-input");
    var sendBtn = document.getElementById("matilda-chat-send");
    var logEl = document.getElementById("matilda-chat-log");
    if (!input || !sendBtn || !logEl) return;

    var text = input.value.trim();
    if (!text) return;

    appendMessage(logEl, text, "user");
    input.value = "";
    input.focus();

    var thinkingId = appendMessage(
      logEl,
      "Matilda is thinking…",
      "matilda",
      true
    );
    sendBtn.disabled = true;

    try {
      var res = await fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: text, agent: "matilda" }),
      });

      var data = await res.json();
      removeMessageById(logEl, thinkingId);
      appendMessage(logEl, (data && data.reply) || "(no reply)", "matilda");
    } catch (err) {
      console.error("[MatildaChat] Error sending message:", err);
      removeMessageById(logEl, thinkingId);
      appendMessage(
        logEl,
        "Matilda encountered an error reaching the backend.",
        "matilda"
      );
    }

    sendBtn.disabled = false;
  }

  function wireChatControls() {
    var input = document.getElementById("matilda-chat-input");
    var sendBtn = document.getElementById("matilda-chat-send");
    var logEl = document.getElementById("matilda-chat-log");
    if (!input || !sendBtn || !logEl) return;

    sendBtn.addEventListener("click", function () {
      sendChatMessage();
    });

    input.addEventListener("keydown", function (e) {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        sendChatMessage();
      }
    });
  }

  // --- Reposition Matilda Chat above Task Delegation if both exist ---
  function repositionMatildaChatCard() {
    var headings = Array.prototype.slice.call(
      document.querySelectorAll("h2, h3")
    );
    var chatHeader = headings.find(function (h) {
      return h.textContent.trim().indexOf("Matilda Chat Console") === 0;
    });
    var taskHeader = headings.find(function (h) {
      return h.textContent.trim().indexOf("Task Delegation") === 0;
    });
    if (!chatHeader || !taskHeader) return;

    var chatCard =
      chatHeader.closest(".card, .panel, .dashboard-section, section, .tile") ||
      chatHeader.parentElement;
    var taskCard =
      taskHeader.closest(".card, .panel, .dashboard-section, section, .tile") ||
      taskHeader.parentElement;

    if (chatCard && taskCard && chatCard !== taskCard && taskCard.parentElement) {
      taskCard.parentElement.insertBefore(chatCard, taskCard);
      taskCard.classList.add("delegation-column-card");
      logInfo("Matilda Chat repositioned above Task Delegation.");
    }
  }

  // --- Fix Critical Ops height ---
  function fixCriticalOpsSize() {
    var panel =
      document.getElementById("critical-ops-alerts") ||
      document.getElementById("critical-ops-panel");
    if (!panel) return;
    panel.style.maxHeight = "260px";
    panel.style.minHeight = "260px";
    panel.style.overflowY = "auto";
  }

  // --- Project Visual Output card below Atlas Subsystem Status ---
  function ensureProjectOutputCard() {
    if (document.getElementById("project-visual-output-card")) return;

    var headings = Array.prototype.slice.call(
      document.querySelectorAll("h2, h3")
    );
    var atlasHeader = headings.find(function (h) {
      return h.textContent.trim().indexOf("Atlas Subsystem Status") === 0;
    });
    if (!atlasHeader) return;

    var atlasCard =
      atlasHeader.closest(
        ".card, .panel, .dashboard-section, section, .tile"
      ) || atlasHeader.parentElement;
    if (!atlasCard || !atlasCard.parentElement) return;

    atlasCard.classList.add("delegation-column-card");

    var outputCard = document.createElement("section");
    outputCard.id = "project-visual-output-card";
    outputCard.className = "dashboard-section card";

    outputCard.innerHTML =
      '<h2>Project Visual Output</h2>' +
      '<div id="project-visual-output" style="min-height: 220px; display: flex; align-items: center; justify-content: center; opacity: 0.8;">' +
      '  <span>No active project output yet. When a build or demo is running, this space can display diagrams, previews, or other visual artifacts.</span>' +
      "</div>";

    if (atlasCard.nextSibling) {
      atlasCard.parentElement.insertBefore(outputCard, atlasCard.nextSibling);
    } else {
      atlasCard.parentElement.appendChild(outputCard);
    }

    logInfo("Project Visual Output card inserted below Atlas Subsystem Status.");
  }

  // --- Chart helpers for Task Activity Over Time ---
  function loadChartJs() {
    if (window.Chart) return Promise.resolve();
    return new Promise(function (resolve, reject) {
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
    if (!container || !window.Chart) return;

    var canvas =
      container.querySelector("#task-activity-chart") ||
      (function () {
        var c = document.createElement("canvas");
        c.id = "task-activity-chart";
        container.appendChild(c);
        return c;
      })();

    var ctx = canvas.getContext("2d");
    new window.Chart(ctx, {
      type: "line",
      data: {
        labels: ["0m", "5m", "10m", "15m", "20m", "25m", "30m"],
        datasets: [
          {
            label: "Tasks Completed",
            data: [3, 7, 5, 9, 6, 10, 8],
            tension: 0.35,
            borderWidth: 2,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
      },
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    logInfo("matilda-chat-console.js loaded");

    ensureMatildaChatStyles();
    ensureMatildaChatConsole();
    wireChatControls();
    repositionMatildaChatCard();
    fixCriticalOpsSize();
    ensureProjectOutputCard();

    loadChartJs()
      .then(function () {
        createTaskActivityChart();
      })
      .catch(function () {
        // Chart is optional – ignore failures
      });
  });
})();
