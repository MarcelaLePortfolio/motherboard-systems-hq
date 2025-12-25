(function () {
  const el = document.getElementById("project-visual-output");
  if (!el) return;

  function clear() {
    while (el.firstChild) el.removeChild(el.firstChild);
  }

  function renderJSON(obj) {
    const pre = document.createElement("pre");
    pre.className = "text-xs whitespace-pre-wrap break-words";
    pre.textContent = JSON.stringify(obj, null, 2);
    el.appendChild(pre);
  }

  function renderLog(msg) {
    const div = document.createElement("div");
    div.className = "text-xs whitespace-pre-wrap break-words";
    div.textContent = msg || "";
    el.appendChild(div);
  }

  function renderArtifact(a) {
    clear();

    const header = document.createElement("div");
    header.className = "text-xs opacity-70 mb-2";
    header.textContent =
      `${a.type} · ${a.source}` +
      (a.taskId ? ` · task ${a.taskId}` : "") +
      (a.timestamp ? ` · ${a.timestamp}` : "");
    el.appendChild(header);

    if (a.type === "log") {
      const p = a.payload || {};
      renderLog(p.message || p.text || p.log || "");
      return;
    }

    renderJSON(a);
  }

  const es = new EventSource("/events/artifacts");
  es.onmessage = (e) => {
    try { renderArtifact(JSON.parse(e.data)); } catch {}
  };
  es.onerror = () => {};
})();
