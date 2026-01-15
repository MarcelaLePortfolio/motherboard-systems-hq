#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
git fetch --tags -q
git checkout -B feature/phase26-task-worker-min v25.0-task-events-single-writer-ok
echo "OK: feature/phase26-task-worker-min @ v25.0-task-events-single-writer-ok"
