#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_489_H1_OPERATOR_GUIDANCE_REDUCTION_SHAPE_INSPECTION.txt"

{
  echo "PHASE 489 — H1 OPERATOR GUIDANCE REDUCTION SHAPE INSPECTION"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo

  echo "=== TARGET FUNCTIONS ==="
  grep -RIn 'function reduceSystemHealthSnapshotToGuidanceReduction\|const reduceSystemHealthSnapshotToGuidanceReduction\|reduceSystemHealthSnapshotToGuidanceReduction\|buildSystemHealthSnapshot' "$ROOT" \
    --include="*.js" --include="*.mjs" --include="*.ts" --include="*.tsx" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build || true
  echo

  echo "=== FUNCTION SOURCE SNIPPETS ==="
  while IFS=: read -r file line _; do
    [[ -n "${file:-}" ]] || continue
    [[ -f "$file" ]] || continue
    echo "--- $file:$line ---"
    start="$(( line > 40 ? line - 40 : 1 ))"
    end="$(( line + 220 ))"
    sed -n "${start},${end}p" "$file"
    echo
  done < <(
    grep -RIn 'reduceSystemHealthSnapshotToGuidanceReduction\|buildSystemHealthSnapshot' "$ROOT" \
      --include="*.js" --include="*.mjs" --include="*.ts" --include="*.tsx" \
      --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build || true
  )

  echo "=== LIVE SSE SAMPLE (SAFE TIME-BOUNDED) ==="
  python3 - <<'PY'
import subprocess, time, sys, json, re

cmd = ["curl", "-N", "-s", "--max-time", "6", "http://localhost:8080/events/operator-guidance"]
proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)

lines = []
try:
    for raw in proc.stdout:
        lines.append(raw.rstrip("\n"))
finally:
    try:
        proc.wait(timeout=2)
    except Exception:
        proc.kill()

print("RAW STREAM:")
for line in lines[:120]:
    print(line)

print("\nPARSED DATA FRAMES:")
for line in lines:
    if line.startswith("data: "):
        payload = line[len("data: "):]
        print(payload)
        try:
            obj = json.loads(payload)
            print("TOP-LEVEL KEYS:", sorted(obj.keys()))
            if isinstance(obj.get("reduction"), dict):
                print("REDUCTION KEYS:", sorted(obj["reduction"].keys()))
                print("REDUCTION JSON:", json.dumps(obj["reduction"], indent=2))
        except Exception as e:
            print("JSON PARSE ERROR:", str(e))
        print("---")
PY
  echo

  echo "=== CURRENT CLIENT SOURCE ==="
  sed -n '1,260p' "$ROOT/public/js/operatorGuidance.sse.js" 2>/dev/null || echo "MISSING: public/js/operatorGuidance.sse.js"
  echo

  echo "=== NEXT ACTION ==="
  echo "Use the observed REDUCTION KEYS to map real message/meta fields into the client."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
