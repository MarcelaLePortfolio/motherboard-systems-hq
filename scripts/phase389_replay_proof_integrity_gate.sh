#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "Phase 389 — Replay proof integrity gate starting"

bash scripts/phase388_replay_proof_surface_audit.sh
bash scripts/phase387_replay_chain_run.sh

echo "Phase 389 — Replay proof integrity gate complete"
