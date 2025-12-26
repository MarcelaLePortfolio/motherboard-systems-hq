#!/usr/bin/env bash
# Usage:
#   ./scripts/_local/safe-run.sh -- <command...>
#   ./scripts/_local/safe-run.sh curl -I http://127.0.0.1:8080/css/dashboard.css
set -u

if [ "${1:-}" = "--" ]; then shift; fi
if [ $# -eq 0 ]; then
  echo "usage: safe-run.sh -- <command...>" >&2
  exit 2
fi

echo "→ $*"
set +e
"$@"
rc=$?
set -e
echo "↳ exit=$rc"
exit 0
