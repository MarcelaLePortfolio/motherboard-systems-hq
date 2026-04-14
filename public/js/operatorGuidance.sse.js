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

  function buildResponse(data) {
    return firstNonEmpty(
      data?.message,
      data?.guidance,
      data?.response,
      data?.headline,
      data?.summary,
      data?.uiSummary?.headline,
      data?.uiSummary?.detail
    );
  }

  function buildMeta(data) {
    const directMeta = firstNonEmpty(data?.meta);
    if (directMeta) return directMeta;

    const parts = [];

    const confidence = firstNonEmpty(
      data?.confidence,
      data?.uiSummary?.confidence,
      data?.latestConfidence
    );
    if (confidence) {
      parts.push(`Confidence: ${confidence}`);
    }

    const sources = Array.isArray(data?.sources)
      ? data.sources.filter(Boolean).join(", ")
      : firstNonEmpty(data?.sources, data?.source);
    if (sources) {
      parts.push(`Sources: ${sources}`);
    }

    const governance = firstNonEmpty(data?.latestGovernanceDecision, data?.governance);
    if (governance) {
      parts.push(`Governance: ${governance}`);
    }

    const approval = firstNonEmpty(data?.latestApprovalStatus, data?.approval);
    if (approval) {
      parts.push(`Approval: ${approval}`);
    }

    const execution = firstNonEmpty(data?.latestExecutionStatus, data?.execution);
    if (execution) {
      parts.push(`Execution: ${execution}`);
    }

    const failure = firstNonEmpty(data?.latestFailureStage, data?.failureStage);
    if (failure) {
      parts.push(`Failure Stage: ${failure}`);
    }

    return parts.join("\n").trim();
  }

  function applyPayload(data) {
    const response = buildResponse(data);
    const meta = buildMeta(data);

    if (RESPONSE_EL && response) {
      RESPONSE_EL.textContent = response;
    }

    if (META_EL && meta) {
      META_EL.textContent = meta;
    }
  }

  function startStream() {
    if (eventSource) return;

    eventSource = new EventSource("/events/operator-guidance");

    eventSource.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        applyPayload(data);
      } catch (_) {}
    };

    eventSource.onerror = () => {
      closeStream();
    };
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
