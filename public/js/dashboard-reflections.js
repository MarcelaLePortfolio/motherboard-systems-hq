// Anchored Reflection Stream → Chat Log container
document.addEventListener("DOMContentLoaded", () => {
  console.log("📡 Anchored reflections → #recentLogs");

  const waitForTarget = () => {
    const target = document.querySelector("#recentLogs");
    if (!target) {
      console.log("🕒 Waiting for #recentLogs...");
      return setTimeout(waitForTarget, 1000);
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
          "padding:4px 8px;margin:2px 0;border-left:2px solid #10b981;background:#0b0b0b;border-radius:6px;color:#e5e7eb;font-family:ui-monospace,monospace;font-size:13px;";
        line.textContent = `[${data.created_at}] ${data.content}`;
        target.prepend(line);
        while (target.children.length > 50) target.removeChild(target.lastChild);
      } catch (err) {
        console.error("Reflection parse error:", err);
      }
    };

    src.onerror = (e) => {
      console.error("Reflections SSE error:", e);
      const note = document.createElement("div");
      note.textContent = "⚠️ Connection lost — retrying …";
      note.style.color = "#fca5a5";
      target.prepend(note);
    };
  };

  waitForTarget();
});
