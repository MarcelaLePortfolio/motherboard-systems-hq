#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "Registry Verification Pass"
echo "=========================="
echo

echo "[1/3] Running registry inspection"
./scripts/operator/registry_inspect.sh
echo

echo "[2/3] Running registry workflow integration"
./scripts/operator/registry_workflow_integration.sh
echo

echo "[3/3] Verification result"
echo "-------------------------"
echo "Registry inspection completed"
echo "Registry workflow completed"
echo "Verification PASS"
