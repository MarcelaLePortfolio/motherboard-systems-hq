#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

mkdir -p docs

cat > docs/phase487_backup_baseline.md <<'DOC'
# Phase 487 Backup Baseline Definition

## Purpose
Establish a deterministic, minimal, and sufficient backup scope to allow full system reconstruction without relying on volatile runtime artifacts.

---

## 1. Canonical Backup Scope (MUST BACK UP)

### Code + System Definition
- All source code (repo root)
- scripts/
- app/
- server/
- src/
- public/
- configs (tsconfig, package.json, etc.)

### Documentation (STRUCTURAL ONLY)
- docs/*.md (strategy, checkpoints, handoffs)
- docs/*.txt that represent structured system reasoning or checkpoints

### Git State
- full git history (remote origin)
- tags (checkpoint anchors)

---

## 2. CONDITIONAL / CONTROLLED BACKUP

### Database (CRITICAL STATE)
- db/main.db (or canonical DB file)

Rules:
- Must be backed up periodically
- Must NOT rely on WAL/SHM files
- Backup must be consistent snapshot

---

## 3. EXCLUDED FROM BACKUP (DO NOT BACK UP)

### Runtime Sidefiles
- db/*.db-wal
- db/*.db-shm
- db/*.sqlite-wal
- db/*.sqlite-shm

### Volatile Artifacts
- docs/phase487_*probe_output.txt
- docs/phase487_*live_probe_output.txt
- docs/phase487_*surface_probe_output.txt
- docs/phase487_*audit_output.txt

### Runtime Directories
- .runtime/
- node_modules/
- .next/

---

## 4. RECONSTRUCTABLE (DO NOT BACK UP)

These can be recreated:
- containers
- build outputs
- node_modules
- compiled bundles

---

## 5. RESTORE REQUIREMENTS (ZERO-TO-ONE)

To restore system:

1. Clone repo
2. Install dependencies
3. Restore DB file (if applicable)
4. Start services
5. Verify dashboard + system health

---

## 6. INVARIANTS

- Backup must be minimal but sufficient
- No volatile data included
- No append-only artifacts included
- Restore must not depend on hidden state

---

## RESULT

System is now:

- Backup-scope defined
- Artifact-safe
- Ready for restore-proof corridor

DOC

echo "Backup baseline definition written to docs/phase487_backup_baseline.md"
