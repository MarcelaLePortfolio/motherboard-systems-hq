#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

git add public/dashboard.html public/js/phase61_tabs_workspace.js
git commit -m "Recover dashboard layout from Phase 61 checkpoint"
git push
