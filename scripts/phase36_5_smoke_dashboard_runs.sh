#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE_URL:-http://127.0.0.1:3000}"

html="$(curl -fsS "$BASE/" | head -c 400000)"

# Capture the first <script src="..."> that contains ".js" anywhere (including querystrings)
script_path="$(
  echo "$html" \
  | grep -oE 'src="[^"]+"' \
  | sed -E 's/^src="|"$//g' \
  | grep -E '\.js($|\?)' \
  | {
      grep -E '^/bundle\.js(\?|$)' || true
      grep -E '^/js/dashboard-bundle-entry\.js(\?|$)' || true
      head -n 1 || true
    } \
  | head -n 1
)"

if [ -z "${script_path:-}" ]; then
  echo 'FAIL: dashboard HTML did not include any <script src="..."> with a .js path'
  exit 1
fi

js="$(curl -fsS "$BASE$script_path" | head -c 2000000)"

# Runs marker evidence (accept any spacing / minification)
echo "$js" | grep -Eq 'data-runs-panel="1"|runsPanel' || {
  echo "FAIL: referenced JS ($script_path) missing Runs panel marker evidence (data-runs-panel=\"1\" or runsPanel)"
  exit 1
}

curl -fsS "$BASE/api/runs?limit=1" >/dev/null || {
  echo "FAIL: /api/runs not reachable"
  exit 1
}

echo "OK: dashboard references $script_path; JS contains Runs panel marker evidence; /api/runs reachable."
