#!/usr/bin/env bash
set -euo pipefail

# Run the Motherboard Systems HQ dashboard locally on port 3000.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "Starting local dashboard on [http://127.0.0.1:3000/dashboard](http://127.0.0.1:3000/dashboard)"
node server.mjs
