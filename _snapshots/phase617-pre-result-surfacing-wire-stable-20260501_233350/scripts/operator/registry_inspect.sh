#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

cd "$ROOT"

echo "Registry Operator Inspection"
echo "----------------------------"

npx tsx scripts/operator/registry_inspect.ts
