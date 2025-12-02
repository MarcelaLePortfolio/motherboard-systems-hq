// Matilda Chat Console – Phase 2 Layout + UX Upgrade
// - Repositions Matilda Chat above Task Delegation
// - Matches Task Delegation styling elements
// - Fixes Critical Ops Alerts height
// - Recreates Task Activity Over Time chart

(function () {
  function logInfo(msg) {
    console.log("[MatildaChat]", msg);
  }

  async function sendChatMessage() {
    const input = document.getElementById("matilda-chat-input");
    const sendBtn = document.getElementById("matilda-chat-send");
    const logEl = document.getElementById("matilda-chat-log");

    if (!input || !sendBtn || !logEl) {
      return;
    }

    const text = input.value.trim();
    if (!text) return;

    // Append user message
    appendMessage(logEl, text, "user");

    input.value = "";
    input.focus();

    // Show typing indicator
    const typingId = appendMessage(logEl, "Matilda is thinking…", "matilda", true);

    sendBtn.disabled = true;

    try {
      const res = await fetch("/api/chat", {
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

      const data = await res.json();
      const reply = (data && data.reply) || "(no reply)";

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

  let messageCounter = 0;

  function appendMessage(logEl, text, role, isEphemeral) {
    const msg = document.createElement("div");
    const id = "matilda-msg-" + messageCounter++;
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
    const el = logEl.querySelector('[data-msg-id="' + id + '"]');
    if (el && el.parentElement) {
      el.parentElement.removeChild(el);
    }
  }

  function wireChatControls() {
    const input = document.getElementById("matilda-chat-input");
    const sendBtn = document.getElementById("matilda-chat-send");
    const logEl = document.getElementById("matilda-chat-log");

    if (!input || !sendBtn || !logEl) {
      logInfo("Chat elements not found; skipping chat wiring.");
      return;
    }

    logInfo("init() running – wiring chat controls.");

    sendBtn.addEventListener("click", (e) => {
      e.preventDefault();
      sendChatMessage();
    });

    input.addEventListener("keydown", (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        sendChatMessage();
      }
    });
  }

  // --- Layout: move Matilda Chat above Task Delegation ---
  function repositionMatildaChatCard() {
    const headings = Array.from(document.querySelectorAll("h2, h3"));

    const chatHeader = headings.find((h) =>
      h.textContent.trim().startsWith("Matilda Chat Console")
    );
    const taskHeader = headings.find((h) =>
      h.textContent.trim().startsWith("Task Delegation")
    );

    if (!chatHeader || !taskHeader) {
      logInfo("Could not find chat or task delegation headers; skipping reposition.");
      return;
    }

    const chatCard =
      chatHeader.closest(".card, .panel, .dashboard-section, section, .tile") ||
      chatHeader.parentElement;
    const taskCard =
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
    const panel =
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
    if (window.Chart) return Promise.resolve();

    return new Promise(function (resolve, reject) {
      const script = document.createElement("script");
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
    const container =
      document.getElementById("task-activity-over-time") ||
      document.getElementById("task-activity-card");

    if (!container) {
      logInfo("Task Activity Over Time container not found; skipping chart.");
      return;
    }

    let canvas = container.querySelector("#task-activity-chart");
    if (!canvas) {
      canvas = document.createElement("canvas");
      canvas.id = "task-activity-chart";
      container.appendChild(canvas);
    }

    const ctx = canvas.getContext("2d");

    // Example placeholder data – can be wired to real metrics later
    const labels = ["0m", "5m", "10m", "15m", "20m", "25m", "30m"];
    const data = [3, 7, 5, 9, 6, 10, 8];

    new window.Chart(ctx, {
      type: "line",
      data: {
        labels,
        datasets: [
          {
            label: "Tasks Completed",
            data,
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

    wireChatControls();
    repositionMatildaChatCard();
    fixCriticalOpsPanelSize();

    loadChartJs()
      .then(createTaskActivityChart)
      .catch(function () {
        // Chart is optional – failure shouldn't break dashboard
      });
  });
})();
