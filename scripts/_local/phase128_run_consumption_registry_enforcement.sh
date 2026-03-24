#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

scripts/_local/phase128_consumption_registry_smoke_suite.sh

echo "phase128 enforcement runner: PASS"
