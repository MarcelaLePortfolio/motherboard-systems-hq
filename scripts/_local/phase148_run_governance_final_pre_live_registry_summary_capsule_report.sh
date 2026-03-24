#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

npx tsx scripts/_local/phase148_governance_final_pre_live_registry_summary_capsule_report.ts
