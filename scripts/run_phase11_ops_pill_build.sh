#!/usr/bin/env bash
set -euo pipefail

# Root of the project

cd "$(dirname "$0")/.."

echo "▶ Phase 11 – rebuilding dashboard bundle and containers for OPS pill update..."
./scripts/build_dashboard_bundle.sh
