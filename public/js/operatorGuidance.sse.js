(() => {
  if (window.__OPERATOR_GUIDANCE_STREAM_ACTIVE__) return;
  window.__OPERATOR_GUIDANCE_STREAM_ACTIVE__ = true;

  const RESPONSE_EL = document.getElementById("operator-guidance-response");
  const META_EL = document.getElementById("operator-guidance-meta");

  let eventSource = null;

  function closeStream() {
    if (eventSource) {
      eventSource.close();
      eventSource = null;
    }
  }

  function firstNonEmpty(...values) {
    for (const value of values) {
      if (value === null || value === undefined) continue;
      const text = String(value).trim();
      if (text) return text;
    }
    return "";
  }

  function normalizePayload(raw) {
    let data = raw;
    try {
      if (typeof raw === "string") data = JSON.parse(raw);
    } catch (_) {}

    const reduction = data?.reduction || {};
    const envelope = reduction?.envelope || {};
    const guidanceItems = Array.isArray(envelope?.guidance) ? envelope.guidance : [];

    const guidanceLines = guidanceItems
      .map((item) =>
        firstNonEmpty(
          item?.summary,
          item?.message,
          item?.headline,
          item?.detail,
          item?.reason
        )
      )
      .filter(Boolean);

    const response = firstNonEmpty(
      guidanceLines.join("\n"),
      reduction?.confidenceReason,
      data?.message,
      data?.summary,
      "No guidance available"
    );

    const sourceSet = new Set();
    if (data?.source) sourceSet.add(String(data.source).trim());
    guidanceItems.forEach((item) => {
      const src = firstNonEmpty(item?.source, item?.domain, item?.key);
      if (src) sourceSet.add(src);
    });

    const metaLines = [];

    const confidence = firstNonEmpty(
      reduction?.surfaceConfidence,
      reduction?.confidence,
      data?.confidence
    );
    if (confidence) metaLines.push(`Confidence: ${confidence}`);

    const confidenceReason = firstNonEmpty(reduction?.confidenceReason);
    if (confidenceReason) metaLines.push(`Reason: ${confidenceReason}`);

    const signalCount =
      reduction?.signalCount !== undefined && reduction?.signalCount !== null
        ? String(reduction.signalCount).trim()
        : "";
    if (signalCount) metaLines.push(`Signals Observed: ${signalCount}`);

    if (reduction?.conflictingSignals === true) {
      metaLines.push("Conflicting Signals: yes");
    }

    const sources = Array.from(sourceSet).filter(Boolean).join(", ");
    if (sources) metaLines.push(`Sources: ${sources}`);

    return { response, metaLines };
  }

  function applyPayload(raw) {
    const normalized = normalizePayload(raw);

    if (RESPONSE_EL && normalized.response) {
      RESPONSE_EL.textContent = normalized.response;
    }

    if (META_EL && normalized.metaLines.length) {
      META_EL.textContent = normalized.metaLines.join("\n");
    }
  }

  function attachHandlers(es) {
    const handleEvent = (event) => {
      try {
        applyPayload(event.data);
      } catch (_) {}
    };

    es.onmessage = handleEvent;
    es.addEventListener("operator_guidance", handleEvent);
    es.addEventListener("operator-guidance", handleEvent);
    es.addEventListener("guidance", handleEvent);

    es.onerror = () => {
      closeStream();
    };
  }

  function startStream() {
    if (eventSource) return;
    eventSource = new EventSource("/events/operator-guidance");
    attachHandlers(eventSource);
  }

  startStream();

  document.addEventListener("visibilitychange", () => {
    if (document.visibilityState === "hidden") {
      closeStream();
    }
  });

  window.addEventListener("beforeunload", () => {
    closeStream();
  });
})();
