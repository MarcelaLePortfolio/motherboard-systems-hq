#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

fix_and_boot() {
  local name="$1"
  local worktree="$2"
  local port="$3"
  local log="$ROOT/docs/recovery_full_audit/${name}_base_port_removed_boot.txt"

  {
    echo "===== ${name} ====="
    echo "WORKTREE=${worktree}"
    echo "PORT=${port}"
    echo

    [ -d "$worktree" ] || { echo "STATUS=MISSING_WORKTREE"; return 0; }

    cd "$worktree"

    python3 - <<'PY'
from pathlib import Path

p = Path("docker-compose.yml")
text = p.read_text().splitlines()

out = []
current_service = None
skip_ports = False

for line in text:
    stripped = line.strip()

    if line.startswith("  ") and not line.startswith("    ") and stripped.endswith(":"):
        current_service = stripped[:-1]
        skip_ports = False

    if current_service in {"postgres", "dashboard"} and line.startswith("    ports:"):
        skip_ports = True
        continue

    if skip_ports:
        if line.startswith("      ") or stripped == "":
            continue
        skip_ports = False

    out.append(line)

new_text = "\n".join(out).rstrip() + "\n"
while "\n\n\n" in new_text:
    new_text = new_text.replace("\n\n\n", "\n\n")

p.write_text(new_text)
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

fix_and_boot "phase65_wiring" "../mbhq_recovery_visual_compare/phase65_wiring" "8092"
fix_and_boot "operator_guidance" "../mbhq_recovery_visual_compare/operator_guidance" "8093"

cat > docs/recovery_full_audit/31_remaining_candidates_after_base_port_removal.txt <<'REPORT'
PHASE 457 - REMAINING CANDIDATES AFTER BASE PORT REMOVAL
========================================================

phase65_layout      -> http://localhost:8091
phase65_wiring      -> http://localhost:8092
operator_guidance   -> http://localhost:8093

Expected:
- 8092 should now boot without base 8080 collision
- 8093 should now boot without base 8080 collision

Logs:
- docs/recovery_full_audit/phase65_wiring_base_port_removed_boot.txt
- docs/recovery_full_audit/operator_guidance_base_port_removed_boot.txt
REPORT

open "http://localhost:8092" || true
open "http://localhost:8093" || true

sed -n '1,220p' docs/recovery_full_audit/phase65_wiring_base_port_removed_boot.txt || true
printf '\n\n'
sed -n '1,220p' docs/recovery_full_audit/operator_guidance_base_port_removed_boot.txt || true
