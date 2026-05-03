#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "Phase 387 — Replay chain execution starting"

bash scripts/phase386_replay_chain_seal.sh

echo "Verifying repository clean state"
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Repository not clean"
  git status --short
  exit 1
fi

echo "Phase 387 — Replay chain execution complete"
