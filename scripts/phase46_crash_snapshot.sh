#!/usr/bin/env bash
set -euo pipefail
TS="$(date +%Y%m%d-%H%M%S)"
OUT="_diag/phase46/crash_${TS}"
mkdir -p "$OUT"

COMPOSE="docker compose -f docker-compose.yml -f docker-compose.workers.yml"

echo "=== ps (compose) ===" | tee "$OUT/00_ps.txt"
$COMPOSE ps | tee -a "$OUT/00_ps.txt"

echo "=== ps (docker) ===" | tee "$OUT/01_docker_ps.txt"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}' | tee -a "$OUT/01_docker_ps.txt"

echo "=== inspect exit codes ===" | tee "$OUT/02_exit_codes.txt"
for n in motherboard_systems_hq-dashboard-1 motherboard_systems_hq-workerA-1 motherboard_systems_hq-workerB-1 motherboard_systems_hq-postgres-1; do
  if docker inspect "$n" >/dev/null 2>&1; then
    docker inspect -f '{{.Name}}  State={{.State.Status}}  Exit={{.State.ExitCode}}  OOM={{.State.OOMKilled}}  Finished={{.State.FinishedAt}}' "$n" \
      | tee -a "$OUT/02_exit_codes.txt"
  fi
done

echo "=== last logs ===" | tee "$OUT/03_logs_tail.txt"
$COMPOSE logs --no-color --tail=250 dashboard postgres workerA workerB | tee -a "$OUT/03_logs_tail.txt" || true

echo "=== network labels ===" | tee "$OUT/04_network_labels.txt"
docker network inspect motherboard_systems_hq_default \
  -f 'Name={{.Name}} Labels={{json .Labels}}' | tee -a "$OUT/04_network_labels.txt" || true

echo "OK: wrote $OUT"
