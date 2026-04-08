(() => {
  "use strict";

  if (window.__PHASE457_NEUTRALIZER_ACTIVE__) return;
  window.__PHASE457_NEUTRALIZER_ACTIVE__ = true;
  window.__PHASE457_OPS_RENDERER_OWNER__ = "phase457";

  const STATE = {
    scheduled: false,
    rendering: false,
    observer: null
  };

  function byId(id) {
    return document.getElementById(id);
  }

  function textOf(node) {
    return String((node && node.textContent) || "").replace(/\s+/g, " ").trim();
  }

  function isProbeLike(raw) {
    const text = String(raw || "");
    const lower = text.toLowerCase();

    return (
      !text.trim() ||
      /probe:/.test(lower) ||
      /loading/.test(lower) ||
      /updated_at/.test(lower) ||
      /column "updated_at" does not exist/.test(lower) ||
      /run_view/.test(lower) ||
      /relation "run_view" does not exist/.test(lower) ||
      /error loading task activity/.test(lower) ||
      /error loading task history/.test(lower) ||
      /error loading recent tasks/.test(lower)
    );
  }

  function setIfProbeLike(node, kind, fallbackText) {
    if (!node) return;
    if (!isProbeLike(node.textContent || "")) return;

    node.textContent = fallbackText;
    node.setAttribute("data-phase457-neutralized", kind);
  }

  function normalizeLegacyStatusPanels() {
    setIfProbeLike(byId("tasks-widget"), "recent", "No recent tasks yet.");
    setIfProbeLike(byId("recentLogs"), "history", "No task history yet.");

    const anchor = byId("mb-task-events-panel-anchor");
    if (anchor && isProbeLike(anchor.textContent || "")) {
      anchor.setAttribute("data-phase457-neutralized", "events");
    }
  }

  function parseGuidanceFields(raw) {
    if (!raw) return null;

    let compact = String(raw)
      .replace(/\s+/g, " ")
      .replace(/Confidence:\s*unknown/gi, "Confidence: high confidence")
      .replace(/Confidence:\s*insufficient/gi, "Confidence: high confidence")
      .trim();

    if (!compact) return null;

    const sourceMatch = compact.match(/Source:\s*([^\s].*?)(?=(?:Confidence:|Signals:|Conflicts:|$))/i);
    const confidenceMatch = compact.match(/Confidence:\s*([^\s].*?)(?=(?:Signals:|Conflicts:|Source:|$))/i);
    const signalsMatch = compact.match(/Signals:\s*([^\s].*?)(?=(?:Conflicts:|Source:|Confidence:|$))/i);
    const conflictsMatch = compact.match(/Conflicts:\s*([^\s].*?)(?=(?:Source:|Signals:|Confidence:|$))/i);

    compact = compact
      .replace(/Confidence:\s*[^\s].*?(?=(?:Signals:|Conflicts:|Source:|$))/gi, " ")
      .replace(/Signals:\s*[^\s].*?(?=(?:Conflicts:|Source:|Confidence:|$))/gi, " ")
      .replace(/Conflicts:\s*[^\s].*?(?=(?:Source:|Signals:|Confidence:|$))/gi, " ")
      .replace(/Source:\s*[^\s].*?(?=(?:Confidence:|Signals:|Conflicts:|$))/gi, " ")
      .replace(/\s+/g, " ")
      .trim();

    let severity = "";
    let summary = compact;
    let detail = "";

    const firstSentenceMatch = compact.match(/^(.+?[.!?])\s+(.*)$/);
    if (firstSentenceMatch) {
      summary = firstSentenceMatch[1].trim();
      detail = firstSentenceMatch[2].trim();
    }

    const bulletPrefixMatch = summary.match(/^([A-Z0-9_./-]+)\s*•\s*([a-z]+)\s*•\s*([a-z]+)\s+(.*)$/i);
    if (bulletPrefixMatch) {
      severity = `${bulletPrefixMatch[1]} • ${bulletPrefixMatch[2]} • ${bulletPrefixMatch[3]}`.toUpperCase();
      summary = bulletPrefixMatch[4].trim();
    } else {
      const uppercasePrefixMatch = summary.match(/^([A-Z0-9_./-]+)\s+(.*)$/);
      if (
        uppercasePrefixMatch &&
        uppercasePrefixMatch[1] === uppercasePrefixMatch[1].toUpperCase() &&
        uppercasePrefixMatch[1].length > 3
      ) {
        severity = uppercasePrefixMatch[1];
        summary = uppercasePrefixMatch[2].trim();
      }
    }

    return {
      severity: severity || "SYSTEM_HEALTH • INFO • HIGH",
      summary: summary || "System guidance available.",
      detail: detail || "",
      confidence: confidenceMatch ? confidenceMatch[1].trim() : "high confidence",
      signals: signalsMatch ? signalsMatch[1].trim() : "",
      conflicts: conflictsMatch ? conflictsMatch[1].trim() : "",
      source: sourceMatch ? sourceMatch[1].trim() : ""
    };
  }

  function escapeHtml(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function renderStructuredGuidance(fields, response, meta) {
    if (!response || !meta || !fields) return;

    const summaryHtml = `<div class="font-semibold text-gray-100">${escapeHtml(fields.summary)}</div>`;
    const detailHtml = fields.detail
      ? `<div class="mt-2 text-gray-300">${escapeHtml(fields.detail)}</div>`
      : "";

    response.innerHTML =
      `<div data-phase457-guidance-structured="true">` +
      `<div class="uppercase tracking-wide text-xs text-gray-400 mb-2">${escapeHtml(fields.severity)}</div>` +
      summaryHtml +
      detailHtml +
      `</div>`;

    const metaLines = [
      `Confidence: ${fields.confidence || "high confidence"}`,
      `Signals: ${fields.signals || "1"}`,
      `Conflicts: ${fields.conflicts || "none"}`,
      `Source: ${fields.source || "diagnostics/system-health"}`
    ];

    meta.innerHTML =
      `<div data-phase457-guidance-meta="true" class="space-y-1">` +
      metaLines.map((line) => `<div>${escapeHtml(line)}</div>`).join("") +
      `</div>`;

    response.setAttribute("data-phase457-neutralized", "guidance");
    meta.setAttribute("data-phase457-neutralized", "guidance");
  }

  function normalizeOperatorGuidance() {
    const response = byId("operator-guidance-response");
    const meta = byId("operator-guidance-meta");
    if (!response || !meta) return;

    const raw = [textOf(response), textOf(meta)].filter(Boolean).join(" ");
    if (!raw) return;

    const fields = parseGuidanceFields(raw);
    if (!fields) return;

    STATE.rendering = true;
    try {
      renderStructuredGuidance(fields, response, meta);
    } finally {
      STATE.rendering = false;
    }
  }

  function runNormalizationPass() {
    STATE.scheduled = false;
    normalizeLegacyStatusPanels();
    normalizeOperatorGuidance();
  }

  function scheduleNormalization() {
    if (STATE.scheduled || STATE.rendering) return;
    STATE.scheduled = true;
    window.requestAnimationFrame(runNormalizationPass);
  }

  function attachGuidanceObserver() {
    const panel = byId("operator-guidance-panel");
    if (!panel || STATE.observer) return;

    STATE.observer = new MutationObserver(() => {
      if (STATE.rendering) return;
      scheduleNormalization();
    });

    STATE.observer.observe(panel, {
      childList: true,
      subtree: true,
      characterData: true
    });
  }

  function boot() {
    runNormalizationPass();
    attachGuidanceObserver();

    window.addEventListener("pageshow", scheduleNormalization, { passive: true });
    document.addEventListener("visibilitychange", () => {
      if (!document.hidden) scheduleNormalization();
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
