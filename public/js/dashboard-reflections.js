// Phase 9.1 — Nested Reflections Stream → precise anchor inside Recent Logs content
(async function reflectionsStream(){
  // Find correct Recent Logs section content div
  const target =
    document.querySelector("#recent-logs .section-content") ||
    document.querySelector("#recent-logs") ||
    document.querySelector(".recent-logs .section-content") ||
    (() => {
      const box = document.createElement("div");
      box.id = "recent-logs";
      box.className = "reflection-log";
      document.body.appendChild(box);
      return box;
    })();

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
        "padding:2px 6px;margin:2px 0;border-left:2px solid #10b981;background:#0f172a;border-radius:4px;color:#f3f4f6;font-family:ui-monospace,monospace;font-size:13px;";
      line.textContent = `[${data.created_at}] ${data.content}`;

      target.prepend(line);
      while (target.children.length > 50) target.removeChild(target.lastChild);
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
