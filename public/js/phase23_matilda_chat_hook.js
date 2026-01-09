/**
 * Phase 23: Matilda Delegation Loop
 * Stable hook for appending system/status lines into Matilda chat stream.
 *
 * - Other modules call: window.__MATILDA_CHAT_APPEND_SYSTEM("...line...")
 * - We also emit: window event "matilda.appendSystem"
 */
(function () {
  if (window.__PHASE23_MATILDA_CHAT_HOOK_STARTED) return;
  window.__PHASE23_MATILDA_CHAT_HOOK_STARTED = true;

  function emit(line) {
    try {
      window.dispatchEvent(
        new CustomEvent("matilda.appendSystem", { detail: { line: String(line), ts: Date.now() } })
      );
    } catch (_) {}
  }

  window.__MATILDA_CHAT_APPEND_SYSTEM =
      window.__MATILDA_CHAT_APPEND_SYSTEM ||
      function (line) {
        const s = String(line);

        // 1) Preferred: explicit append API (if present)
        try {
          if (typeof window.appendMessage === "function") return window.appendMessage({ role: "system", content: s });
          if (typeof window.__appendMessage === "function") return window.__appendMessage({ role: "system", content: s });
          if (typeof window.__appendMessage === "function") return window.__appendMessage({ role: "system", content: s });
        } catch (_) {}

        // 2) Fallback: append directly to the Matilda transcript DOM
        try {
          const transcript = document.getElementById("matilda-chat-transcript");
          if (transcript) {
            const lineEl = document.createElement("p");
            lineEl.className = "mb-1 text-sm";
            lineEl.textContent = "System: " + s;
            transcript.appendChild(lineEl);
            transcript.scrollTop = transcript.scrollHeight;
            return;
          }
        } catch (_) {}

        // 3) Last resort: event-only (useful for debugging)
        emit(s);
      };
  })();
