#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase149] running static execution capability audit"
bash scripts/_local/phase149_run_execution_capability_audit.sh

echo
echo "[phase149] capability presence summary"
python3 - << 'PY'
import json
from pathlib import Path

report = Path("/tmp/phase149_execution_capability_audit.json")
data = json.loads(report.read_text())

caps = data["capabilities"]
present = []
missing = []
for name, info in caps.items():
    line = f"{name}: present={info['present']} match_count={info['match_count']}"
    if info["present"]:
        present.append(line)
    else:
        missing.append(line)

print("PRESENT CAPABILITIES")
for line in present:
    print(f"  - {line}")

print("\nABSENT CAPABILITIES")
for line in missing:
    print(f"  - {line}")

print("\nTOP MATCH FILES")
for name, info in caps.items():
    if info["present"]:
        first = info["files"][0]
        print(f"  - {name}: {first['file']}")
PY

echo
echo "[phase149] full report saved at /tmp/phase149_execution_capability_audit.json"
