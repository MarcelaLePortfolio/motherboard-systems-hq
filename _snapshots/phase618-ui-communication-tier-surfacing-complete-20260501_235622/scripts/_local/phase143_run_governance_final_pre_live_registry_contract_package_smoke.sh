#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

npx tsx scripts/_local/phase143_governance_final_pre_live_registry_contract_package_smoke.ts
