#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — OPERATOR GUIDANCE SURFACE VERIFY"
echo "────────────────────────────────"

OUT="docs/phase487_operator_guidance_surface_verify.md"
mkdir -p docs

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

{
  echo "# Phase 487 Operator Guidance Surface Verification"
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
  echo "## Live endpoint checks"
  echo
  echo '```'
  echo "GET /api/guidance"
  curl -i -s http://localhost:8080/api/guidance | sed -n '1,120p' || true
  echo
  echo "GET /diagnostics/system-health"
  curl -i -s http://localhost:8080/diagnostics/system-health | sed -n '1,120p' || true
  echo '```'
  echo
  echo "## Guidance payload quick read"
  echo
  echo '```'
  python3 - << 'PY'
import json, urllib.request

def fetch(url):
    try:
        with urllib.request.urlopen(url, timeout=5) as r:
            raw = r.read().decode("utf-8", errors="replace")
            try:
                data = json.loads(raw)
                print(f"URL: {url}")
                if isinstance(data, dict):
                    print("top-level-keys:", sorted(data.keys())[:40])
                    for key in ["ok", "status", "severity", "level", "summary", "message", "source", "guidance"]:
                        if key in data:
                            print(f"{key}:", data[key])
                else:
                    print("type:", type(data).__name__)
                print()
            except Exception:
                print(f"URL: {url}")
                print(raw[:1200])
                print()
    except Exception as e:
        print(f"URL: {url}")
        print("ERROR:", e)
        print()

fetch("http://localhost:8080/api/guidance")
fetch("http://localhost:8080/diagnostics/system-health")
PY
  echo '```'
  echo
  echo "## Recent dashboard logs"
  echo
  echo '```'
  docker compose logs --tail=120 dashboard || true
  echo '```'
  echo
  echo "## Determination template"
  echo
  echo "- If /api/guidance returns stable JSON, the guidance surface is live."
  echo "- If guidance content is repetitive, malformed, or low-signal, the issue is content/readability rather than route absence."
  echo "- If /diagnostics/system-health is healthy while /api/guidance is poor, prioritize UI-safe guidance rendering/readability fixes next."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
