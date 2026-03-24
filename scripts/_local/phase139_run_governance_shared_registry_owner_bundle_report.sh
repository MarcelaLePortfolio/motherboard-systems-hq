#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

npx tsx scripts/_local/phase139_governance_shared_registry_owner_bundle_report.ts
