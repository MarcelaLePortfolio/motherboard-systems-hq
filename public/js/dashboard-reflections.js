// Live reflection viewer — now anchored inside the "Recent Logs" panel
(async function reflectionsStream(){
  // Find "Recent Logs" heading or section
  const logsPanel = Array.from(document.querySelectorAll("summary,div,section"))
    .find(el => /Recent Logs/i.test(el.textContent || ""));
  const container = logsPanel?.parentElement || document.body;

  const logBox = document.getElementById("reflections-log") || (() => {
    const box = document.createElement("div");
    box.id = "reflections-log";
    box.className = "reflection-log";
    box.style.cssText = `
      margin-top:6px;
      padding:8px;
      background:#0b0b0b;
      border-radius:8px;
      border:1px solid #3a3a3a;
      color:#e8e0d1;
      font-family:ui-monospace,monospace;
      max-height:25vh;
      overflow-y:auto;
      font-size:0.85rem;
    `;
    if (logsPanel && logsPanel.parentNode) {
      logsPanel.parentNode.insertBefore(box, logsPanel.nextSibling);
    } else {
      container.appendChild(box);
    }
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
      line.textContent = `[${data.created_at}] ${data.content}`;
      logBox.prepend(line);
      while (logBox.children.length > 50) logBox.removeChild(logBox.lastChild);
    } catch (err) {
      console.error("Parse error:", err);
    }
  };

  src.onerror = (e) => {
    console.error("Reflections SSE error:", e);
    const note = document.createElement("div");
    note.textContent = "⚠️ Connection lost. Retrying…";
    note.style.color = "#ffb4a9";
    logBox.prepend(note);
  };
})();
