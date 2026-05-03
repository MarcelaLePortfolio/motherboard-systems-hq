#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
INDEX="$ROOT/public/index.html"
OUT="$ROOT/docs/PHASE_489_H2_TASK_EVENTS_CLIENT_RESTORE.txt"

CANDIDATE="$(
  grep -RIlE 'mb-task-events-panel-anchor|/events/task-events|task-events-panel-anchor|task-events' "$ROOT/public/js" 2>/dev/null \
    | grep -v 'operatorGuidance' \
    | head -n 1 || true
)"

{
  echo "PHASE 489 — H2 TASK EVENTS CLIENT RESTORE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo "Candidate Client: ${CANDIDATE:-NONE}"
  echo
} > "$OUT"

if [[ -z "${CANDIDATE:-}" ]]; then
  echo "No task-events client candidate found under public/js" | tee -a "$OUT"
  exit 1
fi

REL_PATH="${CANDIDATE#$ROOT/public/}"

python3 - <<PY
from pathlib import Path
index = Path(r"$INDEX")
text = index.read_text()

script_tag = f'  <script defer src="{r"$REL_PATH"}"></script>\n'

if script_tag not in text:
    anchor = '  <script defer src="js/dashboard-graph.js"></script>\n'
    if anchor in text:
        text = text.replace(anchor, anchor + script_tag)
    else:
        end_anchor = '</body>'
        text = text.replace(end_anchor, script_tag + end_anchor)

index.write_text(text)
PY

echo "Mounted task-events client: $REL_PATH" | tee -a "$OUT"
sed -n '1,120p' "$OUT"
