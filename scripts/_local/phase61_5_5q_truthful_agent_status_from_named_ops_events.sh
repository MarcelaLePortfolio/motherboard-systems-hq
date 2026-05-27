#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

python3 <<'PY'
from pathlib import Path

path = Path("public/js/agent-status-row.js")
text = path.read_text()

old = '''  let source;
  try {
    source = (window.__PHASE16_SSE_OWNER_STARTED ? null : new EventSource(OPS_SSE_URL));
  } catch (err) {
    console.error("agent-status-row.js: Failed to open OPS SSE connection:", err);
    return;
  }

  if (!source) return;

  source.onmessage = (event) => {
    let data;
    try {
      data = JSON.parse(event.data);
    } catch {
      return;
    }

    const agentName =
      (data.agent || data.actor || data.source || data.worker || "").toString().toLowerCase();
    if (!agentName || !indicators[agentName]) return;

    const status = (data.status || data.state || data.level || "").toString() || "unknown";
    applyVisual(agentName, status);
  };

  source.onerror = (err) => {
    console.warn("agent-status-row.js: OPS SSE error:", err);
    Object.keys(indicators).forEach((key) => applyVisual(key, "unknown"));
  };
})();'''

new = '''  function parseJson(raw) {
    try {
      return JSON.parse(raw);
    } catch {
      return null;
    }
  }

  function extractPayload(data) {
    if (!data || typeof data !== "object") return null;
    if (data.payload && typeof data.payload === "object") return data.payload;
    if (data.data && typeof data.data === "object") return data.data;
    if (data.state && typeof data.state === "object") return data.state;
    return data;
  }

  function applyAgentMap(payload) {
    if (!payload || typeof payload !== "object") return false;
    const agents = payload.agents;
    if (!agents || typeof agents !== "object") return false;

    let applied = false;
    for (const [name, value] of Object.entries(agents)) {
      const key = String(name || "").toLowerCase();
      if (!indicators[key]) continue;

      let status = "unknown";
      if (typeof value === "string") {
        status = value;
      } else if (value && typeof value === "object") {
        status =
          value.status ??
          value.state ??
          value.level ??
          value.health ??
          value.mode ??
          "unknown";
      }

      applyVisual(key, String(status || "unknown"));
      applied = true;
    }
    return applied;
  }

  function applySingleAgent(data) {
    if (!data || typeof data !== "object") return false;

    const agentName =
      (data.agent || data.actor || data.source || data.worker || data.name || "").toString().toLowerCase();
    if (!agentName || !indicators[agentName]) return false;

    const status =
      data.status ??
      data.state ??
      data.level ??
      data.health ??
      data.mode ??
      "unknown";

    applyVisual(agentName, String(status || "unknown"));
    return true;
  }

  function handleOpsEvent(eventName, event) {
    const data = parseJson(event.data);
    if (!data) return;

    const payload = extractPayload(data);

    if (eventName === "ops.state") {
      if (applyAgentMap(payload)) return;
    }

    if (applyAgentMap(data)) return;
    if (applyAgentMap(payload)) return;
    applySingleAgent(payload);
    applySingleAgent(data);
  }

  let source;
  try {
    source = (window.__PHASE16_SSE_OWNER_STARTED ? null : new EventSource(OPS_SSE_URL));
  } catch (err) {
    console.error("agent-status-row.js: Failed to open OPS SSE connection:", err);
    return;
  }

  if (!source) return;

  source.onmessage = (event) => handleOpsEvent("message", event);
  source.addEventListener("hello", (event) => handleOpsEvent("hello", event));
  source.addEventListener("ops.state", (event) => handleOpsEvent("ops.state", event));
  source.addEventListener("state", (event) => handleOpsEvent("state", event));
  source.addEventListener("update", (event) => handleOpsEvent("update", event));

  source.onerror = (err) => {
    console.warn("agent-status-row.js: OPS SSE error:", err);
    Object.keys(indicators).forEach((key) => applyVisual(key, "unknown"));
  };
})();'''

if old not in text:
    raise SystemExit("expected EventSource handling block not found in public/js/agent-status-row.js")

path.write_text(text.replace(old, new, 1))
print("patched public/js/agent-status-row.js for truthful named ops event handling")
PY

npm run build:dashboard-bundle
docker compose build dashboard --no-cache
docker compose up -d
docker compose ps
docker logs --tail 40 motherboard_systems_hq-dashboard-1
