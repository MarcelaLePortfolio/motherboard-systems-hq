#!/usr/bin/env bash
set -euo pipefail

echo "────────────────────────────────"
echo "Phase 704: Restore run_view schema after Docker reset"
echo "────────────────────────────────"

echo ""
echo "1) Repo state..."
git status --short
git branch --show-current

echo ""
echo "2) Container state..."
docker compose ps

echo ""
echo "3) Inspecting run_view bootstrap source..."
sed -n '1,220p' server/db_bootstrap_run_view.mjs

echo ""
echo "4) Restoring run_view using existing bootstrap script..."
docker compose exec -T dashboard node server/db_bootstrap_run_view.mjs

echo ""
echo "5) Verifying database relations..."
docker compose exec -T postgres psql -U postgres -d postgres -c "\dt"
docker compose exec -T postgres psql -U postgres -d postgres -c "\dv"

echo ""
echo "6) Verifying run_view query..."
docker compose exec -T postgres psql -U postgres -d postgres -c "select * from run_view limit 10;"

echo ""
echo "7) Probing inspector-backed API endpoints without macOS timeout dependency..."
for url in \
  "http://localhost:3000/api/health" \
  "http://localhost:3000/api/tasks?limit=12" \
  "http://localhost:3000/api/runs" \
  "http://localhost:3000/api/guidance"
do
  echo ""
  echo "---- $url ----"
  curl -i -sS --max-time 8 "$url" | sed -n '1,120p' || true
done

echo ""
echo "8) Recent dashboard logs..."
docker compose logs --tail=80 dashboard || true

echo ""
echo "9) Git seal for schema restoration..."
cat > PHASE704_RUN_VIEW_RESTORED.md << 'SEAL'
# Phase 704 — run_view Restored After Docker Data Reset

Docker runtime was restored and authoritative, but the fresh Postgres volume did not contain `run_view`.

This seal records restoration of the read-only `run_view` surface required by execution/history inspection paths.

Verified after restoration:
- `tasks` table exists
- `task_events` table exists
- `run_view` view exists
- `select * from run_view limit 10` executes
- `/api/tasks?limit=12` probed
- `/api/runs` probed
- `/api/guidance` probed
SEAL

git add PHASE704_RESTORE_RUN_VIEW_SCHEMA.sh PHASE704_RUN_VIEW_RESTORED.md
git commit -m "Phase 704: restore run_view after Docker data reset"
git push

echo ""
echo "Phase 704 run_view restoration complete."
