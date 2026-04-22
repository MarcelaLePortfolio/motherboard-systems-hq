(function () {
  let inFlight = false;

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
      sendBtn.textContent = isSending ? "Sending..." : "Send";
    }
    if (input) input.disabled = isSending;
  }

  async function fetchWithTimeout(url, options, timeoutMs) {
    const controller = new AbortController();
    const id = setTimeout(() => controller.abort(), timeoutMs);

    try {
      console.log("[PHASE488_TIMEOUT] starting fetch");
      const res = await fetch(url, { ...options, signal: controller.signal });
      console.log("[PHASE488_TIMEOUT] resolved", res.status);
      return res;
    } finally {
      clearTimeout(id);
    }
  }

  async function wireChat() {
    var transcript = document.getElementById("matilda-chat-transcript");
    var input = document.getElementById("matilda-chat-input");
    var sendBtn = document.getElementById("matilda-chat-send");

    if (!transcript || !input || !sendBtn) return;

    async function handleSend() {
      console.log("[PHASE488_TRACE] handleSend invoked");

      if (inFlight) {
        console.warn("[PHASE488_GUARD] blocked duplicate send");
        return;
      }

      var message = (input.value || "").trim();
      if (!message) return;

      inFlight = true;

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

        const reply =
          (data && (data.reply || data.message || data.response)) ||
          "(no reply)";

        appendMessage(transcript, "Matilda", reply);
      } catch (err) {
        appendMessage(transcript, "Matilda", "(timeout or network failure)");
      } finally {
        inFlight = false;
        setSendingState(sendBtn, input, false);
      }
    }

    sendBtn.onclick = handleSend;

    var quickBtn = document.getElementById("matilda-chat-quick-check");
    if (quickBtn) {
      quickBtn.onclick = function () {
        input.value = "Quick systems check from dashboard.";
        handleSend();
      };
    }

    input.onkeydown = function (e) {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        handleSend();
      }
    };

    log("Matilda chat wiring complete.");
  }

  document.addEventListener("DOMContentLoaded", wireChat);
})();
