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

  async function wireChat() {
    var root = document.getElementById("matilda-chat-root");
    if (!root) {
      log("No #matilda-chat-root found; skipping wiring.");
      return;
    }

    var transcript = document.getElementById("matilda-chat-transcript");
    var input = document.getElementById("matilda-chat-input");
    var sendBtn = document.getElementById("matilda-chat-send");

      // Phase23: expose append API for other modules (task-events bridge, ops, etc.)
      // Usage:
      //   window.appendMessage({role:"system"|"user"|"matilda", content:"..."})
      //   window.__appendMessage({role:"system", content:"..."})   (alias)
      window.appendMessage = window.appendMessage || function (msg) {
        try {
          var role = (msg && msg.role) ? String(msg.role) : "system";
          var content = (msg && (msg.content ?? msg.text ?? msg.message)) ? String(msg.content ?? msg.text ?? msg.message) : "";
          var sender = role === "user" ? "You" : (role === "matilda" ? "Matilda" : "System");
          appendMessage(transcript, sender, content);
        } catch (_) {}
      };
      window.__appendMessage = window.__appendMessage || window.appendMessage;

    if (!transcript || !input || !sendBtn) {
      log("Missing one or more Matilda chat elements; aborting wiring.");
      return;
    }

    function safeTrim(value) {
      return (value || "").toString().trim();
    }

    async function handleSend() {
      var message = safeTrim(input.value);
      if (!message) return;

      appendMessage(transcript, "You", message);
      input.value = "";
      setSendingState(sendBtn, input, true);

      try {
        var res = await fetch("/api/chat", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ message: message, agent: "matilda" }),
        });

        if (!res.ok) {
          appendMessage(
            transcript,
            "Matilda",
            "(error talking to /api/chat)"
          );
          return;
        }

        var data = await res.json();
        var reply =
          (data && (data.reply || data.message || data.response)) ||
          "(no reply)";
        appendMessage(transcript, "Matilda", reply);
      } catch (err) {
        console.error(err);
        appendMessage(transcript, "Matilda", "(network error)");
      } finally {
        setSendingState(sendBtn, input, false);
      }
    }

    sendBtn.addEventListener("click", handleSend);

    var quickBtn = document.getElementById("matilda-chat-quick-check");
    if (quickBtn) {
      quickBtn.addEventListener("click", function () {
        input.value = "Quick systems check from dashboard Phase 11.4.";
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
