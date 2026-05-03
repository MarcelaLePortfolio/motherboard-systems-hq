# PHASE 46 — Operator-grade Run Lifecycle + Recovery

Starting point: `v45.1-operational-hardening-golden` on `feature/phase46-enforcement-safely-enabled`.

## Goals
- Deterministic bring-up
- Smoke checks (API + core lifecycle visibility endpoints)
- Deterministic shutdown
- Recovery primitives (restart key services + collect diagnostics)

## Commands

### 1) Bring-up (deterministic)
bash scripts/phase46_bringup.sh

### 2) Smoke (lifecycle visibility)
bash scripts/phase46_smoke.sh

### 3) Shutdown (clean)
bash scripts/phase46_shutdown.sh

### 4) Recovery primitives
bash scripts/phase46_recovery_primitives.sh

### 5) One-shot operator harness
bash scripts/phase46_operator_grade_harness.sh

## Notes
- All scripts are safe to re-run.
- Diagnostics bundle writes to ./_diag/phase46/ and a timestamped tarball.
