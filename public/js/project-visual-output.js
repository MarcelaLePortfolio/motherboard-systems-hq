(function () {
  // Prefer a dedicated content node if present; otherwise render into the card itself.
  const card = document.getElementById("project-visual-output-card");
const el = document.getElementById("project-visual-output");
  if (!el) return;

  
  try {
    el.dataset.pvoLoaded = "1";
    el.style.outline = "2px solid rgba(129,140,248,0.6)";
    const stamp = document.createElement("div");
    stamp.className = "text-xs opacity-80 mb-2";
    stamp.textContent = "PVO TARGET = " + (el.className || "(no class)") + " @ " + new Date().toISOString();
    el.prepend(stamp);

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

  if (a && a.type === "visual") {
    const p = a.payload || {};
    if (p.kind === "html" && typeof p.content === "string") {
      const wrap = document.createElement("div");
      wrap.className = "text-sm";
      wrap.innerHTML = p.content;
      el.appendChild(wrap);
      return;
    }
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
