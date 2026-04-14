#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
TARGET="$ROOT/public/js/operatorGuidance.sse.js"

cat > "$TARGET" <<'JS'
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

    const response = firstNonEmpty(
      reduction?.headline,
      reduction?.summary,
      reduction?.detail,
      reduction?.message,
      data?.message,
      data?.summary,
      "No guidance available"
    );

    const metaLines = [];

    const confidence = firstNonEmpty(
      reduction?.confidence,
      data?.confidence
    );
    if (confidence) metaLines.push(`Confidence: ${confidence}`);

    const source = firstNonEmpty(
      data?.source,
      reduction?.source
    );
    if (source) metaLines.push(`Sources: ${source}`);

    const governance = firstNonEmpty(
      reduction?.governance,
      reduction?.decision,
      data?.latestGovernanceDecision
    );
    if (governance) metaLines.push(`Governance: ${governance}`);

    const approval = firstNonEmpty(
      reduction?.approval,
      data?.latestApprovalStatus
    );
    if (approval) metaLines.push(`Approval: ${approval}`);

    const execution = firstNonEmpty(
      reduction?.execution,
      data?.latestExecutionStatus
    );
    if (execution) metaLines.push(`Execution: ${execution}`);

    const failure = firstNonEmpty(
      reduction?.failureStage,
      data?.latestFailureStage
    );
    if (failure) metaLines.push(`Failure Stage: ${failure}`);

    return {
      response,
      metaLines
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
JS

echo "Updated operatorGuidance.sse.js with reduction-aware mapping"

