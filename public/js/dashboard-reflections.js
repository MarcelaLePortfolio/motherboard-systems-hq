// Phase 9.1 — Precision Anchor: auto-detect correct container inside Recent Logs
(async function reflectionsStream(){
  // Locate the main Recent Logs block
  const section = document.querySelector("#recent-logs, .recent-logs, h3:contains('Recent Logs')") || document.body;

  // Try to find a nested content div, table, or list under that section
  let target = section.querySelector(".section-content, .content, ul, ol, div");
  if (!target) {
    target = document.createElement("div");
    target.className = "section-content";
    target.style.cssText = "padding:6px 8px;";
    section.appendChild(target);
  }

  // Debug marker for quick visibility (auto-removes after first log)
  const marker = document.createElement("div");
  marker.textContent = "📍 [Reflection stream anchored here]";
  marker.style.cssText = "color:#6ee7b7;font-size:12px;margin-bottom:4px;";
  target.appendChild(marker);

  const src = new EventSource("http://localhost:3101/events/reflections");
  let lastId = null;
  let initialized = false;

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
      while (target.children.length > 50) target.removeChild(target.lastChild);

      if (!initialized) {
        initialized = true;
        setTimeout(() => marker.remove(), 1000);
      }
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
})();
