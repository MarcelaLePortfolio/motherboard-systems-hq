#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

CANDIDATES="$(rg -l --no-heading --glob 'server/**/*.mjs' --glob 'server/**/*.ts' --glob 'server.mjs' \
  'select\s+max\(id\)\s+as\s+max_id\s+from\s+task_events|from\s+task_events[\s\S]*where\s+id\s*>\s*\$1|where\s+id\s*>\s*\$1[\s\S]*order\s+by\s+id\s+asc' \
  || true)"

if [ -z "${CANDIDATES}" ]; then
  echo "ERR: no candidate files found" >&2
  exit 2
fi

echo "${CANDIDATES}"

for f in ${CANDIDATES}; do
  cp -av "$f" "$f.bak.$(date +%Y%m%d_%H%M%S)" >/dev/null
  perl -0777 -i -pe '
    s/\bselect\s+max\(id\)\s+as\s+max_id\s+from\s+task_events\b/select max(created_at) as max_created_at from task_events/gi;
    s/\bwhere\s+id\s*>\s*\$1\b/where created_at > $1/gi;
    s/\border\s+by\s+id\s+asc\b/order by created_at asc/gi;
  ' "$f"
done

rg -n --no-heading 'max\(id\)\s+as\s+max_id\s+from\s+task_events' server server.mjs || true
rg -n --no-heading 'where\s+id\s*>\s*\$1' server server.mjs || true
