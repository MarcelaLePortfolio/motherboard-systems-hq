(function () {
  // Prefer a dedicated content node if present; otherwise render into the card itself.
  const el =
    document.getElementById("project-visual-output") ||
    document.getElementById("project-visual-output-card");

  if (!el) return;

  
  try {
    el.dataset.pvoLoaded = "1";
    const mark = document.createElement("div");
    mark.className = "text-xs opacity-70 mb-2";
    mark.textContent = "PVO subscriber loaded @ " + new Date().toISOString();
    el.prepend(mark);
  } catch {}
function clear() {
    while (el.firstChild) el.removeChild(el.firstChild);
  }

  function headerLine(a) {
    const header = document.createElement("div");
    header.className = "text-xs opacity-70 mb-2";
    header.textContent =
      `${a.type || "artifact"} · ${a.source || "unknown"}` +
      (a.taskId ? ` · task ${a.taskId}` : "") +
      (a.timestamp ? ` · ${a.timestamp}` : "");
    return header;
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
    el.appendChild(headerLine(a));

    if (a && a.type === "log") {
      const p = a.payload || {};
      renderLog(p.message || p.text || p.log || "");
      return;
    }

    renderJSON(a);
  }

  const es = new EventSource("/events/artifacts");
  es.onmessage = (e) => {
    try {
      renderArtifact(JSON.parse(e.data));
    } catch {}
  };
  es.onerror = () => {
    // quiet; SSE auto-reconnects
  };
})();
