#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="b299212aa"
OUTPUT="docs/checkpoints/APPROVED_PACKAGE_LIVE_RUNTIME_RECONCILIATION.txt"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

{
  echo "=== PORT 3000 PROCESS ==="
  PID="$(lsof -tiTCP:3000 -sTCP:LISTEN | head -1 || true)"
  echo "PID=${PID:-NONE}"

  if [ -n "${PID:-}" ]; then
    echo
    echo "=== PROCESS COMMAND ==="
    ps -p "$PID" -o pid=,ppid=,etime=,command=

    echo
    echo "=== PROCESS WORKING DIRECTORY ==="
    lsof -a -p "$PID" -d cwd -Fn 2>/dev/null || true
  fi

  echo
  echo "=== CURRENT REPO ROOT ==="
  pwd

  echo
  echo "=== CURRENT DIST CANONICAL REPOSITORY ==="
  grep -n -A 30 -B 10 \
    -E 'awaiting_delegation|delegationStatement|governance_delegations' \
    dist/db/canonical-package-read-repository.js || true

  echo
  echo "=== SERVER INDEX CANONICAL ROUTE BINDING ==="
  grep -Rni \
    -E 'canonical-packages|canonicalPackageRead|createCanonicalPackageReadRepository' \
    dist/server server \
    --include='*.js' \
    --include='*.ts' \
    | head -160 || true

  echo
  echo "=== LIVE RESPONSE STILL MISSING DELEGATION? ==="
  curl -sS \
    "http://localhost:3000/api/canonical-packages?project_id=hq" \
    | grep -o '"delegation"' \
    | head -1 \
    || true

  echo
  echo "RUNTIME_RECONCILIATION_MUTATION=NO"
  echo "NEXT_ACTION=RESTART_ONLY_IF_PID_IS_CONFIRMED_STALE_CURRENT_REPO_RUNTIME"
} | tee "$OUTPUT"

git diff --check -- "$OUTPUT"
