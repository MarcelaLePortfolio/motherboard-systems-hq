#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_operator_guidance_stream_focus.txt"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

OPS_SAMPLE="$TMP_DIR/ops.sample.txt"
REF_SAMPLE="$TMP_DIR/reflections.sample.txt"
HTML_SAMPLE="$TMP_DIR/dashboard.html"
JS_SAMPLE="$TMP_DIR/operatorGuidance.sse.js"

{
  echo "PHASE 456 — OPERATOR GUIDANCE STREAM FOCUS"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== PRECHECK ==="
  git rev-parse --abbrev-ref HEAD
  git rev-parse HEAD
  echo
  git status --short || true
  echo
  df -h .
  echo

  echo "=== CANONICAL COMPOSE STATE ==="
  docker compose ps || true
  echo

  echo "=== HTTP CHECKS ==="
  curl -I --max-time 10 http://localhost:8080/dashboard.html || true
  echo
  curl -I --max-time 10 "http://localhost:8080/js/operatorGuidance.sse.js?v=phase96-live-1" || true
  echo

  echo "=== FETCH DASHBOARD HTML ==="
  curl -fsSL --max-time 15 http://localhost:8080/dashboard.html > "$HTML_SAMPLE"
  grep -nE "operatorGuidance|events/ops|events/reflections|phase457|bundle|SYSTEM_HEALTH|Operator Guidance" "$HTML_SAMPLE" || true
  echo

  echo "=== FETCH OPERATOR GUIDANCE JS ==="
  curl -fsSL --max-time 15 "http://localhost:8080/js/operatorGuidance.sse.js?v=phase96-live-1" > "$JS_SAMPLE"
  grep -nE "events/ops|events/reflections|EventSource|SYSTEM_HEALTH|HIGH|append|textContent|innerHTML|replace|awaiting|guidance" "$JS_SAMPLE" | head -200 || true
  echo

  echo "=== SAMPLE /events/ops ==="
  timeout 5 curl -NsS "http://localhost:8080/events/ops" > "$OPS_SAMPLE" || true
  sed -n '1,120p' "$OPS_SAMPLE" || true
  echo

  echo "=== SAMPLE /events/reflections ==="
  timeout 5 curl -NsS "http://localhost:8080/events/reflections" > "$REF_SAMPLE" || true
  sed -n '1,120p' "$REF_SAMPLE" || true
  echo

  echo "=== FILTERED OPS SIGNALS ==="
  grep -niE "SYSTEM_HEALTH|HIGH|INFO|AWAITING|guidance|event:|data:" "$OPS_SAMPLE" | head -200 || true
  echo

  echo "=== FILTERED REFLECTION SIGNALS ==="
  grep -niE "SYSTEM_HEALTH|HIGH|INFO|AWAITING|guidance|event:|data:" "$REF_SAMPLE" | head -200 || true
  echo

  echo "=== CANONICAL DASHBOARD LOGS (TAIL 160) ==="
  docker compose logs --tail 160 dashboard 2>&1 || true
  echo

  echo "=== SEARCH: GUIDANCE RENDER TARGETS ==="
  grep -RniE "operatorGuidance|SYSTEM_HEALTH|events/ops|events/reflections|AWAITINGBOUNDEDGUIDANCE|Live operator guidance will appear here|Operator Guidance" \
    public server src app routes . 2>/dev/null | head -400 || true
  echo
} | tee "$OUT"
