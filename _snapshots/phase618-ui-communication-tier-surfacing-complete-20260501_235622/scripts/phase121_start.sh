#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "=== Phase 121 initialization ==="

mkdir -p src/cognition/transport/consumptionRegistry

cat > src/cognition/transport/consumptionRegistry/dashboardConsumption.registry.types.ts << 'TYPES'
export interface DashboardConsumptionRegistryEntry {
  readonly contractId: string;
  readonly adapterId: string;
  readonly version: string;
  readonly section: string;
}

export interface DashboardConsumptionRegistry {
  readonly entries: readonly DashboardConsumptionRegistryEntry[];
}

export type DashboardConsumptionRegistryLookup = (
  contractId: string
) => DashboardConsumptionRegistryEntry | undefined;
TYPES

echo "Phase 121 registry scaffold created"
