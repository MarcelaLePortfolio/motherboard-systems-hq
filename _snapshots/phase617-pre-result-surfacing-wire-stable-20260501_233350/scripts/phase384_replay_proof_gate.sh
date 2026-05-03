#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "Phase 384 — Replay proof gate starting"

bash scripts/phase383_replay_proof_execution.sh
bash scripts/phase382_replay_proof_seal.sh

echo "Phase 384 — Replay proof gate complete"
