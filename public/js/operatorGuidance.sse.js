(function () {
  const ENDPOINT = "/events/operator-guidance";

  function byId(id) {
    return document.getElementById(id);
  }

  function escapeHtml(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function renderReduction(reduction, source) {
    const responseEl = byId("operator-guidance-response");
    const metaEl = byId("operator-guidance-meta");

    if (!responseEl || !metaEl) return;

    const guidance = Array.isArray(reduction?.envelope?.guidance)
      ? reduction.envelope.guidance
      : [];

    const confidence = reduction?.surfaceConfidence || "insufficient";
    const reason = reduction?.confidenceReason || "No guidance reason available.";
    const signalCount = Number.isFinite(reduction?.signalCount) ? reduction.signalCount : 0;
    const conflicting = reduction?.conflictingSignals === true ? "present" : "none";
    const sourceLabel = source || "diagnostics/system-health";

    if (guidance.length === 0) {
      responseEl.innerHTML =
        '<div class="text-sm text-gray-300 leading-6">' +
        escapeHtml(reason) +
        "</div>";
    } else {
      responseEl.innerHTML = guidance
        .map(function (item) {
          const message = item?.message || "Guidance available.";
          const rationale = item?.rationale || "";
          const domain = item?.domain || "unknown";
          const severity = item?.severity || "unknown";
          const itemConfidence = item?.confidence || confidence;
          return (
            '<div class="mb-3 last:mb-0">' +
              '<div class="text-xs uppercase tracking-[0.16em] text-gray-500 mb-1">' +
                escapeHtml(domain) + " • " + escapeHtml(severity) + " • " + escapeHtml(itemConfidence) +
              "</div>" +
              '<div class="text-sm text-gray-200 leading-6">' +
                escapeHtml(message) +
              "</div>" +
              (rationale
                ? '<div class="mt-1 text-xs text-gray-400 leading-5">' + escapeHtml(rationale) + "</div>"
                : "") +
            "</div>"
          );
        })
        .join("");
    }

    metaEl.innerHTML =
      "Confidence: " + escapeHtml(confidence) +
      "<br>Signals: " + escapeHtml(String(signalCount)) +
      "<br>Conflicts: " + escapeHtml(conflicting) +
      "<br>Source: " + escapeHtml(sourceLabel);
  }

  function connect() {
    const stream = new EventSource(ENDPOINT);

    stream.addEventListener("operator_guidance", function (e) {
      try {
        const payload = JSON.parse(e.data);
        renderReduction(payload?.reduction || null, payload?.source || null);
      } catch (err) {
        console.error("Operator guidance parse failure", err);
      }
    });

    stream.onerror = function (err) {
      console.warn("Operator guidance stream disconnected", err);
    };

    console.log("Operator guidance stream connected");
  }

  try {
    connect();
  } catch (err) {
    console.error("Operator guidance SSE failed", err);
  }
})();
