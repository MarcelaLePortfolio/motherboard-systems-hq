#!/usr/bin/env bash
set -euo pipefail

sed -n '1,120p' src/cognition/transport/consumptionRegistry/consumption_registry_enforcement_entrypoint.ts
