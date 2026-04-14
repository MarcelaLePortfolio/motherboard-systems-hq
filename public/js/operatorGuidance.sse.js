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
    if (typeof raw === "string") {
      try {
        data = JSON.parse(raw);
      } catch {
        data = { message: raw };
      }
    }

    const reduction = data?.reduction ?? {};

    return {
      response: firstNonEmpty(
        reduction?.message,
        reduction?.guidance,
        reduction?.summary,
        reduction?.headline,
        reduction?.detail,
        data?.message,
        data?.guidance,
        data?.response,
        data?.headline,
        data?.summary,
        data?.uiSummary?.headline,
        data?.uiSummary?.detail
      ),
      metaLines: [
        firstNonEmpty(
          reduction?.confidence ? `Confidence: ${reduction.confidence}` : "",
          data?.confidence ? `Confidence: ${data.confidence}` : "",
          data?.uiSummary?.confidence ? `Confidence: ${data.uiSummary.confidence}` : "",
          data?.latestConfidence ? `Confidence: ${data.latestConfidence}` : ""
        ),
        firstNonEmpty(
          reduction?.source ? `Sources: ${reduction.source}` : "",
          data?.source ? `Sources: ${data.source}` : "",
          Array.isArray(data?.sources) && data.sources.length
            ? `Sources: ${data.sources.filter(Boolean).join(", ")}`
            : ""
        ),
        firstNonEmpty(
          reduction?.governance ? `Governance: ${reduction.governance}` : "",
          data?.latestGovernanceDecision ? `Governance: ${data.latestGovernanceDecision}` : "",
          data?.governance ? `Governance: ${data.governance}` : ""
        ),
        firstNonEmpty(
          reduction?.approval ? `Approval: ${reduction.approval}` : "",
          data?.latestApprovalStatus ? `Approval: ${data.latestApprovalStatus}` : "",
          data?.approval ? `Approval: ${data.approval}` : ""
        ),
        firstNonEmpty(
          reduction?.execution ? `Execution: ${reduction.execution}` : "",
          data?.latestExecutionStatus ? `Execution: ${data.latestExecutionStatus}` : "",
          data?.execution ? `Execution: ${data.execution}` : ""
        ),
        firstNonEmpty(
          reduction?.failureStage ? `Failure Stage: ${reduction.failureStage}` : "",
          data?.latestFailureStage ? `Failure Stage: ${data.latestFailureStage}` : "",
          data?.failureStage ? `Failure Stage: ${data.failureStage}` : ""
        )
      ].filter(Boolean)
    };
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
