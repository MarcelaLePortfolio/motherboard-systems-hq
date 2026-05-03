#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

rm -f .git/index.lock .git/HEAD.lock .git/ORIG_HEAD.lock
find .git -name "*.lock" -delete 2>/dev/null || true

printf '\n===== REPORT =====\n'
sed -n '1,320p' docs/phase487_postgres_gate_startup_report.txt 2>/dev/null || echo "report missing"

printf '\n===== RUNTIME LOG =====\n'
tail -n 200 logs/phase487_dashboard_recovery_runtime.log 2>/dev/null || echo "runtime log missing"

printf '\n===== HTTP PROBE =====\n'
curl -I --max-time 10 http://localhost:8080 || true

printf '\n===== PORTS =====\n'
lsof -nP -iTCP:5432 -sTCP:LISTEN || true
lsof -nP -iTCP:8080 -sTCP:LISTEN || true

printf '\n===== COMPOSE STATUS =====\n'
docker compose ps || true

git add scripts/_local/phase487_start_dashboard_after_postgres_ready.sh \
        scripts/_local/phase487_finalize_postgres_gated_recovery.sh \
        docs/phase487_postgres_gate_startup_report.txt \
        logs/phase487_dashboard_recovery_runtime.log || true

git commit -m "phase487: finalize postgres-gated dashboard recovery status" || true
git push
