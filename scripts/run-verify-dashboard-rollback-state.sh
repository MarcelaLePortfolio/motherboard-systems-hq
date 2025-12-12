#!/usr/bin/env bash
set -euo pipefail

# Run the rollback/layout verification script for the dashboard.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

./scripts/verify-dashboard-rollback-state.sh
