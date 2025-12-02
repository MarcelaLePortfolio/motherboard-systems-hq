// Matilda Chat Console – Phase 2 Layout + UX Upgrade
// - Repositions Matilda Chat above Task Delegation
// - Matches Task Delegation styling elements
// - Fixes Critical Ops Alerts height
// - Recreates Task Activity Over Time chart
// - Ensures matilda-chat.css is loaded from JS

(function () {
  function logInfo(msg) {
    console.log("[MatildaChat]", msg);
  }

  // --- Ensure Matilda Chat stylesheet is loaded even if HTML wasn't wired yet ---
  function ensureMatildaChatStyles() {
    var existing = document.querySelector('link[href="/css/matilda-chat.css"]');
    if (existing) {
      return;
    }
    var link = document.createElement("link");
    link.rel = "stylesheet";
    link.href = "/css/matilda-chat.css";
    document.head.appendChild(link);
    logInfo("Injected /css/matilda-chat.css stylesheet into <head>.");
  }

  async function sendChatMessage() {
    var input = document.getElementById("matilda-chat-input");
    var sendBtn = document.getElementById("matilda-chat-send");
    var logEl = document.getElementById("matilda-chat-log");

    if (!input || !sendBtn || !logEl) {
      return;
    }

    var text = input.value.trim();
    if (!text) return;

    // Append user message
    appendMessage(logEl, text, "user");

    input.value = "";
    input.focus();

    // Show typing indicator
    var typingId = appendMessage(logEl, "Matilda is thinking…", "matilda", true);

    sendBtn.disabled = true;

    try {
      var res = await fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          message: text,
          agent: "matilda",
        }),
      });

      if (!res.ok) {
        throw new Error("Non-200 response");
      }

      var data = await res.json();
      var reply = (data && data.reply) || "(no reply)";

      removeMessageById(logEl, typingId);
      appendMessage(logEl, reply, "matilda");
    } catch (err) {
      console.error("[MatildaChat] Error sending message:", err);
      removeMessageById(logEl, typingId);
      appendMessage(
        logEl,
        "Matilda hit a snag reaching the backend. Please try again in a moment.",
        "matilda"
      );
    } finally {
      sendBtn.disabled = false;
    }
  }

  var messageCounter = 0;

  function appendMessage(logEl, text, role, isEphemeral) {
    var msg = document.createElement("div");
    var id = "matilda-msg-" + messageCounter++;
    msg.dataset.msgId = id;

    msg.classList.add(role === "user" ? "user-msg" : "matilda-msg");
    msg.textContent = text;

    logEl.appendChild(msg);
    logEl.scrollTop = logEl.scrollHeight;

    if (isEphemeral) {
      msg.classList.add("ephemeral-msg");
    }

    return id;
  }

  function removeMessageById(logEl, id) {
    if (!id) return;
    var el = logEl.querySelector('[data-msg-id="' + id + '"]');
    if (el && el.parentElement) {
      el.parentElement.removeChild(el);
    }
  }

  function wireChatControls() {
    var input = document.getElementById("matilda-chat-input");
    var sendBtn = document.getElementById("matilda-chat-send");
    var logEl = document.getElementById("matilda-chat-log");

    if (!input || !sendBtn || !logEl) {
      logInfo("Chat elements not found; skipping chat wiring.");
      return;
    }

    logInfo("init() running – wiring chat controls.");

    sendBtn.addEventListener("click", function (e) {
      e.preventDefault();
      sendChatMessage();
    });

    input.addEventListener("keydown", function (e) {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        sendChatMessage();
      }
    });
  }

  // --- Layout: move Matilda Chat above Task Delegation ---
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

    if (!chatHeader || !taskHeader) {
      logInfo("Could not find chat or task delegation headers; skipping reposition.");
      return;
    }

    var chatCard =
      chatHeader.closest(".card, .panel, .dashboard-section, section, .tile") ||
      chatHeader.parentElement;
    var taskCard =
      taskHeader.closest(".card, .panel, .dashboard-section, section, .tile") ||
      taskHeader.parentElement;

    if (!chatCard || !taskCard || !taskCard.parentElement) {
      logInfo("Card containers not found; skipping reposition.");
      return;
    }

    if (chatCard === taskCard) return;

    // Insert chat card just before Task Delegation card
    taskCard.parentElement.insertBefore(chatCard, taskCard);
    logInfo("Matilda Chat card moved above Task Delegation.");
  }

  // --- Fixed size for Critical Ops Alerts ---
  function fixCriticalOpsPanelSize() {
    var panel =
      document.getElementById("critical-ops-alerts") ||
      document.getElementById("critical-ops-panel");
    if (!panel) {
      logInfo("Critical Ops Alerts panel not found; skipping size fix.");
      return;
    }

    panel.style.maxHeight = "260px";
    panel.style.minHeight = "260px";
    panel.style.overflowY = "auto";
    logInfo("Critical Ops Alerts panel height constrained to 260px.");
  }

  // --- Task Activity Over Time Chart ---
  function loadChartJs() {
    if (typeof window !== "undefined" && window.Chart) {
      return Promise.resolve();
    }

    return new Promise(function (resolve, reject) {
      var script = document.createElement("script");
      script.src = "https://cdn.jsdelivr.net/npm/chart.js";
      script.async = true;
      script.onload = function () {
        resolve();
      };
      script.onerror = function (err) {
        console.error("[MatildaChat] Failed to load Chart.js", err);
        reject(err);
      };
      document.head.appendChild(script);
    });
  }

  function createTaskActivityChart() {
    var container =
      document.getElementById("task-activity-over-time") ||
      document.getElementById("task-activity-card");

    if (!container) {
      logInfo("Task Activity Over Time container not found; skipping chart.");
      return;
    }

    var canvas = container.querySelector("#task-activity-chart");
    if (!canvas) {
      canvas = document.createElement("canvas");
      canvas.id = "task-activity-chart";
      container.appendChild(canvas);
    }

    var ctx = canvas.getContext("2d");

    // Example placeholder data – can be wired to real metrics later
    var labels = ["0m", "5m", "10m", "15m", "20m", "25m", "30m"];
    var data = [3, 7, 5, 9, 6, 10, 8];

    if (!window.Chart) {
      logInfo("Chart.js not available; skipping Task Activity chart.");
      return;
    }

    new window.Chart(ctx, {
      type: "line",
      data: {
        labels: labels,
        datasets: [
          {
            label: "Tasks Completed",
            data: data,
            tension: 0.35,
            borderWidth: 2,
            pointRadius: 3,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            labels: {
              color: "#e5e7eb",
            },
          },
        },
        scales: {
          x: {
            ticks: { color: "#9ca3af" },
            grid: { color: "rgba(55,65,81,0.4)" },
          },
          y: {
            ticks: { color: "#9ca3af" },
            grid: { color: "rgba(55,65,81,0.4)" },
          },
        },
      },
    });

    container.style.minHeight = "260px";
    canvas.style.height = "220px";
    logInfo("Task Activity Over Time chart rendered.");
  }

  document.addEventListener("DOMContentLoaded", function () {
    logInfo("matilda-chat-console.js loaded");

    ensureMatildaChatStyles();
    wireChatControls();
    repositionMatildaChatCard();
    fixCriticalOpsPanelSize();

    loadChartJs()
      .then(function () {
        createTaskActivityChart();
      })
      .catch(function () {
        // Chart is optional – failure shouldn't break dashboard
      });
  });
})();
