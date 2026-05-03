#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

TARGET="scripts/_local/phase61_5_5s_probe_truthful_agent_runtime.sh"
OUT="docs/checkpoints/PHASE61_5_5T_RUNTIME_PROBE_FIX_$(date +%Y%m%d_%H%M%S).txt"
mkdir -p docs/checkpoints

python3 << 'PY'
from pathlib import Path

path = Path("scripts/_local/phase61_5_5s_probe_truthful_agent_runtime.sh")
text = path.read_text()

old = r'''  echo "== current source handler anchors =="
  grep -nE 'function handleOpsEvent|function applyAgentMap|function applySingleAgent|addEventListener\\("ops.state"|source\\.onmessage' public/js/agent-status-row.js public/bundle.js || true
  echo
} > "$OUT"

echo "$OUT"'''

new = r'''  echo "== current source handler anchors =="
  grep -nE 'function handleOpsEvent|function applyAgentMap|function applySingleAgent|addEventListener\\("ops\.state"|source\.onmessage' public/js/agent-status-row.js public/bundle.js || true
  echo
} > "$OUT"

echo "$OUT"

echo
echo "== latest probe findings =="
sed -n '1,260p' "$OUT"'''

if old not in text:
    raise SystemExit("expected probe grep block not found")

path.write_text(text.replace(old, new, 1))
print("patched runtime probe regex and enabled immediate findings printout")
PY

scripts/_local/phase61_5_5s_probe_truthful_agent_runtime.sh | tee "$OUT"

git add scripts/_local/phase61_5_5s_probe_truthful_agent_runtime.sh docs/checkpoints
git commit -m "Phase 61.5.5t: fix runtime probe regex and print findings"
git push origin phase61-cherry-pick-recovery
