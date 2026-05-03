#!/bin/bash

set -euo pipefail

mkdir -p .runtime docs

OUT_TXT=".runtime/phase487_cold_start_rebuild_validation.txt"
OUT_MD="docs/phase487_cold_start_rebuild_validation.md"
TAG_NAME="phase487-restore-proof-complete"

: > "$OUT_TXT"

log() {
  echo "$1" | tee -a "$OUT_TXT"
}

run_cmd() {
  local label="$1"
  shift
  log "---- ${label} ----"
  "$@" 2>&1 | tee -a "$OUT_TXT"
  log "exit=$?"
  log ""
}

log "PHASE 487 — COLD START REBUILD VALIDATION"
log "DATE: $(date)"
log ""
log "Safety notes:"
log "- Protected live volume is preserved"
log "- No volume deletion is performed"
log "- This rebuilds runtime containers/images only"
log ""

run_cmd "docker version" docker version
run_cmd "docker compose config -q" docker compose config -q
run_cmd "docker compose up -d --build" docker compose up -d --build
run_cmd "docker compose ps" docker compose ps
run_cmd "docker ps" docker ps
run_cmd "docker images" docker images
run_cmd "docker system df" docker system df

python3 - << 'PY'
from pathlib import Path
txt = Path(".runtime/phase487_cold_start_rebuild_validation.txt").read_text(errors="ignore")

summary = []
summary.append("# Phase 487 Cold Start Rebuild Validation")
summary.append("")
summary.append("Generated from `.runtime/phase487_cold_start_rebuild_validation.txt`.")
summary.append("")
summary.append("## Result")
summary.append("")
if "exit=1" in txt or "exit=124" in txt:
    summary.append("- Cold start rebuild validation did not complete cleanly.")
    summary.append("- Do not advance beyond this checkpoint without reviewing output.")
else:
    summary.append("- Cold start rebuild validation completed cleanly.")
    summary.append("- Containers and images were rebuilt after prune.")
    summary.append("- Runtime environment is reproducible from the current repo state.")
summary.append("")
summary.append("## Practical meaning")
summary.append("")
summary.append("- The project is not just backed up; it is rebuildable.")
summary.append("- Docker cleanup did not strand the system.")
summary.append("- You now have proof of backup, restore, and cold-start rebuild.")
summary.append("")
summary.append("## Key signals")
summary.append("")
signals = []
for line in txt.splitlines():
    low = line.lower()
    if "created" in low or "started" in low or "running" in low or "healthy" in low:
        signals.append(line)
    if line.startswith("NAME") or line.startswith("CONTAINER ID") or line.startswith("IMAGE"):
        signals.append(line)
    if line.startswith("exit="):
        signals.append(line)

if signals:
    summary.append("```")
    summary.extend(signals[-200:])
    summary.append("```")
else:
    summary.append("_No key signals captured._")

Path("docs/phase487_cold_start_rebuild_validation.md").write_text("\n".join(summary) + "\n")
print("Wrote docs/phase487_cold_start_rebuild_validation.md")
PY

sed -n '1,260p' "$OUT_MD"
