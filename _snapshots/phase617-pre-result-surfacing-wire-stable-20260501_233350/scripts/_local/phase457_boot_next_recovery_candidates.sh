#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
mkdir -p "$ROOT/docs/recovery_full_audit"

launch_candidate() {
  local name="$1"
  local worktree="$2"
  local port="$3"
  local log="$ROOT/docs/recovery_full_audit/${name}_boot_on_${port}.txt"

  {
    echo "===== ${name} ====="
    echo "WORKTREE=${worktree}"
    echo "PORT=${port}"
    echo

    if [ ! -d "$worktree" ]; then
      echo "MISSING_WORKTREE=$worktree"
      return 0
    fi

    cd "$worktree"

    cat > docker-compose.override.yml <<OVERRIDE
services:
  dashboard:
    ports:
      - "${port}:3000"
  postgres:
    ports: []
OVERRIDE

    docker compose down -v --remove-orphans || true
    docker compose up -d postgres

    sleep 6

    docker compose exec -T postgres psql -U postgres -d postgres <<'SQL'
create table if not exists tasks (
  id serial primary key,
  task_id text,
  title text,
  status text,
  created_at timestamptz default now()
);

create table if not exists task_events (
  id bigserial primary key,
  task_id text,
  run_id text,
  kind text,
  status text,
  actor text,
  message text,
  created_at timestamptz default now()
);
SQL

    docker compose up --build -d dashboard

    sleep 8

    echo "--- compose ps -a ---"
    docker compose ps -a || true
    echo

    echo "--- dashboard logs ---"
    docker compose logs dashboard --tail=120 || true
    echo

    echo "--- port listen ---"
    lsof -nP -iTCP:"${port}" -sTCP:LISTEN || true
    echo

    echo "--- http headers ---"
    curl -I --max-time 10 "http://localhost:${port}" || true
    echo

    echo "--- title ---"
    curl -L --max-time 10 "http://localhost:${port}" 2>/dev/null | grep -o '<title>[^<]*</title>' | head -n 1 || true
    echo
  } > "$log" 2>&1 || true
}

launch_candidate "phase65_wiring" "../mbhq_recovery_visual_compare/phase65_wiring" "8092"
launch_candidate "operator_guidance" "../mbhq_recovery_visual_compare/operator_guidance" "8093"

cat > "$ROOT/docs/recovery_full_audit/28_next_candidate_boot_urls.txt" <<'REPORT'
PHASE 457 - NEXT CANDIDATE BOOT URLS
====================================

phase65_layout      -> http://localhost:8091
phase65_wiring      -> http://localhost:8092
operator_guidance   -> http://localhost:8093

Interpretation:
- 8091 = confirmed old layout baseline
- 8092 = next checkpoint to inspect for lost telemetry/wiring
- 8093 = later operator-guidance workspace checkpoint

Logs:
- docs/recovery_full_audit/phase65_wiring_boot_on_8092.txt
- docs/recovery_full_audit/operator_guidance_boot_on_8093.txt
REPORT

open "http://localhost:8092" || true
open "http://localhost:8093" || true
