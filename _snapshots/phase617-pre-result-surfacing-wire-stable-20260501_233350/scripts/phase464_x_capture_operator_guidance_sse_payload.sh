#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs

OUT="docs/phase464_x_operator_guidance_sse_payload_capture.txt"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

try_capture() {
  local base="$1"
  local label="$2"

  local headers="$TMP/${label}_headers.txt"
  local body="$TMP/${label}_body.txt"

  echo "===== TARGET: ${base}/api/operator-guidance ====="
  echo

  if ! curl -N -sS -D "$headers" --max-time 8 "${base}/api/operator-guidance" > "$body"; then
    echo "RESULT: REQUEST FAILED"
    echo
    return 0
  fi

  echo "HEADERS:"
  sed -n '1,80p' "$headers"
  echo

  echo "FIRST 120 LINES OF BODY:"
  sed -n '1,120p' "$body"
  echo

  echo "FRAME COUNT SNAPSHOT:"
  echo "data lines: $(grep -c '^data:' "$body" || true)"
  echo "event lines: $(grep -c '^event:' "$body" || true)"
  echo "id lines: $(grep -c '^id:' "$body" || true)"
  echo

  echo "UNIQUE SYSTEM_HEALTH OCCURRENCES:"
  grep -n 'SYSTEM_HEALTH' "$body" | head -n 40 || true
  echo

  echo "JSON PAYLOAD LINES:"
  grep '^data:' "$body" | head -n 40 || true
  echo
}

{
  echo "PHASE 464.X — OPERATOR GUIDANCE SSE PAYLOAD CAPTURE"
  echo "===================================================="
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo

  try_capture "http://localhost:8080" "port8080"
  try_capture "http://localhost:3000" "port3000"

  echo "DECISION GATE:"
  echo "- If the captured SSE body already contains repeated SYSTEM_HEALTH payloads, the producer is server-side."
  echo "- If the captured SSE body is stable/single-shot, repetition is happening in the browser consumer/render layer."
  echo "- Next mutation must target the side proven by this capture."
} > "$OUT"

echo "Wrote $OUT"
