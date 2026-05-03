#!/usr/bin/env bash
set -euo pipefail
BASE="http://127.0.0.1:8080"
ENDPOINT="${1:-/api/tasks/create}"

curl -sS -D - -o /tmp/seed.out \
  -H "Content-Type: application/json" \
  -X POST "$BASE$ENDPOINT" \
  --data-binary @- <<'JSON'
{
  "kind": "demo.seed",
  "type": "demo.seed",
  "name": "phase31.6 seed task",
  "title": "phase31.6 seed task",
  "payload": { "msg": "seeded via curl" },
  "meta": { "actor": "curl", "note": "manual seed task" }
}
JSON
echo
echo "=== response body ==="
sed -n '1,220p' /tmp/seed.out
