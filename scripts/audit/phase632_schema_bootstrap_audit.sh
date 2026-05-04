#!/usr/bin/env bash
set -euo pipefail

echo "=== Phase 632 Schema Bootstrap Audit ==="
echo
echo "Searching for task table bootstrap definitions..."
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=_snapshots \
  -E "CREATE TABLE.*tasks|next_run_at|completed_at|tasks" . \
  | sed -n '1,160p'
echo
echo "Current running DB task schema:"
docker compose exec postgres psql -U postgres -d postgres -c "\d tasks"
