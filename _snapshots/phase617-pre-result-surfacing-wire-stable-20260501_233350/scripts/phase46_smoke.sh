#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mkdir -p _diag/phase46

bash scripts/_lib/wait_tcp.sh 127.0.0.1 8080 90

bash scripts/phase46_probe_endpoints.sh >/dev/null

code="$(curl -sS -o /dev/null -w "%{http_code}" "http://127.0.0.1:8080/" || echo "000")"
[ "$code" != "000" ]

runs_code="$(curl -sS -o /dev/null -w "%{http_code}" "http://127.0.0.1:8080/api/runs" || echo "000")"
if [ "$runs_code" = "200" ]; then
  curl -fsS "http://127.0.0.1:8080/api/runs" >/dev/null
fi
