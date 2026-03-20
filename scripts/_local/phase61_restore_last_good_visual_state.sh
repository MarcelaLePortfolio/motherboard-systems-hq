#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

GOOD_REF="${1:-2b467a03}"

git rev-parse -q --verify "${GOOD_REF}^{commit}" >/dev/null

git restore --source "${GOOD_REF}" -- \
  public/dashboard.html \
  public/js/phase61_tabs_workspace.js

git diff -- public/dashboard.html public/js/phase61_tabs_workspace.js || true
