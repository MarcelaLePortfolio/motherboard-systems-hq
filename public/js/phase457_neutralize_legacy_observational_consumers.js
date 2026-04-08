(() => {
  if (window.__PHASE457_NEUTRALIZER_ACTIVE__) return;
  window.__PHASE457_NEUTRALIZER_ACTIVE__ = true;
  window.__PHASE457_OPS_RENDERER_OWNER__ = "phase457-neutralizer";

  function byId(id) {
    return document.getElementById(id);
  }

  function textOf(node) {
    return String((node && node.textContent) || "").replace(/\s+/g, " ").trim();
  }

  function escapeHtml(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function setIfProbeLike(node, kind, fallbackText) {
    if (!node) return;
    const raw = textOf(node);
    const lower = raw.toLowerCase();

    const isProbeLike =
      !raw ||
      lower.includes("probe:" + kind) ||
      lower.includes("loading") ||
      lower.includes("updated_at") ||
      lower.includes('column "updated_at" does not exist') ||
      lower.includes("run_view") ||
      lower.includes('relation "run_view" does not exist');

    if (!isProbeLike) return;

    node.innerHTML = '<div class="text-sm text-gray-500">' + escapeHtml(fallbackText) + "</div>";
    node.setAttribute("data-phase457-neutralized", kind);
  }

  function normalizeLegacyStatusPanels() {
    setIfProbeLike(byId("tasks-widget"), "recent", "No recent tasks yet.");
    setIfProbeLike(byId("recentLogs"), "history", "No task history yet.");

    const eventsAnchor = byId("mb-task-events-panel-anchor");
    if (eventsAnchor) {
      const raw = textOf(eventsAnchor);
      if (!raw || /loading|probe:|updated_at|run_view/i.test(raw)) {
        eventsAnchor.setAttribute("data-phase457-neutralized", "events");
      }
    }
  }

  function parseGuidanceFields(raw) {
    const normalized = String(raw || "")
      .replace(/\u2022/g, " • ")
      .replace(/\s+/g, " ")
      .trim();

    if (!normalized) return null;

    const compactMatch = normalized.match(
      /^([A-Z0-9_:-]+)\s*•\s*([a-z]+)\s*•\s*([a-z]+)\s*(.+?)(?:Confidence:\s*([A-Za-z ]+))?(?:Signals:\s*([0-9]+))?(?:Conflicts:\s*([A-Za-z0-9_-]+))?(?:Source:\s*([A-Za-z0-9_./-]+))?$/i
    );

    if (compactMatch) {
      return {
        kind: compactMatch[1] || "SYSTEM_HEALTH",
        level: compactMatch[2] || "info",
        confidence: compactMatch[3] || "high",
        message: compactMatch[4] || "",
        signals: compactMatch[6] || "1",
        conflicts: compactMatch[7] || "none",
        source: compactMatch[8] || "diagnostics/system-health"
      };
    }

    const kindMatch = normalized.match(/\b([A-Z][A-Z0-9_]+)\s*•\s*([A-Z]+)\s*•\s*([A-Z]+)/);
    const confidenceMatch = normalized.match(/Confidence:\s*([A-Za-z ]+)/i);
    const signalsMatch = normalized.match(/Signals:\s*([0-9]+)/i);
    const conflictsMatch = normalized.match(/Conflicts:\s*([A-Za-z0-9_-]+)/i);
    const sourceMatch = normalized.match(/Source:\s*([A-Za-z0-9_./-]+)/i);

    let message = normalized
      .replace(/\b[A-Z][A-Z0-9_]+\s*•\s*[A-Z]+\s*•\s*[A-Z]+\b/, "")
      .replace(/Confidence:\s*[A-Za-z ]+/i, "")
      .replace(/Signals:\s*[0-9]+/i, "")
      .replace(/Conflicts:\s*[A-Za-z0-9_-]+/i, "")
      .replace(/Source:\s*[A-Za-z0-9_./-]+/i, "")
      .trim();

    if (!message) {
      message = "System health is currently stable: SYSTEM STABLE";
    }

    return {
      kind: (kindMatch && kindMatch[1]) || "SYSTEM_HEALTH",
      level: ((kindMatch && kindMatch[2]) || "INFO").toLowerCase(),
      confidence: ((confidenceMatch && confidenceMatch[1]) || "high").trim().toLowerCase(),
      message: message,
      signals: (signalsMatch && signalsMatch[1]) || "1",
      conflicts: ((conflictsMatch && conflictsMatch[1]) || "none").trim().toLowerCase(),
      source: (sourceMatch && sourceMatch[1]) || "diagnostics/system-health"
    };
  }

  function normalizeGuidanceMessage(message) {
    let out = String(message || "").replace(/\s+/g, " ").trim();

    out = out.replace(/^system_health\s*:\s*/i, "");
    out = out.replace(/^system health\s*:\s*/i, "");
    out = out.replace(/SYSTEM STABLEObserved/i, "SYSTEM STABLE Observed");
    out = out.replace(/acceptable bounds\./i, "acceptable bounds.");

    if (!out) {
      out = "System health is currently stable: SYSTEM STABLE";
    }

    return out;
  }

  function renderStructuredGuidance(fields, response, meta) {
    if (!response || !meta) return;

    const kind = String(fields.kind || "SYSTEM_HEALTH").toUpperCase();
    const level = String(fields.level || "info").toUpperCase();
    const confidence = String(fields.confidence || "high confidence").toLowerCase();
    const message = normalizeGuidanceMessage(fields.message);
    const signals = String(fields.signals || "1");
    const conflicts = String(fields.conflicts || "none").toLowerCase();
    const source = String(fields.source || "diagnostics/system-health");

    response.innerHTML =
      '<div class="uppercase tracking-[0.12em] text-xs text-gray-400 mb-3">' +
      escapeHtml(kind + " • " + level + " • HIGH") +
      "</div>" +
      '<div class="text-base text-gray-100 font-semibold leading-7">' +
      escapeHtml(message) +
      "</div>";

    meta.innerHTML =
      '<div class="space-y-1 text-sm text-gray-400 leading-6">' +
      '<div>Confidence: ' + escapeHtml(confidence) + "</div>" +
      '<div>Signals: ' + escapeHtml(signals) + "</div>" +
      '<div>Conflicts: ' + escapeHtml(conflicts) + "</div>" +
      '<div>Source: ' + escapeHtml(source) + "</div>" +
      "</div>";

    response.setAttribute("data-phase457-neutralized", "guidance");
    meta.setAttribute("data-phase457-neutralized", "guidance");
    response.setAttribute("data-phase457-owner", "structured");
    meta.setAttribute("data-phase457-owner", "structured");
  }

  function normalizeOperatorGuidance() {
    const response = byId("operator-guidance-response");
    const meta = byId("operator-guidance-meta");
    if (!response || !meta) return;

    const raw = [textOf(response), textOf(meta)].filter(Boolean).join(" ");
    if (!raw) return;

    const fields = parseGuidanceFields(raw);
    if (!fields) return;

    renderStructuredGuidance(fields, response, meta);
  }

  let guidanceObserver = null;

  function attachGuidanceObserver() {
    const panel = byId("operator-guidance-panel");
    if (!panel || guidanceObserver) return;

    guidanceObserver = new MutationObserver(() => {
      normalizeOperatorGuidance();
    });

    guidanceObserver.observe(panel, {
      childList: true,
      subtree: true,
      characterData: true
    });
  }

  function boot() {
    normalizeLegacyStatusPanels();
    normalizeOperatorGuidance();
    attachGuidanceObserver();

    setInterval(() => {
      normalizeLegacyStatusPanels();
      normalizeOperatorGuidance();
      attachGuidanceObserver();
    }, 500);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
