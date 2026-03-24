#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

npx tsx scripts/_local/phase135_governance_cognition_snapshot_smoke.ts
