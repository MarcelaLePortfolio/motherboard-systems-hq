#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_489_H1_OPERATOR_GUIDANCE_EVENT_PAYLOAD_TRACE.txt"

{
  echo "PHASE 489 — H1 OPERATOR GUIDANCE EVENT PAYLOAD TRACE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo

  echo "=== LIVE OBSERVATION ==="
  echo "Operator Guidance still shows fallback meta ('Confidence: insufficient')."
  echo "Telemetry Console changed, which indicates the served dashboard is updating."
  echo

  echo "=== SERVED SSE ROUTE HEADERS ==="
  curl -i -s http://localhost:8080/events/operator-guidance | sed -n '1,60p' || true
  echo

  echo "=== LIVE SSE PAYLOAD SAMPLE (6s) ==="
  python3 - <<'PY'
import subprocess, time, sys
cmd = ["curl", "-N", "-s", "http://localhost:8080/events/operator-guidance"]
proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
start = time.time()
try:
    while time.time() - start < 6:
        line = proc.stdout.readline()
        if not line:
            time.sleep(0.1)
            continue
        sys.stdout.write(line)
        sys.stdout.flush()
finally:
    proc.terminate()
    try:
        proc.wait(timeout=2)
    except Exception:
        proc.kill()
PY
  echo
  echo

  echo "=== CURRENT CLIENT SCRIPT ==="
  sed -n '1,220p' "$ROOT/public/js/operatorGuidance.sse.js" 2>/dev/null || echo "MISSING: public/js/operatorGuidance.sse.js"
  echo

  echo "=== SERVER ROUTE SNIPPET (server.mjs) ==="
  grep -n 'app.get("/events/operator-guidance"' "$ROOT/server.mjs" || true
  route_line="$(grep -n 'app.get("/events/operator-guidance"' "$ROOT/server.mjs" | head -n 1 | cut -d: -f1 || true)"
  if [[ -n "${route_line:-}" ]]; then
    start="$(( route_line > 40 ? route_line - 40 : 1 ))"
    end="$(( route_line + 140 ))"
    sed -n "${start},${end}p" "$ROOT/server.mjs"
  else
    echo "ROUTE NOT FOUND IN server.mjs"
  fi
  echo

  echo "=== DOM ANCHORS IN SERVED INDEX ==="
  grep -nA12 -B6 'operator-guidance-response\|operator-guidance-meta' "$ROOT/public/index.html" || true
  echo

  echo "=== QUICK DIAGNOSIS ==="
  echo "If SSE payload keys do not match data.message / data.meta,"
  echo "the client is mounted but reading the wrong fields."
  echo "If SSE payload is empty or never arrives, the route is the issue."
  echo "If payload is correct but UI still unchanged, another writer may be overwriting the panel."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
