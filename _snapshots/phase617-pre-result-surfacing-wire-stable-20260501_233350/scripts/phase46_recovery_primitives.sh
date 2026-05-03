#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p _diag/phase46
bash scripts/_lib/wait_http.sh "http://127.0.0.1:8080/api/runs" 90
ts="$(date +%Y%m%d-%H%M%S)"
bundle_dir="_diag/phase46/bundle_${ts}"
mkdir -p "$bundle_dir"
docker compose ps > "${bundle_dir}/compose_ps.txt" || true
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' > "${bundle_dir}/docker_ps.txt" || true
curl -fsS "http://127.0.0.1:8080/api/runs" > "${bundle_dir}/api_runs.json" || true
curl -fsS "http://127.0.0.1:8080/api/tasks" > "${bundle_dir}/api_tasks.json" || true
curl -fsS "http://127.0.0.1:8080/api/task-events" > "${bundle_dir}/api_task_events.json" || true
dash="$(docker ps --format '{{.Names}}' | grep -E 'dashboard' | head -n1 || true)"
pg="$(docker ps --format '{{.Names}}' | grep -E 'postgres' | head -n1 || true)"
if [ -n "${dash}" ]; then
  docker logs --tail=400 "${dash}" > "${bundle_dir}/dashboard_tail.log" 2>/dev/null || true
  docker restart "${dash}" >/dev/null
  bash scripts/_lib/wait_http.sh "http://127.0.0.1:8080/api/runs" 90
  curl -fsS "http://127.0.0.1:8080/api/runs" >/dev/null
fi
if [ -n "${pg}" ]; then
  docker logs --tail=400 "${pg}" > "${bundle_dir}/postgres_tail.log" 2>/dev/null || true
  docker restart "${pg}" >/dev/null
  sleep 2
  bash scripts/_lib/wait_http.sh "http://127.0.0.1:8080/api/runs" 90
  curl -fsS "http://127.0.0.1:8080/api/runs" >/dev/null
fi
tarball="_diag/phase46/phase46_diag_${ts}.tgz"
tar -czf "${tarball}" -C "_diag/phase46" "bundle_${ts}"
printf '%s\n' "${tarball}"
