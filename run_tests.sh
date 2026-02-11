#!/usr/bin/env bash
set -euo pipefail


# Phase 37.6: guard against run_view drift (single owner)
./scripts/phase37_6_run_view_single_owner_check.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

echo "run_tests.sh: repo_root=$REPO_ROOT"

# Prefer an existing project-owned test runner if present.
CANDIDATES=(
  "./scripts/run_tests.sh"
  "./scripts/ci/run_tests.sh"
  "./scripts/_ci/run_tests.sh"
  "./scripts/test.sh"
  "./scripts/smoke/ci.sh"
  "./scripts/smoke/run_tests.sh"
)

for c in "${CANDIDATES[@]}"; do
  if [[ -f "$c" ]]; then
    [[ -x "$c" ]] || chmod +x "$c" || true
    echo "run_tests.sh: delegating to $c"
    exec "$c"
  fi
done

# Fallback to package manager test scripts if present.
if [[ -f "package.json" ]]; then
  if command -v pnpm >/dev/null 2>&1; then
    echo "run_tests.sh: running pnpm test"
    exec pnpm test
  fi
  if command -v npm >/dev/null 2>&1; then
    echo "run_tests.sh: running npm test"
    exec npm test
  fi
  if command -v yarn >/dev/null 2>&1; then
    echo "run_tests.sh: running yarn test"
    exec yarn test
  fi
fi

echo "run_tests.sh: ERROR no test runner found (no scripts/* runner, no package.json test runner)" >&2
exit 127
