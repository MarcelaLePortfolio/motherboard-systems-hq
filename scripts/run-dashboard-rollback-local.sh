#!/usr/bin/env bash
set -euo pipefail

# Run the rolled-back v11.7 dashboard baseline locally on port 3000.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "Running v11.7 rollback dashboard at [http://127.0.0.1:3000/dashboard](http://127.0.0.1:3000/dashboard)"
node server.mjs
