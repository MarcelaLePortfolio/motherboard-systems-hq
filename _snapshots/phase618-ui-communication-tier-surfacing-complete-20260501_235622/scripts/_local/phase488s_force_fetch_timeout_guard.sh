#!/bin/bash
set -euo pipefail

FILE="public/js/matilda-chat-console.js"

echo "=== APPLY FETCH TIMEOUT GUARD (5s) ==="

cat > "$FILE" << 'JS'
(function () {
  function log(msg) {
    console.log("[matilda-chat]", msg);
  }

  function appendMessage(transcriptEl, sender, text) {
    if (!transcriptEl) return;
    var line = document.createElement("p");
    line.className = "mb-1 text-sm";
    var label = sender ? sender + ": " : "";
    line.textContent = label + text;
    transcriptEl.appendChild(line);
    transcriptEl.scrollTop = transcriptEl.scrollHeight;
  }

  function setSendingState(sendBtn, input, isSending) {
    if (sendBtn) {
      sendBtn.disabled = isSending;
      sendBtn.classList.toggle("opacity-60", isSending);
      sendBtn.textContent = isSending ? "Sending..." : "Send";
    }
    if (input) {
      input.disabled = isSending;
    }
  }

  async function fetchWithTimeout(url, options, timeoutMs) {
    const controller = new AbortController();
    const id = setTimeout(() => controller.abort(), timeoutMs);

    try {
      console.log("[PHASE488_TIMEOUT] starting fetch", url);
      const res = await fetch(url, { ...options, signal: controller.signal });
      console.log("[PHASE488_TIMEOUT] fetch resolved", res.status);
      return res;
    } catch (err) {
      console.error("[PHASE488_TIMEOUT] fetch error", err);
      throw err;
    } finally {
      clearTimeout(id);
    }
  }

  async function wireChat() {
    var root = document.getElementById("matilda-chat-root");
    if (!root) return;

    var transcript = document.getElementById("matilda-chat-transcript");
    var input = document.getElementById("matilda-chat-input");
    var sendBtn = document.getElementById("matilda-chat-send");

    if (!transcript || !input || !sendBtn) return;

    async function handleSend() {
      console.log("[PHASE488_TRACE] handleSend invoked");

      var message = (input.value || "").trim();
      if (!message) return;

      appendMessage(transcript, "You", message);
      input.value = "";
      setSendingState(sendBtn, input, true);

      try {
        const res = await fetchWithTimeout("/api/chat", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ message: message, agent: "matilda" }),
        }, 5000);

        const data = await res.json();
        console.log("[PHASE488_TRACE] parsed json", data);

        var reply =
          (data && (data.reply || data.message || data.response)) ||
          "(no reply)";

        appendMessage(transcript, "Matilda", reply);
      } catch (err) {
        appendMessage(transcript, "Matilda", "(timeout or network failure)");
      } finally {
        setSendingState(sendBtn, input, false);
      }
    }

    sendBtn.addEventListener("click", handleSend);

    var quickBtn = document.getElementById("matilda-chat-quick-check");
    if (quickBtn) {
      quickBtn.addEventListener("click", function () {
        input.value = "Quick systems check from dashboard.";
        handleSend();
      });
    }

    input.addEventListener("keydown", function (e) {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        handleSend();
      }
    });

    log("Matilda chat wiring complete.");
  }

  document.addEventListener("DOMContentLoaded", wireChat);
})();
JS

docker compose build dashboard
docker compose up -d dashboard
sleep 3

open -na "Google Chrome" --args --auto-open-devtools-for-tabs http://localhost:8080/

git add public/js/matilda-chat-console.js
git commit -m "Add fetch timeout guard to confirm frontend hang due to stalled request"
git push
