#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

python3 scripts/_local/phase149_execution_capability_audit.py | tee /tmp/phase149_execution_capability_audit.json
