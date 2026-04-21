#!/bin/bash

set -euo pipefail

mkdir -p .runtime docs

OUT_TXT=".runtime/phase487_restore_proof_preflight.txt"
OUT_MD="docs/phase487_restore_proof_preflight.md"

VOLUME_NAME="motherboard_systems_hq_pgdata"

{
  echo "PHASE 487 — RESTORE PROOF PREFLIGHT (READ-ONLY)"
  echo "DATE: $(date)"
  echo ""

  echo "== Protected volume target =="
  echo "$VOLUME_NAME"
  echo ""

  echo "== Docker version =="
  docker version
  echo ""

  echo "== Docker volume ls =="
  docker volume ls
  echo ""

  echo "== Protected volume inspect =="
  docker volume inspect "$VOLUME_NAME"
  echo ""

  echo "== Docker compose files in repo root =="
  ls -1 docker-compose*.yml docker-compose*.yaml compose*.yml compose*.yaml 2>/dev/null || true
  echo ""

  echo "== Candidate compose references =="
  grep -RIn --include='docker-compose*.yml' --include='docker-compose*.yaml' --include='compose*.yml' --include='compose*.yaml' "$VOLUME_NAME" . 2>/dev/null || true
  echo ""

  echo "== Candidate postgres references =="
  grep -RIn --include='docker-compose*.yml' --include='docker-compose*.yaml' --include='compose*.yml' --include='compose*.yaml' -E 'postgres|5432|POSTGRES_' . 2>/dev/null || true
  echo ""

  echo "== Current docker images =="
  docker images
  echo ""

  echo "== Current docker system df =="
  docker system df
  echo ""
} > "$OUT_TXT"

python3 - << 'PY'
from pathlib import Path
txt = Path(".runtime/phase487_restore_proof_preflight.txt").read_text(errors="ignore")

summary = []
summary.append("# Phase 487 Restore-Proof Preflight")
summary.append("")
summary.append("Generated from `.runtime/phase487_restore_proof_preflight.txt`.")
summary.append("")
summary.append("## Goal")
summary.append("")
summary.append("Prepare the restore-proof corridor without mutating the protected volume.")
summary.append("")
summary.append("## Safety posture")
summary.append("")
summary.append("- Read-only only")
summary.append("- No backup executed yet")
summary.append("- No restore executed yet")
summary.append("- Protected volume remains untouched: `motherboard_systems_hq_pgdata`")
summary.append("")
summary.append("## What this preflight checks")
summary.append("")
summary.append("- Docker health")
summary.append("- Protected volume presence")
summary.append("- Compose/service references for Postgres")
summary.append("- Current image/runtime prerequisites")
summary.append("")
if "motherboard_systems_hq_pgdata" in txt and "Mountpoint" in txt:
    summary.append("## Result")
    summary.append("")
    summary.append("- Protected volume is present and inspectable.")
    summary.append("- Safe next step is generation of a non-destructive backup script.")
else:
    summary.append("## Result")
    summary.append("")
    summary.append("- Volume inspection did not return the expected data.")
    summary.append("- Stop before any backup/restore scripting.")
summary.append("")
Path("docs/phase487_restore_proof_preflight.md").write_text("\n".join(summary) + "\n")
print("Wrote docs/phase487_restore_proof_preflight.md")
PY

sed -n '1,220p' "$OUT_MD"
