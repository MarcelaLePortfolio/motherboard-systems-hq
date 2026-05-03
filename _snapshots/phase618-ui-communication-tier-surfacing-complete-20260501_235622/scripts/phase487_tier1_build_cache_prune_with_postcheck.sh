#!/bin/bash

set -euo pipefail

mkdir -p .runtime docs

OUT_TXT=".runtime/phase487_tier1_build_cache_prune_with_postcheck.txt"
OUT_MD="docs/phase487_tier1_build_cache_prune_result.md"

: > "$OUT_TXT"

log() {
  echo "$1" | tee -a "$OUT_TXT"
}

run_bounded() {
  local label="$1"
  shift
  log "---- ${label} ----"
  python3 - "$@" << 'PY' | tee -a "$OUT_TXT"
import subprocess
import sys

cmd = sys.argv[1:]
try:
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=20)
    if r.stdout:
        print(r.stdout, end="")
    if r.stderr:
        print(r.stderr, end="")
    print(f"exit={r.returncode}")
except subprocess.TimeoutExpired as e:
    if e.stdout:
        try:
            print(e.stdout.decode() if isinstance(e.stdout, bytes) else e.stdout, end="")
        except Exception:
            pass
    if e.stderr:
        try:
            print(e.stderr.decode() if isinstance(e.stderr, bytes) else e.stderr, end="")
        except Exception:
            pass
    print("exit=124")
    print(f"TIMEOUT {' '.join(cmd)}")
PY
  log ""
}

log "PHASE 487 — TIER 1 BUILD CACHE PRUNE WITH POST-CHECK"
log "DATE: $(date)"
log ""
log "Protected volume remains excluded: motherboard_systems_hq_pgdata"
log ""

run_bounded "precheck docker version" docker version
run_bounded "precheck docker ps" docker ps
run_bounded "precheck docker system df" docker system df

log "---- execute docker builder prune -f ----"
docker builder prune -f 2>&1 | tee -a "$OUT_TXT"
log "exit=$?"
log ""

run_bounded "postcheck docker version" docker version
run_bounded "postcheck docker ps" docker ps
run_bounded "postcheck docker system df" docker system df

python3 - << 'PY'
from pathlib import Path
txt = Path(".runtime/phase487_tier1_build_cache_prune_with_postcheck.txt").read_text(errors="ignore")

summary = []
summary.append("# Phase 487 Tier 1 Build Cache Prune Result")
summary.append("")
summary.append("Generated from `.runtime/phase487_tier1_build_cache_prune_with_postcheck.txt`.")
summary.append("")
summary.append("## Safety Gate")
summary.append("")
if "retrieving disk usage: EOF" in txt or "\nEOF\n" in txt or "TIMEOUT docker" in txt or "exit=124" in txt:
    summary.append("- Docker health degraded during or after Tier 1 prune.")
    summary.append("- Stop here. Do not proceed to Tier 2.")
else:
    summary.append("- Docker remained healthy through Tier 1 prune.")
    summary.append("- Safe to consider Tier 2 only if still needed.")
summary.append("")
summary.append("## Key Signals")
summary.append("")
signals = []
for line in txt.splitlines():
    low = line.lower()
    if "reclaimed" in low or "deleted" in low or "total reclaimed space" in low:
        signals.append(line)
    if "exit=" in line or "timeout" in low or "retrieving disk usage: eof" in low or line.strip() == "EOF":
        signals.append(line)

if signals:
    summary.append("```")
    summary.extend(signals[-120:])
    summary.append("```")
else:
    summary.append("_No key signals captured._")

Path("docs/phase487_tier1_build_cache_prune_result.md").write_text("\n".join(summary) + "\n")
print("Wrote docs/phase487_tier1_build_cache_prune_result.md")
PY

sed -n '1,220p' "$OUT_MD"
