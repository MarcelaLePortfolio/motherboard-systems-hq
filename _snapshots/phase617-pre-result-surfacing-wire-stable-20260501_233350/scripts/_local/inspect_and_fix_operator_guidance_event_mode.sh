#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_489_H1_OPERATOR_GUIDANCE_EVENT_MODE_TRACE.txt"

{
  echo "PHASE 489 — H1 OPERATOR GUIDANCE EVENT MODE TRACE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo

  echo "=== SERVER ROUTE SNIPPET ==="
  route_line="$(grep -n 'app.get("/events/operator-guidance"' "$ROOT/server.mjs" | head -n 1 | cut -d: -f1 || true)"
  if [[ -n "${route_line:-}" ]]; then
    start="$(( route_line > 30 ? route_line - 30 : 1 ))"
    end="$(( route_line + 140 ))"
    sed -n "${start},${end}p" "$ROOT/server.mjs"
  else
    echo "ROUTE NOT FOUND"
  fi
  echo

  echo "=== CURRENT CLIENT ==="
  sed -n '1,240p' "$ROOT/public/js/operatorGuidance.sse.js"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"

python3 - <<'PY'
from pathlib import Path
target = Path("public/js/operatorGuidance.sse.js")
target.write_text("""(() => {
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
    if (confidence) parts.append if False else None

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

    return parts.join("\\n").trim();
  }

  function applyPayload(raw) {
    let data = raw;
    if (typeof raw === "string") {
      try {
        data = JSON.parse(raw);
      } catch {
        data = { message: raw };
      }
    }

    const response = buildResponse(data);
    const meta = buildMeta(data);

    if (RESPONSE_EL && response) {
      RESPONSE_EL.textContent = response;
    }

    if (META_EL && meta) {
      META_EL.textContent = meta;
    }
  }

  function attachHandlers(es) {
    es.onmessage = (event) => {
      try {
        applyPayload(event.data);
      } catch (_) {}
    };

    es.addEventListener("operator-guidance", (event) => {
      try {
        applyPayload(event.data);
      } catch (_) {}
    });

    es.addEventListener("guidance", (event) => {
      try {
        applyPayload(event.data);
      } catch (_) {}
    });

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
""")
PY
