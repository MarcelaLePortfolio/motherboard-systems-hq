#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

rm -f public/dashboard.html.bak.phase61_debug || true

rm -f public/dashboard.html.bak_phase61_operator_workspace_* || true
rm -f public/js/phase61_tabs_workspace.js.bak_phase61_operator_workspace_* || true

rm -f public/js/task-events-sse-client.js.bak.phase58a.* || true

git status --short
