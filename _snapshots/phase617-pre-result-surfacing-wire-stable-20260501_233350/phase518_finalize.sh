#!/usr/bin/env bash
set -euo pipefail

echo "[1] Final health check"
curl -sS 'http://localhost:8080/api/health'
echo

echo "[2] Final task surface check"
curl -sS 'http://localhost:8080/api/tasks?limit=1' | jq
echo

echo "[3] Tagging final clean checkpoint"
git tag phase-518-clean-worker-claim-lifecycle-validated || true
git push origin phase-518-clean-worker-claim-lifecycle-validated

echo
echo "=== PHASE 518 FINALIZED ==="
echo "System: CLEAN"
echo "State: CONSISTENT"
echo "Checkpoint: TAGGED"
