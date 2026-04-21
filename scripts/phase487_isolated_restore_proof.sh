#!/bin/bash

set -euo pipefail

mkdir -p .runtime docs

OUT_TXT=".runtime/phase487_isolated_restore_proof.txt"
OUT_MD="docs/phase487_isolated_restore_proof.md"

LIVE_VOLUME="motherboard_systems_hq_pgdata"
BACKUP_ROOT="${HOME}/Desktop/Motherboard_Systems_HQ_Backups/postgres_volume"
LATEST_DIR="$(ls -1dt "${BACKUP_ROOT}"/* 2>/dev/null | head -n 1 || true)"
if [ -z "${LATEST_DIR}" ]; then
  echo "ERROR: no backup directory found under ${BACKUP_ROOT}" >&2
  exit 1
fi

BACKUP_FILE="${LATEST_DIR}/${LIVE_VOLUME}.tar.gz"
MANIFEST_FILE="${LATEST_DIR}/backup_manifest.txt"
STAMP="$(date +%Y%m%d-%H%M%S)"
VALIDATION_VOLUME="${LIVE_VOLUME}_restore_validation_${STAMP}"
VALIDATION_CONTAINER="phase487-restore-validate-${STAMP}"

: > "$OUT_TXT"

log() {
  echo "$1" | tee -a "$OUT_TXT"
}

run_bounded() {
  local label="$1"
  shift
  log "---- ${label} ----"
  python3 - "$@" << 'PY' | tee -a "$OUT_TXT"
import subprocess, sys
cmd = sys.argv[1:]
try:
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
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

cleanup_container() {
  docker rm -f "${VALIDATION_CONTAINER}" >/dev/null 2>&1 || true
}
trap cleanup_container EXIT

log "PHASE 487 — ISOLATED RESTORE PROOF"
log "DATE: $(date)"
log ""
log "Live protected volume (untouched): ${LIVE_VOLUME}"
log "Validation volume (new): ${VALIDATION_VOLUME}"
log "Backup dir: ${LATEST_DIR}"
log "Backup file: ${BACKUP_FILE}"
log "Manifest file: ${MANIFEST_FILE}"
log ""

test -f "${BACKUP_FILE}"
test -f "${MANIFEST_FILE}"

run_bounded "docker version" docker version
run_bounded "backup archive listing" tar -tzf "${BACKUP_FILE}"

log "---- create validation volume ----"
docker volume create "${VALIDATION_VOLUME}" 2>&1 | tee -a "$OUT_TXT"
log "exit=$?"
log ""

log "---- restore archive into validation volume ----"
docker run --rm \
  -v "${VALIDATION_VOLUME}:/target" \
  -v "${LATEST_DIR}:/backup:ro" \
  alpine:3.22 \
  sh -lc 'cd /target && tar -xzf /backup/'"${LIVE_VOLUME}"'.tar.gz' 2>&1 | tee -a "$OUT_TXT"
log "exit=$?"
log ""

log "---- inspect restored top-level contents ----"
docker run --rm -v "${VALIDATION_VOLUME}:/data:ro" alpine:3.22 sh -lc 'ls -la /data | sed -n "1,80p"' 2>&1 | tee -a "$OUT_TXT"
log "exit=$?"
log ""

log "---- postgres boot validation on isolated volume ----"
docker run -d --name "${VALIDATION_CONTAINER}" \
  -v "${VALIDATION_VOLUME}:/var/lib/postgresql/data" \
  postgres:16-alpine 2>&1 | tee -a "$OUT_TXT"
log "exit=$?"
log ""

python3 - << 'PY' | tee -a "$OUT_TXT"
import subprocess, time, os, sys
container = os.environ["VALIDATION_CONTAINER"]
deadline = time.time() + 90
healthy = False

while time.time() < deadline:
    p = subprocess.run(["docker", "exec", container, "pg_isready", "-U", "postgres"],
                       capture_output=True, text=True)
    if p.stdout:
        print(p.stdout, end="")
    if p.stderr:
        print(p.stderr, end="")
    print(f"pg_isready_exit={p.returncode}")
    if p.returncode == 0:
        healthy = True
        break
    time.sleep(3)

if not healthy:
    print("BOOT_VALIDATION_FAILED")
    logs = subprocess.run(["docker", "logs", container], capture_output=True, text=True)
    if logs.stdout:
        print(logs.stdout, end="")
    if logs.stderr:
        print(logs.stderr, end="")
    sys.exit(1)
else:
    print("BOOT_VALIDATION_PASSED")
PY
log ""

run_bounded "validation volume inspect" docker volume inspect "${VALIDATION_VOLUME}"

python3 - << 'PY'
from pathlib import Path
txt = Path(".runtime/phase487_isolated_restore_proof.txt").read_text(errors="ignore")

summary = []
summary.append("# Phase 487 Isolated Restore Proof")
summary.append("")
summary.append("Generated from `.runtime/phase487_isolated_restore_proof.txt`.")
summary.append("")
summary.append("## Safety Posture")
summary.append("")
summary.append("- Live protected volume remained untouched: `motherboard_systems_hq_pgdata`")
summary.append("- Restore was performed only into a new validation volume.")
summary.append("- No volume deletion occurred.")
summary.append("")
summary.append("## Result")
summary.append("")
if "BOOT_VALIDATION_PASSED" in txt:
    summary.append("- Isolated restore completed successfully.")
    summary.append("- Restored data was unpacked into a validation volume.")
    summary.append("- Disposable Postgres boot validation passed.")
    summary.append("- Restore proof is now established without touching the live protected volume.")
else:
    summary.append("- Isolated restore proof did not complete successfully.")
    summary.append("- Live protected volume still remained untouched.")
    summary.append("- Stop and inspect the validation output before any further action.")
summary.append("")
summary.append("## Key Signals")
summary.append("")
signals = []
for line in txt.splitlines():
    low = line.lower()
    if "validation volume" in low or "boot_validation" in low or "pg_isready_exit" in low:
        signals.append(line)
    if "exit=" in line or "time" in low and "timeout" in low:
        signals.append(line)
    if "error" in low or "failed" in low:
        signals.append(line)

if signals:
    summary.append("```")
    summary.extend(signals[-160:])
    summary.append("```")
else:
    summary.append("_No key signals captured._")

Path("docs/phase487_isolated_restore_proof.md").write_text("\n".join(summary) + "\n")
print("Wrote docs/phase487_isolated_restore_proof.md")
PY

sed -n '1,260p' "$OUT_MD"
