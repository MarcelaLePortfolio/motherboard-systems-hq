#!/usr/bin/env bash
set -euo pipefail

TARGET="server.mjs"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="/tmp/server_pre_phase510_${STAMP}.bak"

cp "${TARGET}" "${BACKUP}"

cat >> "${TARGET}" << 'SCRIPT'

// PHASE 510 — MINIMAL REAL GUIDANCE STREAM (DETERMINISTIC, NO FAKE SIGNALS)

app.get('/api/guidance', (req, res) => {

  const hasRequest =
    req.query?.request ||
    req.body?.request;

  // NO REQUEST → no guidance stream exists
  if (!hasRequest) {
    return res.json({
      guidance_available: false,
      guidance: null,
      reason: "no_request_provided"
    });
  }

  // REQUEST EXISTS → deterministic guidance scaffold
  // (still NOT "smart AI", just structured system response)
  return res.json({
    guidance_available: true,
    guidance: {
      status: "generated",
      input: hasRequest,
      steps: [
        "intake_received",
        "governance_not_evaluated",
        "execution_not_started"
      ],
      note: "minimal_deterministic_guidance_stream"
    },
    evidence: [],
    reason: "request_detected"
  });
});

SCRIPT

echo "Phase 510 minimal guidance stream wired into ${TARGET}"
