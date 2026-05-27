#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

CHECKPOINT_TAG="${1:-v61.0-observational-workspace-checkpoint}"

git rev-parse -q --verify "refs/tags/${CHECKPOINT_TAG}" >/dev/null

git restore --source "${CHECKPOINT_TAG}" -- \
  public/dashboard.html \
  public/js/phase61_tabs_workspace.js

git diff -- public/dashboard.html public/js/phase61_tabs_workspace.js || true
