// Phase 9.1 — Guaranteed anchor: waits for dashboard to fully render
window.addEventListener("DOMContentLoaded", () => {
  setTimeout(() => {
    const tryAnchor = () => {
      // Locate the exact Recent Logs container dynamically
      const section = document.querySelector("#recent-logs, .recent-logs");
      const target =
        section?.querySelector(".section-content") ||
        section?.querySelector("div") ||
        section;

      if (!target) {
        console.warn("🕒 Waiting for Recent Logs container...");
        return setTimeout(tryAnchor, 500);
      }

      console.log("✅ Reflections anchored to:", target);

      const src = new EventSource("http://localhost:3101/events/reflections");
      let lastId = null;

      src.onmessage = (e) => {
        try {
          const data = JSON.parse(e.data);
          if (!data.id || data.id === lastId) return;
          lastId = data.id;

          const line = document.createElement("div");
          line.className = "reflection-line";
          line.style.cssText =
            "padding:3px 6px;margin:2px 0;border-left:2px solid #10b981;background:#111827;border-radius:4px;color:#e5e7eb;font-family:ui-monospace,monospace;font-size:13px;";
          line.textContent = `[${data.created_at}] ${data.content}`;

          target.prepend(line);
          while (target.children.length > 50)
            target.removeChild(target.lastChild);
        } catch (err) {
          console.error("Parse error:", err);
        }
      };

      src.onerror = () => {
        const note = document.createElement("div");
        note.textContent = "⚠️ Connection lost — retrying …";
        note.style.cssText = "color:#fca5a5;";
        target.prepend(note);
      };
    };

    tryAnchor();
  }, 1500); // wait a bit longer for dashboard HTML to render
});
