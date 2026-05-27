#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
TS="$(date -u +"%Y%m%dT%H%M%SZ")"
OUT="PHASE62B_TERMINAL_METRICS_EVIDENCE_${TS}.txt"

echo "PHASE 62B TERMINAL METRICS EVIDENCE" | tee "$OUT"
echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")" | tee -a "$OUT"
echo | tee -a "$OUT"

echo "== tasks snapshot ==" | tee -a "$OUT"
curl -s "${BASE_URL}/api/tasks?limit=50" | tee -a "$OUT"
echo | tee -a "$OUT"

echo "== terminal counts ==" | tee -a "$OUT"

python3 <<'PY' | tee -a "$OUT"
import json, urllib.request

BASE="http://127.0.0.1:8080"

data=json.load(urllib.request.urlopen(f"{BASE}/api/tasks?limit=200"))

tasks=data.get("tasks",[])

success=0
failed=0
running=0
queued=0

for t in tasks:
    s=t.get("status")
    if s=="completed":
        success+=1
    elif s=="failed":
        failed+=1
    elif s=="running":
        running+=1
    elif s=="queued":
        queued+=1

total_terminal=success+failed

success_rate=0
if total_terminal>0:
    success_rate=round((success/total_terminal)*100,2)

print("success_tasks:",success)
print("failed_tasks:",failed)
print("running_tasks:",running)
print("queued_tasks:",queued)
print("terminal_total:",total_terminal)
print("calculated_success_rate:",success_rate)
PY

echo | tee -a "$OUT"
echo "== evidence artifact =="
echo "$OUT"
