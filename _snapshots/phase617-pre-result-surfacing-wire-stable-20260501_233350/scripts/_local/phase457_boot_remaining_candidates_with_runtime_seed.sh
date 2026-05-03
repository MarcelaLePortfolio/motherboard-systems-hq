#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

boot_candidate() {
  local name="$1"
  local worktree="$2"
  local port="$3"
  local log="$ROOT/docs/recovery_full_audit/${name}_runtime_seed_boot.txt"

  {
    echo "===== ${name} ====="
    echo "WORKTREE=${worktree}"
    echo "PORT=${port}"
    echo

    if [ ! -d "$worktree" ]; then
      echo "STATUS=MISSING_WORKTREE"
      return 0
    fi

    cd "$worktree"

    if [ -f docker-compose.yml.bak ]; then
      mv -f docker-compose.yml.bak docker-compose.yml
    fi

    python3 - <<'PY'
from pathlib import Path
p = Path("docker-compose.yml")
t = p.read_text()
lines = t.splitlines()
out = []
in_postgres = False
skip_ports = False

for line in lines:
    stripped = line.strip()

    if line.startswith("  ") and not line.startswith("    ") and stripped.endswith(":"):
        if stripped == "postgres:":
            in_postgres = True
            skip_ports = False
        else:
            in_postgres = False
            skip_ports = False

    if in_postgres and line.startswith("    ports:"):
        skip_ports = True
        continue

    if skip_ports:
        if line.startswith("      ") or stripped == "":
            continue
        skip_ports = False

    out.append(line)

text = "\n".join(out).rstrip() + "\n"
while "\n\n\n" in text:
    text = text.replace("\n\n\n", "\n\n")
p.write_text(text)
PY

    cat > docker-compose.override.yml <<OVERRIDE
services:
  dashboard:
    ports:
      - "${port}:3000"
  postgres:
    ports: []
OVERRIDE

    echo "--- compose config ---"
    docker compose config || true
    echo

    echo "--- compose down ---"
    docker compose down -v --remove-orphans || true
    echo

    echo "--- start postgres ---"
    docker compose up -d postgres
    sleep 6
    docker compose ps -a || true
    echo

    echo "--- seed runtime tables ---"
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
    echo

    echo "--- start dashboard ---"
    docker compose up --build -d dashboard
    sleep 8
    docker compose ps -a || true
    echo

    echo "--- dashboard logs ---"
    docker compose logs dashboard --tail=120 || true
    echo

    echo "--- postgres logs ---"
    docker compose logs postgres --tail=80 || true
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

    cd "$ROOT"
  } > "$log" 2>&1 || true
}

boot_candidate "phase65_wiring" "../mbhq_recovery_visual_compare/phase65_wiring" "8092"
boot_candidate "operator_guidance" "../mbhq_recovery_visual_compare/operator_guidance" "8093"

cat > docs/recovery_full_audit/30_remaining_candidate_runtime_seed_urls.txt <<'REPORT'
PHASE 457 - REMAINING CANDIDATE RUNTIME SEED URLS
=================================================

phase65_layout      -> http://localhost:8091
phase65_wiring      -> http://localhost:8092
operator_guidance   -> http://localhost:8093

Interpretation:
- 8091 = confirmed old layout baseline
- 8092 = next checkpoint to inspect for lost telemetry/wiring
- 8093 = later operator-guidance workspace checkpoint

Logs:
- docs/recovery_full_audit/phase65_wiring_runtime_seed_boot.txt
- docs/recovery_full_audit/operator_guidance_runtime_seed_boot.txt
REPORT

open "http://localhost:8092" || true
open "http://localhost:8093" || true

sed -n '1,240p' docs/recovery_full_audit/phase65_wiring_runtime_seed_boot.txt || true
printf '\n\n'
sed -n '1,240p' docs/recovery_full_audit/operator_guidance_runtime_seed_boot.txt || true
