#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_489_H1_OPERATOR_GUIDANCE_REDUCTION_CONTENT_TRACE.txt"

{
  echo "PHASE 489 — H1 OPERATOR GUIDANCE REDUCTION CONTENT TRACE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo

  echo "=== OBSERVATION ==="
  echo "Client wiring is now partially working:"
  echo "• fallback confidence line disappeared"
  echo "• source line remains"
  echo "• guidance body still shows placeholder content"
  echo
  echo "This strongly suggests the SSE route is connected, but the emitted reduction"
  echo "does not currently contain the message/meta fields the client expects."
  echo

  echo "=== SERVER ROUTE SNIPPET ==="
  route_line="$(grep -n 'app.get(\"/events/operator-guidance\"' "$ROOT/server.mjs" | head -n 1 | cut -d: -f1 || true)"
  if [[ -n "${route_line:-}" ]]; then
    start="$(( route_line > 30 ? route_line - 30 : 1 ))"
    end="$(( route_line + 180 ))"
    sed -n "${start},${end}p" "$ROOT/server.mjs"
  else
    echo "ROUTE NOT FOUND"
  fi
  echo

  echo "=== REDUCTION BUILDER REFERENCES ==="
  grep -RIn 'reduceSystemHealthSnapshotToGuidanceReduction\|buildSystemHealthSnapshot' "$ROOT" \
    --include="*.js" --include="*.mjs" --include="*.ts" --include="*.tsx" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build || true
  echo

  echo "=== REDUCTION BUILDER SOURCE SNIPPETS ==="
  while IFS=: read -r file line _; do
    [[ -n "${file:-}" ]] || continue
    [[ -f "$file" ]] || continue
    echo "--- $file:$line ---"
    start="$(( line > 30 ? line - 30 : 1 ))"
    end="$(( line + 160 ))"
    sed -n "${start},${end}p" "$file"
    echo
  done < <(
    grep -RIn 'reduceSystemHealthSnapshotToGuidanceReduction\|buildSystemHealthSnapshot' "$ROOT" \
      --include="*.js" --include="*.mjs" --include="*.ts" --include="*.tsx" \
      --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build || true
  )

  echo "=== LIVE EVENT SAMPLE (HEADERS + FIRST FRAMES) ==="
  python3 - <<'PY'
import subprocess, time, sys
print("---- HEADERS ----")
h = subprocess.run(
    ["curl", "-i", "-s", "http://localhost:8080/events/operator-guidance"],
    capture_output=True, text=True, timeout=5
)
print("\n".join(h.stdout.splitlines()[:40]))
print("\n---- STREAM ----")
proc = subprocess.Popen(
    ["curl", "-N", "-s", "http://localhost:8080/events/operator-guidance"],
    stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
)
start = time.time()
try:
    while time.time() - start < 8:
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

  echo "=== NEXT ACTION ==="
  echo "If emitted payload contains reduction only, client must map reduction fields."
  echo "If reduction contains no useful message/confidence, server reduction builder must be audited next."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
