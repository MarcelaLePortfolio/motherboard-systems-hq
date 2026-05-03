#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE_URL:-http://127.0.0.1:3000}"

# 1) baseline
curl -fsS "$BASE/api/runs?limit=1" >/dev/null || {
  echo "FAIL: baseline /api/runs failed"
  exit 1
}

# 2) is_terminal filter
curl -fsS "$BASE/api/runs?limit=1&is_terminal=true" >/dev/null || {
  echo "FAIL: /api/runs is_terminal=true failed"
  exit 1
}

# 3) task_status repeatable filter (should not error even if empty result)
curl -fsS "$BASE/api/runs?limit=5&task_status=completed&task_status=failed" >/dev/null || {
  echo "FAIL: /api/runs repeatable task_status failed"
  exit 1
}

# 4) since_ts sanity (use a very old timestamp so it should behave like baseline)
curl -fsS "$BASE/api/runs?limit=1&since_ts=0" >/dev/null || {
  echo "FAIL: /api/runs since_ts=0 failed"
  exit 1
}

echo "OK: Phase 36.6 API runs filters smoke passed."
