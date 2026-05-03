#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

npx tsx scripts/_local/phase145_governance_pre_live_registry_delivery_manifest_smoke.ts
