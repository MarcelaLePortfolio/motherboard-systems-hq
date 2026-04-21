#!/bin/bash

set -euo pipefail

mkdir -p .runtime docs

OUT_TXT=".runtime/phase487_run_volume_backup_with_verification.txt"
OUT_MD="docs/phase487_volume_backup_result.md"

: > "$OUT_TXT"

log() {
  echo "$1" | tee -a "$OUT_TXT"
}

log "PHASE 487 — RUN PROTECTED VOLUME BACKUP WITH VERIFICATION"
log "DATE: $(date)"
log ""

log "== Execute backup script =="
bash scripts/phase487_volume_backup_script.sh 2>&1 | tee -a "$OUT_TXT"
log ""

log "== Discover newest backup directory =="
BACKUP_ROOT="${HOME}/Desktop/Motherboard_Systems_HQ_Backups/postgres_volume"
LATEST_DIR="$(ls -1dt "${BACKUP_ROOT}"/* 2>/dev/null | head -n 1 || true)"

if [ -z "${LATEST_DIR}" ]; then
  log "ERROR: No backup directory found under ${BACKUP_ROOT}"
  exit 1
fi

BACKUP_FILE="${LATEST_DIR}/motherboard_systems_hq_pgdata.tar.gz"
MANIFEST_FILE="${LATEST_DIR}/backup_manifest.txt"

log "Latest backup dir: ${LATEST_DIR}"
log "Backup file: ${BACKUP_FILE}"
log "Manifest file: ${MANIFEST_FILE}"
log ""

log "== Verify artifacts exist =="
test -f "${BACKUP_FILE}"
test -f "${MANIFEST_FILE}"
ls -lh "${BACKUP_FILE}" "${MANIFEST_FILE}" | tee -a "$OUT_TXT"
log ""

log "== Verify archive readability =="
tar -tzf "${BACKUP_FILE}" | sed -n '1,40p' | tee -a "$OUT_TXT"
log ""

python3 - << 'PY'
from pathlib import Path
txt = Path(".runtime/phase487_run_volume_backup_with_verification.txt").read_text(errors="ignore")

summary = []
summary.append("# Phase 487 Protected Volume Backup Result")
summary.append("")
summary.append("Generated from `.runtime/phase487_run_volume_backup_with_verification.txt`.")
summary.append("")
summary.append("## Safety Result")
summary.append("")
if "ERROR:" in txt:
    summary.append("- Backup verification failed.")
    summary.append("- Stop before restore-script generation.")
else:
    summary.append("- Backup executed successfully.")
    summary.append("- Archive and manifest were both created.")
    summary.append("- Archive readability check passed.")
    summary.append("- Safe next step is generation of a restore script without executing restore yet.")
summary.append("")
summary.append("## Key Signals")
summary.append("")
signals = []
for line in txt.splitlines():
    low = line.lower()
    if "backup created:" in low or "manifest created:" in low or "latest backup dir:" in low:
        signals.append(line)
    if "motherboard_systems_hq_pgdata.tar.gz" in line or "backup_manifest.txt" in line:
        signals.append(line)
    if line.startswith("drwx") or line.startswith("-rw") or line.startswith("total "):
        signals.append(line)

if signals:
    summary.append("```")
    summary.extend(signals[-120:])
    summary.append("```")
else:
    summary.append("_No key signals captured._")

Path("docs/phase487_volume_backup_result.md").write_text("\n".join(summary) + "\n")
print("Wrote docs/phase487_volume_backup_result.md")
PY

sed -n '1,220p' "$OUT_MD"
