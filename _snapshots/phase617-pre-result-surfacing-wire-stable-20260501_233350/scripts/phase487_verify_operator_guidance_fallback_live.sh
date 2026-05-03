#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — VERIFY OPERATOR GUIDANCE FALLBACK LIVE"
echo "────────────────────────────────"

OUT="docs/phase487_verify_operator_guidance_fallback_live.md"
mkdir -p docs

{
  echo "# Phase 487 Verify Operator Guidance Fallback Live"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Runtime posture"
  echo
  echo '```'
  git status --short
  echo
  docker compose ps
  echo '```'
  echo
  echo "## Served HTML markers"
  echo
  echo '```'
  curl -s http://localhost:8080 | rg -n "phase487-operator-guidance-fallback|operator-guidance-response|operator-guidance-meta" || true
  echo '```'
  echo
  echo "## Live source payloads"
  echo
  echo '```'
  echo "/api/guidance"
  curl -s http://localhost:8080/api/guidance
  echo
  echo
  echo "/diagnostics/system-health"
  curl -s http://localhost:8080/diagnostics/system-health
  echo
  echo '```'
  echo
  echo "## Browserless fallback expectation"
  echo
  echo '```'
  python3 - << 'PY'
import json, urllib.request

guidance = json.loads(urllib.request.urlopen("http://localhost:8080/api/guidance", timeout=5).read().decode())
health = json.loads(urllib.request.urlopen("http://localhost:8080/diagnostics/system-health", timeout=5).read().decode())

expected = None
source = None

if isinstance(guidance, dict) and guidance.get("guidance_available") is True:
    g = guidance.get("guidance")
    if isinstance(g, str) and g.strip():
        expected = g.strip()
    elif isinstance(g, dict):
        for k in ("summary", "message", "text", "content", "body", "note"):
            v = g.get(k)
            if isinstance(v, str) and v.strip():
                expected = v.strip()
                break
    source = "/api/guidance"

if not expected:
    expected = health.get("situationSummary") or "System stable. No active guidance stream."
    source = "diagnostics/system-health (fallback)"

print("expected_source:", source)
print("expected_guidance_text:")
print(expected)
PY
  echo '```'
  echo
  echo "## Recent dashboard logs"
  echo
  echo '```'
  docker compose logs --tail=120 dashboard || true
  echo '```'
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
