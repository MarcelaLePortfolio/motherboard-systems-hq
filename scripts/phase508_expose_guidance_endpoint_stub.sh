#!/usr/bin/env bash
set -euo pipefail

TARGET="server.mjs"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="/tmp/server_pre_phase508_${STAMP}.bak"

if [ ! -f "${TARGET}" ]; then
  echo "❌ server.mjs not found — adjust TARGET path"
  exit 1
fi

cp "${TARGET}" "${BACKUP}"

cat >> "${TARGET}" << 'SCRIPT'

// PHASE 508 — GUIDANCE ENDPOINT STUB (STRUCTURAL, NO FAKE SIGNALS)

app.get('/api/guidance', (req, res) => {
  res.json({
    guidance_available: false,
    guidance: null,
    reason: "no_active_guidance_stream"
  });
});

SCRIPT

echo "Phase 508 guidance endpoint stub added to ${TARGET}"
