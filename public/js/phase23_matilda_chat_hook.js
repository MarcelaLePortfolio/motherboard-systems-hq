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
      try {
        if (typeof window.appendMessage === "function") return window.appendMessage({ role: "system", content: String(line) });
        if (typeof window.__appendMessage === "function") return window.__appendMessage({ role: "system", content: String(line) });
      } catch (_) {}
      emit(line);
    };
})();
