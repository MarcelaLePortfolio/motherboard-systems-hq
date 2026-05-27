#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

compose() { docker compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.worker.yml "$@"; }

echo "=== services ==="
compose config --services | sort

echo
echo "=== worker service + profiles (from resolved config) ==="
compose config | awk '
BEGIN{p=0}
$0 ~ /^  worker:$/ {p=1; print; next}
p==1 {
  if ($0 ~ /^  [a-zA-Z0-9_.-]+:$/ && $0 !~ /^  worker:$/) exit
  print
}
'
