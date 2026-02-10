#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE_URL:-http://127.0.0.1:3000}"

html="$(curl -fsS "$BASE/" | head -c 400000)"

script_path="$(
  echo "$html" | grep -oE 'src="[^"]+\.js"' | sed -E 's/^src="|"$//g' | {
    grep -E '^/bundle\.js(\?|$)' || true
    grep -E '^/js/dashboard-bundle-entry\.js(\?|$)' || true
    grep -E '^/js/[^"]+\.js(\?|$)' | head -n 1 || true
  } | head -n 1
)"

if [ -z "${script_path:-}" ]; then
  echo "FAIL: dashboard HTML did not include any <script src=\"...js\"> tags we could parse"
  exit 1
fi

js="$(curl -fsS "$BASE$script_path" | head -c 2000000)"

echo "$js" | grep -q 'data-runs-panel="1"\|dataset\.runsPanel\s*=\s*"1"' || {
  echo "FAIL: referenced JS ($script_path) missing runs panel marker (data-runs-panel=\"1\" or dataset.runsPanel=\"1\")"
  exit 1
}

curl -fsS "$BASE/api/runs?limit=1" >/dev/null || {
  echo "FAIL: /api/runs not reachable"
  exit 1
}

echo "OK: dashboard references $script_path; JS contains Runs panel marker; /api/runs reachable."
